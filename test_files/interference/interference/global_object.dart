class GlobalObject {
  GlobalObject._internal();

  static final GlobalObject _instance = GlobalObject._internal();
  bool changed = false;

  static GlobalObject get instance => _instance;
}
