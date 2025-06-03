import 'dart:convert' show json;
import 'package:http/http.dart' as http;

class EmailVerifier {
  static final List<String> _apiKeys = [
    '40741c25a6544b8695eae23a89203c5c',
    '97930f6809874ab39aca1121108ae19e',
    '7602fc665db44df7a9c5ec87a3094888',
  ]; 


  static int _currKeyIndex = 0;
  static int _numCalls = 0;

  static Future<String?> validate(String email) async {
    String apiKey = _apiKeys[_currKeyIndex];
    final url = Uri.parse('https://api.zerobounce.net/v2/validate?api_key=$apiKey&email=$email');

    try {
      final response = await http.get(url);

      _numCalls++;
      if (_numCalls >= 100) {
        _numCalls = 0;
        _currKeyIndex = (_currKeyIndex + 1) % _apiKeys.length;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] != null) {
          return 'API error: ${data['error']}';
        }

        final status = data['status'];
        final isDisposable = data['disposable'] == 'true';

        if (status == 'valid') {
          return null; // success
        } else if (isDisposable) {
          return 'Disposable email addresses are not allowed.';
        } else {
          return 'Email address is not deliverable ($status).';
        }
      } else {
        return 'Error validating email (status code ${response.statusCode}).';
      }
    } catch (e) {
      return 'Network error while validating email.';
    }
  }
}
