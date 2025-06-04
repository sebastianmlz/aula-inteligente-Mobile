import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/participation_model.dart';
import '../utils/logger_util.dart';

class ParticipationService {
  final _storage = const FlutterSecureStorage();
  final _logger = LoggerUtil.instance;

  // Método para obtener el token de autenticación
  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Método para obtener participaciones del estudiante (paginadas)
  Future<PaginatedParticipations> getParticipations({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
    int? courseId,
    int? subjectId,
    int? studentId,
    int? periodId,
    String? level,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      // Construir la URL con parámetros de query
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      // Añadir parámetros opcionales
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }
      if (courseId != null) {
        queryParams['course'] = courseId.toString();
      }
      if (subjectId != null) {
        queryParams['subject'] = subjectId.toString();
      }
      if (studentId != null) {
        queryParams['student'] = studentId.toString();
      }
      if (periodId != null) {
        queryParams['period'] = periodId.toString();
      }
      if (level != null && level.isNotEmpty) {
        queryParams['level'] = level;
      }
      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }

      // Usar la URL base correcta
      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}${ApiEndpoints.participations}',
      ).replace(queryParameters: queryParams);

      _logger.i('Obteniendo participaciones: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _logger.i(
          'Datos recibidos: ${data['items']?.length} participaciones de ${data['total']}',
        );
        return PaginatedParticipations.fromJson(data);
      } else {
        _logger.e(
          'Error al obtener participaciones: ${response.statusCode}',
          error: response.body,
        );
        throw Exception(
          'Error al obtener participaciones: ${response.statusCode}',
        );
      }
    } catch (e) {
      _logger.e(
        'Error al obtener participaciones',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }
}
