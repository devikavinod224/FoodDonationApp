import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food.dart';
import '../models/food_request.dart';
import '../models/profile_details.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'package:geolocator/geolocator.dart';

class AppProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final SocketService _socket = SocketService();
  
  List<Food> _foods = [];
  List<FoodRequest> _requests = [];
  
  ShopkeeperProfile? _shopkeeperProfile;
  ReceiverProfile? _receiverProfile;
  ShopDetails? _shopDetails;
  List<ShopDetails> _nearbyShops = [];
  
  bool _isLoading = false;

  AppProvider() {
    // Initial data will be fetched after login/role selection
  }

  List<Food> get foods => _foods;
  List<FoodRequest> get requests => _requests;
  ShopkeeperProfile? get shopkeeperProfile => _shopkeeperProfile;
  ReceiverProfile? get receiverProfile => _receiverProfile;
  ShopDetails? get shopDetails => _shopDetails;
  List<ShopDetails> get nearbyShops => _nearbyShops;
  bool get isLoading => _isLoading;

  List<String> getCategories({String? shopId}) {
    if (shopId != null) {
      return _foods.where((f) => f.shopId == shopId).map((f) => f.category).toSet().toList();
    }
    return _foods.map((f) => f.category).toSet().toList();
  }


  // API Methods
  Future<void> fetchFoods({String? category}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.getFoods(category: category);
      if (response.data['success']) {
        final List data = response.data['data'];
        _foods = data.map((json) => Food.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch Foods Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchShopkeeperData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final shopRes = await _api.getMyShop();
      if (shopRes.data['success']) {
        _shopDetails = ShopDetails.fromJson(shopRes.data['data']);
      }
      
      final reqRes = await _api.getShopkeeperRequests();
      if (reqRes.data['success']) {
        final List data = reqRes.data['data'];
        _requests = data.map((json) => FoodRequest.fromJson(json)).toList();
      }

      await fetchFoods(); // Fetch my shop's food
    } catch (e) {
      print('Fetch Shopkeeper Data Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceiverData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final reqRes = await _api.getReceiverRequests();
      if (reqRes.data['success']) {
        final List data = reqRes.data['data'];
        _requests = data.map((json) => FoodRequest.fromJson(json)).toList();
      }
      await fetchFoods(); // Fetch nearby/all food
      
      // Try to get real location, fall back to default if denied
      Position? position;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        print('Location fetch error: $e');
      }

      final lat = position?.latitude ?? 12.9716;
      final lng = position?.longitude ?? 77.5946;
      await fetchNearbyShops(lat, lng);
    } catch (e) {
      print('Fetch Receiver Data Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Socket Integration
  void initSocket(String userId) {
    _socket.connect(userId);
    _socket.onEvent((event, data) {
      if (event == 'newRequest') {
        _requests.insert(0, FoodRequest.fromJson(data['request']));
        notifyListeners();
      } else if (event == 'requestUpdate') {
        final index = _requests.indexWhere((r) => r.id == data['requestId']);
        if (index != -1) {
          _requests[index] = _requests[index].copyWith(
            status: data['status'] == 'accepted' ? RequestStatus.accepted : RequestStatus.rejected
          );
          notifyListeners();
        }
      }
    });
  }

  void disposeSocket() {
    _socket.disconnect();
  }

  Future<void> fetchNearbyShops(double lat, double lng) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.getNearbyShops(lat, lng);
      if (res.data['success']) {
        final List data = res.data['data'];
        _nearbyShops = data.map((json) => ShopDetails.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch Nearby Shops Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CRUD Actions via API
  Future<bool> createFood(Map<String, dynamic> foodData) async {
    try {
      final res = await _api.addFood(foodData);
      if (res.data['success']) {
        _foods.insert(0, Food.fromJson(res.data['data']));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Create Food Error: $e');
    }
    return false;
  }

  Future<bool> updateFood(String id, Map<String, dynamic> foodData) async {
    try {
      final res = await _api.updateFood(id, foodData);
      if (res.data['success']) {
        final index = _foods.indexWhere((f) => f.id == id);
        if (index != -1) {
          _foods[index] = Food.fromJson(res.data['data']);
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('Update Food Error: $e');
    }
    return false;
  }

  Future<bool> deleteFood(String id) async {
    try {
      final res = await _api.deleteFood(id);
      if (res.data['success']) {
        _foods.removeWhere((f) => f.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Delete Food Error: $e');
    }
    return false;
  }

  Future<bool> sendRequest(String foodId, int qty) async {
    try {
      final res = await _api.createRequest(foodId, qty);
      if (res.data['success']) {
        _requests.insert(0, FoodRequest.fromJson(res.data['data']));
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Send Request Error: $e');
    }
    return false;
  }

  Future<void> updateRequestStatus(String id, RequestStatus status) async {
    try {
      final statusStr = status == RequestStatus.accepted ? 'accept' : 'reject';
      final res = await _api.updateRequestStatus(id, statusStr);
      if (res.data['success']) {
        final index = _requests.indexWhere((r) => r.id == id);
        if (index != -1) {
          _requests[index] = _requests[index].copyWith(status: status);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Update Request Error: $e');
    }
  }

  Future<String?> uploadImage(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.uploadImage(filePath);
      if (res.data['success']) {
        return res.data['data']['url'];
      }
    } catch (e) {
      print('Upload Image Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> updateShopDetails(ShopDetails details) async {
    try {
      Position? position;
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          position = await Geolocator.getCurrentPosition();
        }
      } catch (e) {
        print('Shop location fetch error: $e');
      }

      final lat = position?.latitude ?? 12.9716;
      final lng = position?.longitude ?? 77.5946;

      final res = await _api.updateShop({
        'name': details.shopName,
        'description': details.aboutShop,
        'location': {
          'address': details.shopLocation,
          'type': 'Point',
          'coordinates': [lng, lat] // [lng, lat] for GeoJSON
        },
        'imageUrl': details.shopImageUrl,
      });
      if (res.data['success']) {
        _shopDetails = ShopDetails.fromJson(res.data['data']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Update Shop Error: $e');
    }
    return false;
  }

  // Auth helper
  Future<bool> signup(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.signup(userData);
      if (res.data['success']) {
        final token = res.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', userData['role']);
        
        await fetchData(); // Fetch initial data
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Signup Error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role == 'shopkeeper') {
      await fetchShopkeeperData();
    } else if (role == 'receiver') {
      await fetchReceiverData();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await _api.login(email, password);
      if (res.data['success']) {
        final data = res.data['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        
        if (data['role'] == 'shopkeeper') {
          _shopkeeperProfile = ShopkeeperProfile.fromJson(data['user']);
          initSocket(_shopkeeperProfile!.id);
          await fetchShopkeeperData();
        } else {
          _receiverProfile = ReceiverProfile.fromJson(data['user']);
          initSocket(_receiverProfile!.id);
          await fetchReceiverData();
        }
        return true;
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return false;
  }

  Future<String?> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final role = prefs.getString('user_role');
      if (role != null) {
        await fetchData();
        return role;
      }
    } catch (e) {
      print('Auto Login Error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    _shopkeeperProfile = null;
    _receiverProfile = null;
    _shopDetails = null;
    _foods = [];
    _requests = [];
    disposeSocket();
    notifyListeners();
  }
}
