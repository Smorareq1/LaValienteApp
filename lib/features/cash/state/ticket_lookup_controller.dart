import 'package:design_system/design_system.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../../orders/models/order.dart';
import '../../scan/data/scan_remote_datasource.dart';
import '../../scan/models/ticket_lookup.dart';
import '../../scan/state/ticket_photo_picker.dart';
import 'deliveries_controller.dart';

part 'ticket_lookup_controller.g.dart';

/// Cómo terminó escanear una boleta para entregarla (plan 0006 §7.1.1).
///
/// Un conjunto cerrado y no un `bool` con mensaje: cada final tiene una salida
/// distinta —marcar, avisar, dejar escrito en el buscador— y dejar que la
/// pantalla las distinga por el texto sería colgar la interfaz de una frase.
sealed class TicketLookupOutcome {
  const TicketLookupOutcome();
}

/// Nadie tomó la foto. No es un error y no se dice nada.
class TicketLookupCancelled extends TicketLookupOutcome {
  const TicketLookupCancelled();
}

/// La boleta es esta, está abierta y quedó marcada.
///
/// Que quede **marcada** y no entregada es el punto: escanear automatiza el
/// acto de anotar el número, no el de cobrar. Lo que se entrega y por cuánto se
/// sigue confirmando en la hoja, igual que si se hubiera tecleado.
class TicketMarked extends TicketLookupOutcome {
  const TicketMarked(this.order, {this.wasAlreadyMarked = false});

  final OrderListItem order;

  /// Ya estaba marcada antes de esta foto. Se dice, en vez de callarlo: quien
  /// barre una pila necesita saber que no la contó dos veces.
  final bool wasAlreadyMarked;
}

/// Existe, pero ya no está abierta: se entregó o se anuló.
class TicketAlreadyClosed extends TicketLookupOutcome {
  const TicketAlreadyClosed(this.match);

  final TicketLookupMatch match;
}

/// El servidor la conoce y este teléfono todavía no.
///
/// Pasa con una boleta que otro dispositivo capturó hace un momento: el pull
/// aún no la bajó. Se dice tal cual en vez de fingir que no existe, porque la
/// respuesta —esperar al siguiente ciclo— depende de saberlo.
class TicketNotMirrored extends TicketLookupOutcome {
  const TicketNotMirrored(this.match);

  final TicketLookupMatch match;
}

/// El serial impreso y el número escrito a mano apuntan a boletas distintas.
/// La decisión es de quien tiene el papel.
class TicketAmbiguous extends TicketLookupOutcome {
  const TicketAmbiguous(this.matches);

  final List<TicketLookupMatch> matches;
}

/// Se leyó algo que no corresponde a ninguna boleta, o no se leyó nada.
///
/// Lleva lo que se leyó para dejarlo escrito en el buscador: casi siempre es un
/// dígito mal leído, y corregirlo tecleando es más rápido que volver a
/// encuadrar la foto.
class TicketNotFound extends TicketLookupOutcome {
  const TicketNotFound({this.read});

  final String? read;

  bool get wasUnreadable => read == null;
}

/// No se pudo leer: sin señal, sin cupo, o el proveedor caído.
class TicketLookupFailed extends TicketLookupOutcome {
  const TicketLookupFailed(this.failure);

  final AppFailure failure;
}

/// Escanear una boleta para entregarla.
///
/// Es el acelerador del buscador, no otro camino (plan 0006 §7.1.1): termina
/// exactamente donde termina teclear el número —con la boleta marcada en la
/// lista— y cuando no puede, deja lo que leyó escrito en el buscador para que
/// la persona siga a mano. El camino manual nunca depende de esto (plan 0003
/// D8).
@riverpod
class TicketLookupController extends _$TicketLookupController {
  @override
  bool build() => false;

  /// `true` mientras la foto va y viene, para que el botón no se pueda tocar
  /// dos veces: cada toque es una llamada al proveedor que se cobra.
  bool get isBusy => state;

  Future<TicketLookupOutcome> scan(AppImageSource source) async {
    if (state) return const TicketLookupCancelled();

    final image = await ref.read(ticketPhotoPickerProvider).pick(source);
    if (image == null) return const TicketLookupCancelled();

    state = true;
    try {
      final result = await ref.read(scanRemoteDataSourceProvider).lookup(image);
      return _resolve(result);
    } catch (error) {
      return TicketLookupFailed(AppFailure.fromException(error));
    } finally {
      state = false;
    }
  }

  /// Contrasta lo que dijo el servidor contra el espejo local.
  ///
  /// El servidor identifica la boleta, pero quien la marca es la lista de acá:
  /// la hoja de cobro se arma con el pedido local —su saldo, sus prendas— y
  /// funciona sin señal. Aceptar un id que este teléfono no tiene dejaría una
  /// selección que la hoja no podría dibujar.
  TicketLookupOutcome _resolve(TicketLookupResult result) {
    if (result.matches.length > 1) {
      _leaveInSearchBox(result);
      return TicketAmbiguous(result.matches);
    }
    if (result.matches.isEmpty) {
      _leaveInSearchBox(result);
      return TicketNotFound(read: result.asSearchText);
    }

    final match = result.matches.single;
    final open = ref.read(openOrdersProvider).valueOrNull ?? const <OrderListItem>[];
    final order = open.where((item) => item.id == match.orderId).firstOrNull;

    if (order == null) {
      // Abierta para el servidor pero ausente de la lista local: o el pull no
      // la ha bajado, o ya no está abierta. El estado que mandó el servidor lo
      // distingue, y son dos frases distintas.
      _leaveInSearchBox(result);
      return _isOpen(match.status)
          ? TicketNotMirrored(match)
          : TicketAlreadyClosed(match);
    }

    final marked = ref.read(deliverySelectionProvider.notifier).mark(order);
    return TicketMarked(order, wasAlreadyMarked: !marked);
  }

  /// Deja lo leído escrito en el buscador, que es el camino que siempre
  /// funciona. No se toca cuando sí hubo boleta: sobreescribir la búsqueda de
  /// alguien que acaba de marcar una escondería el resto de su lista.
  void _leaveInSearchBox(TicketLookupResult result) {
    final text = result.asSearchText;
    if (text != null) {
      ref.read(deliverySearchQueryProvider.notifier).update(text);
    }
  }

  static bool _isOpen(String status) =>
      status == 'received' || status == 'in_progress' || status == 'ready';
}
