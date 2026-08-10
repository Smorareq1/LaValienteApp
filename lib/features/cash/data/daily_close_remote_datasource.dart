import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../models/day_close.dart';

part 'daily_close_remote_datasource.g.dart';

/// I/O contra `/daily-close`. **En línea**, a diferencia de todo lo operativo.
///
/// Cerrar el día es online-only por decisión del plan 0005 (D11), y el porqué
/// no es técnico: el acta declara cuánto valió un día entero, y un dispositivo
/// sin señal solo conoce lo que pasó por sus manos. Cerrar con eso archivaría
/// una cifra que le falta lo que cobró la otra tableta.
///
/// Por eso aquí no hay outbox ni escritura optimista: sin red no se cierra y se
/// dice (plan 0006 §14).
class DailyCloseRemoteDataSource {
  const DailyCloseRemoteDataSource(this._dio);

  final Dio _dio;

  /// El día como está ahora. Sigue respondiendo después del cierre: detrás del
  /// candado las cifras no se pueden mover, así que ver que el preview y el acta
  /// dicen lo mismo es algo que se comprueba en vez de creerse.
  Future<DayClosePreview> preview(String date) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/daily-close/preview',
      queryParameters: {'date': date},
    );
    return DayClosePreview.fromJson(response.data!);
  }

  /// Las actas del rango, **reabiertas incluidas**: ese es el rastro (D9).
  Future<List<DayClosureRecord>> history({required String from, required String to}) async {
    final response = await _dio.get<List<dynamic>>(
      '/daily-close',
      queryParameters: {'from': from, 'to': to},
    );
    return [
      for (final item in response.data ?? const [])
        DayClosureRecord.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Archiva el día y bloquea la fecha.
  Future<DayClosureRecord> close({required String date, String? notes}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/daily-close',
      data: {'close_date': date, 'notes': notes},
    );
    return DayClosureRecord.fromJson(response.data!);
  }

  /// Levanta el candado, dejando quién lo levantó y por qué.
  Future<DayClosureRecord> reopen({required String id, required String reason}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/daily-close/$id/reopen',
      data: {'reason': reason},
    );
    return DayClosureRecord.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
DailyCloseRemoteDataSource dailyCloseRemoteDataSource(Ref ref) {
  return DailyCloseRemoteDataSource(ref.watch(apiClientProvider));
}
