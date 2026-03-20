import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://fooddonationbackend.onrender.com';
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Auth
  Future<Response> login(String email, String password) async {
    return _dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<Response> signup(Map<String, dynamic> userData) async {
    return _dio.post('/auth/register', data: userData);
  }

  // Foods
  Future<Response> getFoods({String? category}) async {
    return _dio.get('/foods', queryParameters: category != null ? {'category': category} : null);
  }

  Future<Response> getMyFoods() async {
    return _dio.get('/foods/my');
  }

  Future<Response> addFood(Map<String, dynamic> foodData) async {
    return _dio.post('/foods', data: foodData);
  }

  Future<Response> updateFood(String id, Map<String, dynamic> foodData) async {
    return _dio.put('/foods/$id', data: foodData);
  }

  Future<Response> deleteFood(String id) async {
    return _dio.delete('/foods/$id');
  }

  // Shops
  Future<Response> getNearbyShops(double lat, double lng, {int radius = 5000}) async {
    return _dio.get('/shops/nearby', queryParameters: {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    });
  }

  Future<Response> getMyShop() async {
    return _dio.get('/shops/my');
  }

  Future<Response> updateShop(Map<String, dynamic> shopData) async {
    return _dio.post('/shops', data: shopData);
  }

  // Requests
  Future<Response> createRequest(String foodId, int requestedQty) async {
    return _dio.post('/requests', data: {
      'foodId': foodId,
      'requestedQty': requestedQty,
    });
  }

  Future<Response> getReceiverRequests() async {
    return _dio.get('/requests/receiver');
  }

  Future<Response> getShopkeeperRequests() async {
    return _dio.get('/requests/shopkeeper');
  }

  Future<Response> updateRequestStatus(String id, String status) async {
    return _dio.post('/requests/$id/$status');
  }

  // Upload
  Future<Response> uploadImage(String filePath) async {
    String fileName = filePath.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
    });
    return _dio.post("/upload", data: formData);
  }
}
