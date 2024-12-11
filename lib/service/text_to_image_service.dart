import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:illustra_ai/service/exception/text_to_image_exception.dart';

class TextToImageService {
  final String apiUrl;
  final String apiKey;

  TextToImageService({
    required this.apiUrl,
    required this.apiKey,
  });

  Future<Uint8List> generateImage(String prompt) async {
    if (prompt.isEmpty || prompt.trim().isEmpty) {
      throw TextToImageException(
          'The prompt cannot be null or empty. Please provide a valid input.');
    }

    try {
      // Set up headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      // Request payload
      final body = jsonEncode({'inputs': prompt});

      // Make API call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.bodyBytes);
      } else if (response.statusCode == 403) {
        throw TextToImageException(
            'Invalid API key. Please check your credentials.');
      } else if (response.statusCode == 429) {
        throw TextToImageException(
            'Rate limit exceeded. Please try again later.');
      } else {
        throw TextToImageException(
            'There was an issue with the request. Please try again later.');
      }
    } on http.ClientException {
      // Handle network connectivity issues
      throw TextToImageException(
          'Network error: Unable to access the service. Please check your connection.');
    } catch (e) {
      // Catch any other unexpected exceptions
      throw TextToImageException(
          'An unexpected error occurred: ${e.toString()}');
    }
  }
}
