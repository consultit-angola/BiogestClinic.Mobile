import 'dart:convert';
import 'dart:io';
import 'package:biogest_clinic_mobile/app/data/models/index.dart';
import 'package:http/http.dart' as http;
import '../shared/preferences.dart';
import '../shared/api_config.dart';

class Provider {
  final Preferences _preferences = Preferences();

  String get _baseApiUrl => ApiConfig.activeApiUrl;

  Map<String, String> getHeaderJson() {
    Map<String, String> dataHeader = {
      'Authorization': 'Bearer ${_preferences.token}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    return dataHeader;
  }

  Map<String, dynamic> _httpError(http.Response response) {
    return {
      'ok': false,
      'statusCode': response.statusCode,
      'sessionExpired': response.statusCode == 401,
      'message': response.body,
    };
  }

  Map<String, dynamic> _connectionError() {
    return {
      'ok': false,
      'connectionError': true,
      'message': 'Error de conexión',
    };
  }

  Future<Map<String, dynamic>> _getCalendarFilterOptions(
    String path, {
    Map<String, String>? queryParameters,
    bool Function(Map<String, dynamic> item)? itemFilter,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseApiUrl/$path',
      ).replace(queryParameters: queryParameters);
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body) as List;
        final options = data
            .cast<Map<String, dynamic>>()
            .where((item) => itemFilter?.call(item) ?? true)
            .map((item) => CalendarFilterOptionDTO.fromJson(item))
            .where((option) => option.id > 0 && option.name.isNotEmpty)
            .toList();
        return {'ok': true, 'data': options};
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': <CalendarFilterOptionDTO>[]};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getEmployees({required String name}) {
    return _getCalendarFilterOptions(
      'Employee',
      queryParameters: {
        'withDeleted': 'false',
        'operationCode': '190',
        'name': name,
      },
      itemFilter: (employee) {
        final specialties =
            employee['AllowedAppointmentExecutionSpecialties'] as List?;
        return specialties?.isNotEmpty == true;
      },
    );
  }

  Future<Map<String, dynamic>> getCalendarStores() {
    return _getCalendarFilterOptions(
      'Store',
      queryParameters: {'withDeleted': 'false'},
    );
  }

  Future<Map<String, dynamic>> getRooms() {
    return _getCalendarFilterOptions(
      'Store/Room',
      queryParameters: {'withDeleted': 'false'},
    );
  }

  Future<Map<String, dynamic>> getAppointmentStates() {
    return _getCalendarFilterOptions(
      'Appointment/GetAppointmentStateCollection',
    );
  }

  Future<Map<String, dynamic>> getMedicalSpecialties() {
    return _getCalendarFilterOptions(
      'Appointment/GetMedicalSpecialtyCollection',
      queryParameters: {'withDeleted': 'false'},
    );
  }

