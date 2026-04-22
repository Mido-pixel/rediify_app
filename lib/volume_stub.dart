class VolumeController {
  static final VolumeController _instance = VolumeController._internal();
  factory VolumeController() => _instance;
  VolumeController._internal();

  // ignore: avoid_setters_without_getters
  set showSystemUI(bool value) {}

  void listener(void Function(double) callback) {}
  Future<double> getVolume() async => 0.5;
  void setVolume(double volume) {}
  void removeListener() {}
}