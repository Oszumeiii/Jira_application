import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectService {
  static const String baseUrl = 'http://localhost:8080/api/projects'; 

  static Future<Map<String, dynamic>> addProject({
    required String name,
    required String ownerId,
    String description = "",
    List<String> members = const [],
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': description,
        'ownerId': ownerId,
        'members': members,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Lỗi khi tạo project: ${response.body}');
    }
  }
}
