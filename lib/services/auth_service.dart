import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://dummyjson.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json",
    },
  ));

  AuthService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await getToken();

        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          print("Unauthorized! Redirect to login.");
        }
        return handler.next(e);
      },
    ));
  }


  /// Saves JWT Token to local storage
  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  /// Login API Call
  Future<String?> login(String username, String password) async {
    try {
      Response response = await _dio.post('/auth/login', data: {
        "username": username,
        "password": password,
      });

      if (response.statusCode == 200) {
        String token = response.data['accessToken'];
        await _saveToken(token);
        return token;
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
    return null;
  }

  /// Registration API Call
  Future<String?> register(String name, String username, String password) async {
    try {
      Response response = await _dio.post('/auth/register', data: {
        "name": name,
        "username": username,
        "password": password,
      });

      if (response.statusCode == 201) {
        String token = response.data['token'];
        await _saveToken(token);
        return token;
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    }
    return null;
  }

  /// Logout: Clear JWT Token
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  /// Get Saved Token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  /// Handle Dio Errors
  String _handleDioError(DioException e) {
    if (e.response != null) {
      return e.response!.data['message'] ?? 'Something went wrong!';
    } else {
      return 'Network error! Check your internet connection.';
    }
  }
}
