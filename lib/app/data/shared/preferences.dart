/*
  Recordar instalar el paquete de:
    shared_preferences:

  Inicializar en el main
    final prefs = new Preferences();
    await prefs.initPrefs();
    
    Recuerden que el main() debe de ser async {...

*/
// import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/enums/predefined_addresses.dart';
// import '../models/location_address_model.dart';

class Preferences {
  static String get shphomelocationaddress => "HOME_LOCATION_ADDRESS";
  static String get shpworklocationaddress => "WORK_LOCATION_ADDRESS";
  static final Preferences _instancia = Preferences._internal();

  factory Preferences() {
    return _instancia;
  }

  Preferences._internal();

  SharedPreferences? _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  clear() async {
    var aux = skipSplash;
    _prefs?.clear();
    skipSplash = aux;
  }

  bool get skipSplash {
    return _prefs?.getBool('skipSplash') ?? false;
  }

  set skipSplash(bool value) {
    _prefs?.setBool('skipSplash', value);
  }

  String get lastLogin {
    return _prefs?.getString('lastLogin') ?? '';
  }

  set lastLogin(String value) {
    _prefs?.setString('lastLogin', value);
  }

  String get token {
    return _prefs?.getString('token') ?? '';
  }

  set token(String value) {
    _prefs?.setString('token', value);
  }

  String get expire {
    return _prefs?.getString('expire') ?? '';
  }

  set expire(String value) {
    _prefs?.setString('expire', value);
  }

  int get userID {
    return _prefs?.getInt('userID') ?? -1;
  }

  set userID(int value) {
    _prefs?.setInt('userID', value);
  }

  String get username {
    return _prefs?.getString('username') ?? '';
  }

  set username(String value) {
    _prefs?.setString('username', value);
  }

  String get pass {
    return _prefs?.getString('pass') ?? '';
  }

  set pass(String value) {
    _prefs?.setString('pass', value);
  }

  int get storeID {
    return _prefs?.getInt('storeID') ?? -1;
  }

  set storeID(int value) {
    _prefs?.setInt('storeID', value);
  }

  String get typeUser {
    return _prefs?.getString('typeUser') ?? '';
  }

  set typeUser(String value) {
    _prefs?.setString('typeUser', value);
  }

  bool get isNotification {
    return _prefs?.getBool('isNotification') ?? false;
  }

  set isNotification(bool value) {
    _prefs?.setBool('isNotification', value);
  }

  String get tokenFCM {
    return _prefs?.getString('tokenFCM') ?? '';
  }

  set tokenFCM(String value) {
    _prefs?.setString('tokenFCM', value);
  }

  String get userState {
    return _prefs?.getString('userState') ?? '{}';
  }

  set userState(String value) {
    _prefs?.setString('userState', value);
  }

  // Future<void> setPredefinedLocationAddress(LocationAddress locationAddress,
  //     PredefinedAddresses predefinedAddresses) async {
  //   String strUser = jsonEncode(locationAddress);
  //   String key = predefinedAddresses == PredefinedAddresses.home
  //       ? shphomelocationaddress
  //       : shpworklocationaddress;
  //   _prefs?.setString(key, strUser);
  // }

  // Future<LocationAddress?> getPredefinedLocationAddress(
  //     PredefinedAddresses predefinedAddresses) async {
  //   String key = predefinedAddresses == PredefinedAddresses.home
  //       ? shphomelocationaddress
  //       : shpworklocationaddress;
  //   String? strData = _prefs?.getString(key);
  //   if (strData != null) {
  //     return LocationAddress.fromJson(jsonDecode(strData));
  //   }
  //   return LocationAddress(address: '', position: null);
  // }

  // Future<void> deletePredefinedLocationAddress(
  //     PredefinedAddresses predefinedAddresses) async {
  //   String key = predefinedAddresses == PredefinedAddresses.home
  //       ? shphomelocationaddress
  //       : shpworklocationaddress;
  //   _prefs?.remove(key);
  // }
}
