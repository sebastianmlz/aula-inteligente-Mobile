import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/grade_model.dart';
import '../utils/logger_util.dart';
import '../utils/api_util.dart';

class GradeService {
  final http.Client client;

  GradeService({http.Client? client}) : client = client ?? http.Client();

  Future<PaginatedGrades> fetchGrades({
    String? token,
    int? student,
    int? subject,
    int? period,
    String? assessmentType,
    int? assessmentItem,
    int? assessmentItemTrimester,
    int? assessmentItemTrimesterPeriod,
    double? value,
    double? valueGte,
    double? valueLte,
    String? search,
    int pageSize = 10,
    int page = 1,
    String? ordering,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };

      if (student != null) {
        queryParams['student'] = student.toString();
      }
      if (subject != null) {
        queryParams['subject'] = subject.toString();
      }
      if (period != null) {
        queryParams['period'] = period.toString();
      }
      if (assessmentType != null) {
        queryParams['assessment_type'] = assessmentType;
      }
      if (assessmentItemTrimester != null) {
        queryParams['assessment_item__trimester'] =
            assessmentItemTrimester.toString();
      }
      if (assessmentItemTrimesterPeriod != null) {
        queryParams['assessment_item__trimester__period'] =
            assessmentItemTrimesterPeriod.toString();
      }
      if (valueGte != null) {
        queryParams['value__gte'] = valueGte.toString();
      }
      if (valueLte != null) {
        queryParams['value__lte'] = valueLte.toString();
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (ordering != null) {
        queryParams['ordering'] = ordering;
      }

      // Registra todos los parámetros de la solicitud
      LoggerUtil.instance.i('Parámetros de consulta para grades: $queryParams');

      final String url = '${EnvConfig.apiBaseUrl}${ApiEndpoints.grades}';
      LoggerUtil.instance.i('Fetching grades from $url');

      final response = await client.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      LoggerUtil.instance.i('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        LoggerUtil.instance.i('Response data: $data');
        return PaginatedGrades.fromJson(data);
      } else {
        LoggerUtil.instance.e('Error response: ${response.body}');
        throw Exception(
          'Error al obtener calificaciones: Error ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      LoggerUtil.instance.e('Error en fetchGrades: $e');
      throw Exception('Error al obtener calificaciones: $e');
    }
  }
}
