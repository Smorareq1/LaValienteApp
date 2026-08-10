import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/scan_remote_datasource.dart';
import '../models/cash_sheet.dart';

part 'cash_sheet_controller.g.dart';

/// En qué va el escaneo de la hoja de caja.
sealed class CashSheetState {
  const CashSheetState();
}

class CashSheetIdle extends CashSheetState {
  const CashSheetIdle();
}

class CashSheetSending extends CashSheetState {
  const CashSheetSending(this.image);

  final Uint8List image;
}

class CashSheetFailed extends CashSheetState {
  const CashSheetFailed(this.image, this.failure);

  final Uint8List image;
  final AppFailure failure;
}

/// La hoja leída y sobre la mesa: cada fila con lo que la persona lleva
/// marcado. Nada de esto se ha escrito todavía.
class CashSheetReview extends CashSheetState {
  const CashSheetReview({
    required this.image,
    required this.result,
    required this.dayIndex,
    required this.incomes,
    required this.expenses,
    required this.attendance,
    this.applying = false,
    this.failure,
  });

  final Uint8List image;
  final CashSheetResult result;

  /// Cuál de los bloques de la hoja se está revisando. Se importa **de uno en
  /// uno**: cada día es su propio acto, con su propio candado de fecha.
  final int dayIndex;

  /// Lo editado, por índice de fila. Las que no están aquí no se mandan.
  final Map<int, IncomeEdit> incomes;
  final Map<int, ExpenseEdit> expenses;
  final Map<int, AttendanceEdit> attendance;

  final bool applying;
  final AppFailure? failure;

  CashSheetDay get day => result.days[dayIndex];

  int get selectedIncomes =>
      incomes.values.where((edit) => edit.selected).length;
  int get selectedExpenses =>
      expenses.values.where((edit) => edit.selected).length;
  int get selectedAttendance =>
      attendance.values.where((edit) => edit.selected).length;

  /// Lo que se va a cobrar si se aplica tal como está.
  int get collectedTotal => incomes.values
      .where((edit) => edit.selected)
      .fold(0, (sum, edit) => sum + edit.amount);

  int get spentTotal => expenses.values
      .where((edit) => edit.selected)
      .fold(0, (sum, edit) => sum + edit.amount);

  bool get hasSomethingToApply =>
      selectedIncomes > 0 || selectedExpenses > 0 || selectedAttendance > 0;

