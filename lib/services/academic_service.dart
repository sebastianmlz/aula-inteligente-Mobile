import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/subject_model.dart';
import '../models/course_model.dart';
import '../utils/logger_util.dart';

class AcademicService {
  final _storage = const FlutterSecureStorage();
  final _logger = LoggerUtil.instance;

  // Método para obtener el token de autenticación
  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Método para obtener las materias del estudiante (paginadas)
  Future<PaginatedSubjects> getSubjects({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
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

      // Usar la URL base correcta
      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}${ApiEndpoints.subjects}',
      ).replace(queryParameters: queryParams);

      _logger.i('Obteniendo materias: $uri');

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
          'Datos recibidos: ${data['items']?.length} materias de ${data['total']}',
        );
        return PaginatedSubjects.fromJson(data);
      } else {
        _logger.e(
          'Error al obtener materias: ${response.statusCode}',
          error: response.body,
        );
        throw Exception('Error al obtener materias: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e(
        'Error al obtener materias',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // Método para obtener los cursos del estudiante (paginados)
  Future<PaginatedCourses> getCourses({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
    int? year,
    bool? active,
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
      if (year != null) {
        queryParams['year'] = year.toString();
      }
      if (active != null) {
        queryParams['active'] = active.toString();
      }

      final uri = Uri.parse(
        '${EnvConfig.apiBaseUrl}${ApiEndpoints.courses}',
      ).replace(queryParameters: queryParams);

      _logger.i('Obteniendo cursos: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaginatedCourses.fromJson(data);
      } else {
        _logger.e(
          'Error al obtener cursos: ${response.statusCode}',
          error: response.body,
        );
        throw Exception('Error al obtener cursos: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e(
        'Error al obtener cursos',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }
}