  Future<Map<String, dynamic>> searchClients({required String name}) async {
    try {
      final uri = Uri.parse('$_baseApiUrl/Client/Search');
      final resp = await http.put(
        uri,
        headers: getHeaderJson(),
        body: jsonEncode({
          'HideDeleted': true,
          'OnlyClients': true,
          'ClientName': name,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final responseData = json.decode(resp.body) as Map<String, dynamic>;
        final clients = (responseData['Clients'] as List? ?? [])
            .map(
              (item) => CalendarFilterOptionDTO.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .where((option) => option.id > 0 && option.name.isNotEmpty)
            .toList();
        return {'ok': true, 'data': clients};
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': <CalendarFilterOptionDTO>[]};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getStores() async {
    try {
      // get /api/Store
      final uri = Uri.parse(
        '$_baseApiUrl/Store',
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
    bool forceLogout = false,
  }) async {
    try {
      // post /api/Auth/AuthenticateUser
      final uri = Uri.parse('$_baseApiUrl/Auth/AuthenticateUser').replace(
        queryParameters: {
          "login": username,
          "password": password,
          "storeID": storeID.toString(),
          "keepMeLoggedIn": 'true',
          "forceLogout": forceLogout.toString(),
        },
      );

      final result = await http.post(uri, headers: getHeaderJson());

      if (result.statusCode == 401) {
        return {
          'ok': false,
          'message': 'Utilizador ou palavra-passe incorreto',
        };
      }

      dynamic data;
      try {
        data = json.decode(result.body);
      } catch (_) {
        data = result.body;
      }
      if (result.statusCode >= 200 && result.statusCode <= 299) {
        var auth = AuthResponseDTO.fromJson(data as Map<String, dynamic>);

        _preferences.token = auth.accessToken;
        _preferences.expire = auth.accessTokenExpireDate;
        _preferences.userID = auth.userInfo.id;
        _preferences.username = username;
        _preferences.pass = password;
        _preferences.storeID = storeID;

        return {'ok': true, 'data': auth};
      } else {
        final message = data is String
            ? data
            : data is Map<String, dynamic>
            ? data['message']?.toString() ??
                  data['Message']?.toString() ??
                  result.body
            : result.body;
        return {
          'ok': false,
          'statusCode': result.statusCode,
          'requiresForceLogout': result.statusCode == 409,
          'message': message,
        };
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      var resp = e.toString();
      if (resp.contains('html')) {
        resp = 'Error: de respuesta del servidor';
      }
      return {'ok': false, 'message': resp};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      // post /api/Auth/Logout
      final uri = Uri.parse(
        '$_baseApiUrl/Auth/Logout',
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

  Future<Map<String, dynamic>> getEnumEntries() async {
    try {
      final uri = Uri.parse('$_baseApiUrl/Auth/GetEnumEntries');
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final enumEntries = data.map(
          (key, value) => MapEntry(
            key,
            (value as List)
                .map(
                  (entry) =>
                      EnumEntryDTO.fromJson(entry as Map<String, dynamic>),
                )
                .toList(),
          ),
        );
        return {'ok': true, 'data': enumEntries};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    try {
      // put /api/Auth/RefreshToken
      final uri = Uri.parse('$_baseApiUrl/Auth/RefreshToken');
      final resp = await http.put(uri, headers: getHeaderJson());
      if (resp.statusCode == 401) {
        return _httpError(resp);
      }
      final data = json.decode(resp.body);
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        var auth = RefreshTokenDTO.fromJson(data);

        _preferences.token = auth.accessToken;
        _preferences.expire = auth.accessTokenExpireDate;
        _preferences.userID = auth.userInfo.id;

        return {'ok': true, 'data': auth};
      } else {
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      var resp = e.toString();
      if (resp.contains('html')) {
        resp = 'Error: de respuesta del servidor';
      }
      return {'ok': false, 'message': resp};
    }
  }

  Future<Map<String, dynamic>> getUsers() async {
    try {
      // get /api/User
      final uri = Uri.parse(
        '$_baseApiUrl/User',
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
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getMessages(Map<String, dynamic> body) async {
    try {
      // put /api/EmailSMS/ChatMessageSearch
      final uri = Uri.parse('$_baseApiUrl/EmailSMS/ChatMessageSearch');

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
      } else if (resp.statusCode == 401) {
        var result = await refreshToken();
        if (result['ok']) {
          return await getMessages(body);
        } else {
          return result;
        }
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': messages};
      } else {
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required MessageDTO message,
  }) async {
    try {
      // post /api/EmailSMS/ChatMessageInsert
      final uri = Uri.parse('$_baseApiUrl/EmailSMS/ChatMessageInsert');

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
        return _httpError(resp);
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
      // get /api/EmailSMS/ChatMessageMarkAsRead/{ID}
      final uri = Uri.parse(
        '$_baseApiUrl/EmailSMS/ChatMessageMarkAsRead/$messageID',
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
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return {'ok': false, 'message': 'Error de conexión'};
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getProgrammedAlarms() async {
    try {
      // get /api/Alarm
      final uri = Uri.parse('$_baseApiUrl/Alarm');

      final resp = await http.get(uri, headers: getHeaderJson());

      var alarms = <AlarmDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data as List)
            .map((alarm) => alarms.add(AlarmDTO.fromJson(alarm)))
            .toList();
        return {'ok': true, 'data': alarms};
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': alarms};
      } else {
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getActiveInstances(
    Map<String, dynamic> params,
  ) async {
    try {
      // get /api/Alarm/GetActiveInstances
      final uri = Uri.parse('$_baseApiUrl/Alarm/GetActiveInstances').replace(
        queryParameters: params.map((k, v) => MapEntry(k, v.toString())),
      );

      final resp = await http.get(uri, headers: getHeaderJson());

      var instances = <AlarmInstanceDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body);
        (data['AlarmInstancesToNotify'] as List)
            .map(
              (instance) => instances.add(AlarmInstanceDTO.fromJson(instance)),
            )
            .toList();
        return {'ok': true, 'data': instances};
      } else if (resp.statusCode == 404) {
        return {'ok': true, 'data': instances};
      } else {
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getAppts(Map<String, dynamic> body) async {
    try {
      // put /api/Appointment/SearchAppointments
      final uri = Uri.parse('$_baseApiUrl/Appointment/SearchAppointments');

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
        return _httpError(resp);
      }
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getEmployeeAbsences(
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('$_baseApiUrl/EmployeeAbsence/Search');
      final resp = await http.put(
        uri,
        headers: getHeaderJson(),
        body: jsonEncode(body),
      );

      final activities = <EmployeeAbsenceDTO>[];
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        final data = json.decode(resp.body) as List;
        activities.addAll(
          data.map(
            (activity) =>
                EmployeeAbsenceDTO.fromJson(activity as Map<String, dynamic>),
          ),
        );
        return {'ok': true, 'data': activities};
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': activities};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getDashboardFullStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      String formatDate(DateTime date) =>
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final uri = Uri.parse('$_baseApiUrl/Dashboard/GetFullStatistics').replace(
        queryParameters: {
          'startDate': formatDate(startDate),
          'endDate': formatDate(endDate),
        },
      );
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return {
          'ok': true,
          'data': json.decode(resp.body) as Map<String, dynamic>,
        };
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': <String, dynamic>{}};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getDashboardClientStatistics(int year) async {
    try {
      final uri = Uri.parse(
        '$_baseApiUrl/Dashboard/GetClientStatistics',
      ).replace(queryParameters: {'year': year.toString()});
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return {
          'ok': true,
          'data': json.decode(resp.body) as Map<String, dynamic>,
        };
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': <String, dynamic>{}};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> getDashboardRealTimeStatistics() async {
    try {
      final uri = Uri.parse('$_baseApiUrl/Dashboard/GetRealTimeStatistics');
      final resp = await http.get(uri, headers: getHeaderJson());
      if (resp.statusCode >= 200 && resp.statusCode <= 299) {
        return {
          'ok': true,
          'data': json.decode(resp.body) as Map<String, dynamic>,
        };
      }
      if (resp.statusCode == 404) {
        return {'ok': true, 'data': <String, dynamic>{}};
      }
      return _httpError(resp);
    } on SocketException catch (_) {
      return _connectionError();
    } catch (e) {
      return {'ok': false, 'message': '$e'};
    }
  }
}
