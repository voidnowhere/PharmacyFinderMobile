import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static Dio? _instance;

  static Dio getInstance() {
    if (_instance == null) {
      _instance = Dio();

      String baseUrl = dotenv.env['BASE_URL']!;
      _instance!.options.baseUrl = baseUrl;
      _instance!.options.connectTimeout = const Duration(seconds: 10);
      _instance!.options.headers['Content-Type'] = 'application/json';
      _instance!.options.headers['Accept'] = 'application/json';
    }
    return _instance ?? Dio();
  }
}
