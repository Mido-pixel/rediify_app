// volume_service.dart
import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';

class VolumeService {
  static void init(void Function(double) listener) {
    if (kIsWeb) return;
    VolumeController().showSystemUI = false;
    VolumeController().listener(listener);
    VolumeController().getVolume().then(listener);
  }

  static void setVolume(double v) {
    if (kIsWeb) return;
    VolumeController().setVolume(v);
  }

  static void dispose() {
    if (kIsWeb) return;
    VolumeController().removeListener();
  }
}