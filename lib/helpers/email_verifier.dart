import 'dart:convert' show json;

import 'package:http/http.dart' as http;

class EmailVerifier {
  static final List<String> _apiKeys = [
    'api',
    'api2',
    'API_KEY_3',
  ]; // Cycles through these API keys since it has a limit of 100

  static int _currKeyIndex = 0;
  static int _numCalls = 0;


  static Future<String?> validate(String email) async {
    String apiKey = _apiKeys[_currKeyIndex];
    final url = Uri.parse(
'     https://api.zerobounce.net/v2/validate?api_key=$apiKey&email=$email'
    );

    try {
      final response = await http.get(url);

      _numCalls++;
      if (_numCalls >= 100) {
        _numCalls = 0;
        _currKeyIndex = (_currKeyIndex + 1) % _apiKeys.length;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];
        final isDisposable = data['disposable'];

        if (status == 'valid') {
          return null; 
        } else if (isDisposable) {
          return 'Disposable email addresses are not allowed.';
        } else {
          // Invalid email
          return 'Email address is not deliverable ($status).';
        }
        // Bad API key
      } else {
        return 'Error validating email (server error).';
      }
      // Network error
    } catch (e) {
      return 'Network error while validating email.';
    }
  }
}
