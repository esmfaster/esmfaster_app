class Config {

  String appName = 'WooCommerce';
  String androidPackageName = 'com.mstoreapp.wooapp';
  String iosPackageName = 'com.mstoreapp.app';

  String mapApiKey = 'AIzaRyBQu4D8dd3AXuNjJIk31n44B6RfWRrqn0Q';

  String url = 'https://example.com';
  String consumerKey = 'ck_09c3ed340641888f643ec275345276bf8b4c14';
  String consumerSecret = 'cs_a263c945c6993e7ae6fbsafd23bd7dedf9d85ca83b1';

  static Config _singleton = new Config._internal();

  factory Config() {
    return _singleton;
  }

  Config._internal();

  Map<String, dynamic> appConfig = Map<String, dynamic>();

  Config loadFromMap(Map<String, dynamic> map) {
    appConfig.addAll(map);
    return _singleton;
  }

  dynamic get(String key) => appConfig[key];

  bool getBool(String key) => appConfig[key];

  int getInt(String key) => appConfig[key];

  double getDouble(String key) => appConfig[key];

  String getString(String key) => appConfig[key];

  void clear() => appConfig.clear();

  @Deprecated("use updateValue instead")
  void setValue(key, value) => value.runtimeType != appConfig[key].runtimeType
      ? throw ("wrong type")
      : appConfig.update(key, (dynamic) => value);

  void updateValue(String key, dynamic value) {
    if (appConfig[key] != null &&
        value.runtimeType != appConfig[key].runtimeType) {
      throw ("The persistent type of ${appConfig[key].runtimeType} does not match the given type ${value.runtimeType}");
    }
    appConfig.update(key, (dynamic) => value);
  }

  void addValue(String key, dynamic value) =>
      appConfig.putIfAbsent(key, () => value);

  add(Map<String, dynamic> map) => appConfig.addAll(map);

}