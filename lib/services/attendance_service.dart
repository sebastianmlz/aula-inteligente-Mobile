import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/attendance_model.dart';
import '../utils/logger_util.dart';

class AttendanceService {
  final _storage = const FlutterSecureStorage();
  final _logger = LoggerUtil.instance;

  // Método para obtener el token de autenticación
  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Método para obtener registros de asistencia con diversos filtros
  Future<PaginatedAttendance> getAttendanceRecords({
    int page = 1,
    int pageSize = 10,
    int? courseId,
    int? subjectId,
    int? periodId,
    int? userId,
    String? fromDate,
    String? toDate,
    String? status,
    String? ordering,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      // Construir los parámetros de query
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      // Añadir filtros opcionales
      if (courseId != null) {
        queryParams['course'] = courseId.toString();
      }
      if (subjectId != null) {
        queryParams['subject'] = subjectId.toString();
      }
      if (periodId != null) {
        queryParams['period'] = periodId.toString();
      }
      if (userId != null) {
        queryParams['student'] = userId.toString();
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }

      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}${ApiEndpoints.attendances}',
      ).replace(queryParameters: queryParams);

      _logger.i('Obteniendo registros de asistencia: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginatedAttendance.fromJson(data);
      } else {
        _logger.e(
          'Error al obtener registros de asistencia: ${response.statusCode}',
          error: response.body,
        );
        throw Exception(
          'Error al obtener registros de asistencia: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e(
        'Error al obtener registros de asistencia',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }
}
