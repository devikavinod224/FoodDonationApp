import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  static Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }
    
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    // For Android 13+, use photos permission, for older use storage
    var status = await Permission.photos.status;
    if (status.isDenied) {
        status = await Permission.photos.request();
    }
    
    if (status.isRestricted || status.isDenied) {
        // Fallback for older Android
        status = await Permission.storage.request();
    }
    
    return status.isGranted;
  }

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }
}
