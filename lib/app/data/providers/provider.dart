import 'dart:convert';
import 'dart:io';
import 'package:biogest_clinic_movile/app/data/models/index.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../shared/preferences.dart';

class Provider {
  final Preferences _preferences = Preferences();
  final logger = Logger();

  Map<String, String> getHeaderJson() {
    Map<String, String> dataHeader = {
      'Content-Type': '	application/json; charset=utf-8',
    };
    return dataHeader;
  }

  Future<Map<String, dynamic>> getStores() async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/Store',
      ).replace(queryParameters: {'withDeleted': 'false'});

      logger.i('GET $uri');
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        var stores = <StoreDTO>[];
        (data as List)
            .map((store) => stores.add(StoreDTO.fromJson(store)))
            .toList();
        return {'ok': true, 'data': stores};
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> login(
    String username,
    String password,
    int storeID,
  ) async {
    try {
      final uri = Uri.parse('${dotenv.env['API_URL']}/Auth/AuthenticateUser')
          .replace(
            queryParameters: {
              "login": username,
              "password": password,
              "storeID": password,
            },
          );

      final result = await http.post(uri, headers: getHeaderJson());

      if (result.statusCode == 401) {
        return {
          'ok': false,
          'message': 'Utilizador ou palavra-passe incorreto',
        };
      }

      final data = json.decode(result.body);
      if (result.statusCode >= 200 && result.statusCode <= 299) {
        var auth = AuthResponseDTO.fromJson(data);

        _preferences.token = auth.accessToken;
        _preferences.expire = auth.accessTokenExpireDate;
        _preferences.userID = auth.userInfo.id;
        _preferences.username = username;
        _preferences.pass = password;
        _preferences.storeID = storeID;

        return {'ok': true, 'data': auth};
      } else {
        return {'ok': false, 'message': data['message']};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      var resp = e.toString();
      if ((e as String).contains('html')) {
        resp = 'Error: de respuesta del servidor';
      }
      return {'ok': false, 'message': resp};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/Auth/Logout',
      ).replace(queryParameters: {'userID': _preferences.userID.toString()});

      final resp = await http.post(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return {'ok': true};
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }
}
