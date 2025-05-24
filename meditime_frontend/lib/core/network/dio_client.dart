import 'package:dio/dio.dart';
import 'package:meditime_frontend/core/constants/api_endpoints.dart';
import 'package:meditime_frontend/services/local_storage_service.dart';

/// Gère les appels HTTP via Dio configuré.
/// Spécialement utilisé pour l’authentification (connexion, inscription).
class DioClient {
  // Singleton : une seule instance réutilisable
  static final DioClient _instance = DioClient._internal();

  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: ApiConstants.defaultHeaders,
        responseType: ResponseType.json,
      ),
    );

    // Ajoute un interceptor pour injecter le token JWT
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Ajoute un interceptor de log (optionnel mais utile en dev)
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  /// Effectue une requête POST générique
  Future<Response> post(String route, {dynamic data}) async {
    try {
      final response = await dio.post(route, data: data);
      return response;
    } on DioException catch (e) {
      // Gestion propre des erreurs Dio
      return Future.error(_handleDioError(e));
    }
  }

  /// Gestion propre des erreurs
  String _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Temps de connexion dépassé.";
    } else if (error.response != null) {
      return error.response?.data["message"] ?? "Erreur inconnue.";
    } else {
      return "Erreur réseau : ${error.message}";
    }
  }
}