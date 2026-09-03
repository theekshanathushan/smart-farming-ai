import 'package:permission_handler/permission_handler.dart';

Future<bool> checkAndRequestCameraPermission() async {
  PermissionStatus status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  }

  if (status.isDenied) {
    status = await Permission.camera.request();
    return status.isGranted;
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }
  
  return false;
}
