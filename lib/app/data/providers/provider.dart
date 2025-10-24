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
      'Authorization': 'Bearer ${_preferences.token}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dataHeader;
  }

  Future<Map<String, dynamic>> getStores() async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/Store',
      ).replace(queryParameters: {'withDeleted': 'false'});
      final resp = await http.get(uri, headers: getHeaderJson());
      var stores = <StoreDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data as List)
            .map((store) => stores.add(StoreDTO.fromJson(store)))
            .toList();
        return {'ok': true, 'data': stores};
      } else if (resp.statusCode == 404) {
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

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required int storeID,
  }) async {
    try {
      final uri = Uri.parse('${dotenv.env['API_URL']}/Auth/AuthenticateUser')
          .replace(
            queryParameters: {
              "login": username,
              "password": password,
              "storeID": storeID.toString(),
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

  Future<Map<String, dynamic>> getUsers() async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/User',
      ).replace(queryParameters: {'withDeleted': 'false'});

      final resp = await http.get(uri, headers: getHeaderJson());
      var users = <UserDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data as List)
            .map((user) => users.add(UserDTO.fromJson(user)))
            .toList();
        return {'ok': true, 'data': users};
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': users};
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getMessages(Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/EmailSMS/ChatMessage/Search',
      );

      final resp = await http.put(
        uri,
        headers: getHeaderJson(),
        body: jsonEncode(body),
      );
      var messages = <MessageDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data as List)
            .map((message) => messages.add(MessageDTO.fromJson(message)))
            .toList();
        return {'ok': true, 'data': messages};
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': messages};
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required MessageDTO message,
  }) async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/EmailSMS/ChatMessage/Insert',
      );

      final resp = await http.post(
        uri,
        headers: getHeaderJson(),
        body: jsonEncode(message),
      );
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        var message = MessageDTO.fromJson(data);
        return {'ok': true, 'data': message};
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> setMessageMarkAsRead({
    required int messageID,
  }) async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/EmailSMS/ChatMessage/MarkAsRead/$messageID',
      );

      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return {'ok': true};
      } else if (resp.statusCode == 404) {
        return {
          'ok': false,
          'data': 'Mensagem com ID:$messageID não encontrada',
        };
      } else {
        return {'ok': false, 'message': resp.body};
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getAppts(Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse(
        '${dotenv.env['API_URL']}/Appointment/SearchAppointments',
      );

      final resp = await http.put(
        uri,
        headers: getHeaderJson(),
        body: jsonEncode(body),
      );

      var appts = <AppointmentDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data['Appointments'] as List)
            .map((appt) => appts.add(AppointmentDTO.fromJson(appt)))
            .toList();
        return {'ok': true, 'data': appts};
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': appts};
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