  CashSheetReview copyWith({
    int? dayIndex,
    Map<int, IncomeEdit>? incomes,
    Map<int, ExpenseEdit>? expenses,
    Map<int, AttendanceEdit>? attendance,
    bool? applying,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return CashSheetReview(
      image: image,
      result: result,
      dayIndex: dayIndex ?? this.dayIndex,
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
      attendance: attendance ?? this.attendance,
      applying: applying ?? this.applying,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

/// Se aplicó. Lo que quedó fuera se enseña aquí, no se pierde.
class CashSheetApplied extends CashSheetState {
  const CashSheetApplied(this.result);

  final CashSheetApplyResult result;
}

/// Una fila de cobro, como la dejó la persona.
class IncomeEdit {
  const IncomeEdit({
    required this.selected,
    required this.amount,
    required this.method,
    required this.deliver,
  });

  final bool selected;

  /// Centavos.
  final int amount;

  final String method;
  final bool deliver;

  IncomeEdit copyWith({bool? selected, int? amount, String? method, bool? deliver}) {
    return IncomeEdit(
      selected: selected ?? this.selected,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      deliver: deliver ?? this.deliver,
    );
  }
}

class ExpenseEdit {
  const ExpenseEdit({
    required this.selected,
    required this.concept,
    required this.amount,
    required this.method,
    required this.status,
    this.categoryId,
    this.employeeId,
    this.observations,
  });

  final bool selected;
  final String concept;
  final int amount;
  final String method;
  final String status;
  final String? categoryId;
  final String? employeeId;
  final String? observations;

  /// Sin categoría no se puede archivar: el servidor la exige y la hoja no
  /// siempre la dice.
  bool get isComplete =>
      categoryId != null && concept.trim().isNotEmpty && amount > 0;

  ExpenseEdit copyWith({
    bool? selected,
    String? concept,
    int? amount,
    String? method,
    String? status,
    String? categoryId,
    String? employeeId,
    String? observations,
  }) {
    return ExpenseEdit(
      selected: selected ?? this.selected,
      concept: concept ?? this.concept,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      employeeId: employeeId ?? this.employeeId,
      observations: observations ?? this.observations,
    );
  }
}

class AttendanceEdit {
  const AttendanceEdit({
    required this.selected,
    required this.clockIn,
    this.employeeId,
    this.clockOut,
  });

  final bool selected;
  final String clockIn;
  final String? employeeId;
  final String? clockOut;

  bool get isComplete => employeeId != null && clockIn.isNotEmpty;

  AttendanceEdit copyWith({
    bool? selected,
    String? clockIn,
    String? employeeId,
    String? clockOut,
  }) {
    return AttendanceEdit(
      selected: selected ?? this.selected,
      clockIn: clockIn ?? this.clockIn,
      employeeId: employeeId ?? this.employeeId,
      clockOut: clockOut ?? this.clockOut,
    );
  }
}

/// El escaneo de la hoja «Registro Diario» (plan 0005 §1).
///
/// La diferencia de fondo con [ScanController] está en la última línea de este
/// archivo: aquel entrega un borrador y se acabó, y este **aplica**. De ahí que
/// todo lo de arriba exista — las filas editables, lo que está marcado, el total
/// que se va a cobrar — porque entre leer y cobrar tiene que haber una persona
/// mirando, y esto es lo que esa persona está mirando.
///
/// Qué llega marcado por omisión, que es la decisión con más consecuencias:
///
/// * los cobros, **solo** los que el servidor emparejó con una boleta que debe
///   justo lo que dice el papel. Un desajuste de monto, una boleta que no
///   aparece o una que ya está cobrada llegan desmarcadas: son las que hay que
///   mirar, y marcarlas sería esconderlas.
/// * los gastos, solo los que tienen categoría y monto. Sin categoría no se
///   puede archivar y la elige una persona.
/// * las horas, solo cuando el empleado se identificó sin ambigüedad.
@riverpod
class CashSheetController extends _$CashSheetController {
  @override
  CashSheetState build() => const CashSheetIdle();

  Future<Either<AppFailure, CashSheetResult>> send(Uint8List image) async {
    state = CashSheetSending(image);
    try {
      final result = await ref
          .read(scanRemoteDataSourceProvider)
          .scanCashSheet(image);
      if (result.days.isEmpty) {
        // El servidor contesta bien y sin un solo bloque cuando la foto no deja
        // leer la rejilla. No es un fallo de red y no se reintenta solo: hay que
        // tomar otra foto, y decirlo es más útil que una pantalla en blanco.
        const failure = ValidationFailure(
          'De esta foto no se sacó ningún día. Que se vea la hoja entera, con '
          'los renglones derechos y sin sombra encima.',
        );
        // La foto se conserva igual que en un fallo de red: quien acaba de
        // encuadrar una hoja no debería volver a hacerlo para reintentar.
        state = CashSheetFailed(image, failure);
        return const Left(failure);
      }
      state = _review(image, result);
      return Right(result);
    } catch (error) {
      final failure = AppFailure.fromException(error);
      state = CashSheetFailed(image, failure);
      return Left(failure);
    }
  }

  Future<Either<AppFailure, CashSheetResult>> retry() async {
    final image = switch (state) {
      CashSheetFailed(:final image) => image,
      CashSheetSending(:final image) => image,
      CashSheetReview(:final image) => image,
      _ => null,
    };
    if (image == null) {
      return const Left(ValidationFailure('No hay ninguna foto que reintentar'));
    }
    return send(image);
  }

  void reset() => state = const CashSheetIdle();

  /// Cambiar de bloque rehace las marcas: son de ese día y de ningún otro.
  void selectDay(int dayIndex) {
    if (state case final CashSheetReview review) {
      if (dayIndex == review.dayIndex ||
          dayIndex < 0 ||
          dayIndex >= review.result.days.length) {
        return;
      }
      state = _review(review.image, review.result, dayIndex: dayIndex);
    }
  }

  void updateIncome(int index, IncomeEdit edit) {
    if (state case final CashSheetReview review) {
      state = review.copyWith(
        incomes: {...review.incomes, index: edit},
        clearFailure: true,
      );
    }
  }

  void updateExpense(int index, ExpenseEdit edit) {
    if (state case final CashSheetReview review) {
      state = review.copyWith(
        expenses: {...review.expenses, index: edit},
        clearFailure: true,
      );
    }
  }

  void updateAttendance(int index, AttendanceEdit edit) {
    if (state case final CashSheetReview review) {
      state = review.copyWith(
        attendance: {...review.attendance, index: edit},
        clearFailure: true,
      );
    }
  }

  /// Marca o desmarca de golpe los cobros que se pueden cobrar.
  void toggleAllIncomes({required bool selected}) {
    if (state case final CashSheetReview review) {
      final incomes = {
        for (final entry in review.incomes.entries)
          entry.key: review.day.incomes
                  .firstWhere((row) => row.index == entry.key)
                  .status
                  .isCollectable
              ? entry.value.copyWith(selected: selected)
              : entry.value,
      };
      state = review.copyWith(incomes: incomes, clearFailure: true);
    }
  }

  /// Escribe lo marcado. La respuesta dice fila por fila qué pasó.
  Future<Either<AppFailure, CashSheetApplyResult>> apply() async {
    if (state case final CashSheetReview review) {
      final body = _body(review);
      if (body.isEmpty) {
        return const Left(ValidationFailure('No hay nada marcado para importar'));
      }

      state = review.copyWith(applying: true, clearFailure: true);
      try {
        final result = await ref
            .read(scanRemoteDataSourceProvider)
            .applyCashSheet(review.result.id, body);
        state = CashSheetApplied(result);
        return Right(result);
      } catch (error) {
        final failure = AppFailure.fromException(error);
        // Se vuelve a la revisión con todo lo marcado intacto: reintentar es
        // seguro —los ids de las filas los deriva el servidor del escaneo, así
        // que lo que ya entró se reconoce en vez de duplicarse— y volver a
        // marcar quince filas no lo sería.
        state = review.copyWith(applying: false, failure: failure);
        return Left(failure);
      }
    }
    return const Left(ValidationFailure('No hay ninguna hoja que importar'));
  }

  CashSheetApply _body(CashSheetReview review) {
    final day = review.day;
    return CashSheetApply(
      closeDate: day.closeDate.value ?? '',
      incomes: [
        for (final row in day.incomes)
          if (review.incomes[row.index] case final IncomeEdit edit)
            if (edit.selected && row.orderId != null && edit.amount > 0)
              CashIncomeApply(
                index: row.index,
                orderId: row.orderId!,
                amount: edit.amount,
                method: edit.method,
                deliver: edit.deliver && row.canDeliver,
              ),
      ],
      expenses: [
        for (final row in day.expenses)
          if (review.expenses[row.index] case final ExpenseEdit edit)
            if (edit.selected && edit.isComplete)
              CashExpenseApply(
                index: row.index,
                categoryId: edit.categoryId!,
                concept: edit.concept.trim(),
                amount: edit.amount,
                method: edit.method,
                status: edit.status,
                employeeId: edit.employeeId,
                observations: edit.observations,
              ),
      ],
      attendance: [
        for (final row in day.attendance)
          if (review.attendance[row.index] case final AttendanceEdit edit)
            if (edit.selected && edit.isComplete)
              CashAttendanceApply(
                index: row.index,
                employeeId: edit.employeeId!,
                clockIn: edit.clockIn,
                clockOut: edit.clockOut,
              ),
      ],
    );
  }

  /// El estado inicial de la revisión: las filas con lo que el servidor propuso.
  CashSheetReview _review(
    Uint8List image,
    CashSheetResult result, {
    int dayIndex = 0,
  }) {
    final day = result.days[dayIndex];
    return CashSheetReview(
      image: image,
      result: result,
      dayIndex: dayIndex,
      incomes: {
        for (final row in day.incomes)
          row.index: IncomeEdit(
            // Solo lo que cuadra llega marcado. Lo demás es justamente lo que
            // hay que mirar, y marcarlo lo escondería en la lista.
            selected: row.status == CashIncomeStatus.matched,
            amount: row.amountSuggested ?? 0,
            method: row.method,
            deliver: row.canDeliver,
          ),
      },
      expenses: {
        for (final row in day.expenses)
          row.index: ExpenseEdit(
            selected: row.status == CashExpenseStatus.matched,
            concept: row.concept.value ?? '',
            amount: row.amount.value ?? 0,
            method: row.method,
            status: row.expenseStatus,
            categoryId: row.categoryId,
            employeeId: row.employeeId,
            observations: row.observations.value,
          ),
      },
      attendance: {
        for (final row in day.attendance)
          row.index: AttendanceEdit(
            selected: row.isUsable,
            clockIn: row.clockIn.value ?? '',
            employeeId: row.employeeId,
            clockOut: row.clockOut.value,
          ),
      },
    );
  }
}
