import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiUtil {
  // Método para extraer mensajes de error de las respuestas HTTP
  static String getErrorMessageFromResponse(http.Response response) {
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      if (body.containsKey('detail')) {
        return body['detail'];
      } else if (body.containsKey('message')) {
        return body['message'];
      } else {
        return 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }
  }
}
