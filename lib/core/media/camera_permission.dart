import 'package:permission_handler/permission_handler.dart';

/// Requests camera access before starting local video capture. Explicit,
/// up-front `permission_handler` request (rather than relying solely on
/// whatever implicit OS prompt `getUserMedia({'video': true})` triggers) -
/// `permission_handler` was already a dependency but previously unused.
Future<bool> ensureCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}
