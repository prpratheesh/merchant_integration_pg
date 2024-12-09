import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  Future<http.Response> sendPostRequest(String url, String payload) async {
    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // Ensure the header matches Postman
        },
        body: payload, // Send the raw JSON string as the body
      );
      // Log the response details
      print('Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      throw Exception('Error sending request: $e');
    }
  }
}
