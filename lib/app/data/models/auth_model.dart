import 'index.dart';

class AuthResponseDTO {
  final String accessToken;
  final bool mustChangePassword;
  final String accessTokenIssueDate;
  final String accessTokenExpireDate;
  final String refreshToken;
  final String refreshTokenExpiration;
  final UserDTO userInfo;
  final EmployeeDTO employee;

  AuthResponseDTO({
    required this.accessToken,
    required this.mustChangePassword,
    required this.accessTokenIssueDate,
    required this.accessTokenExpireDate,
    required this.refreshToken,
    required this.refreshTokenExpiration,
    required this.userInfo,
    required this.employee,
  });

  factory AuthResponseDTO.fromJson(Map<String, dynamic> json) =>
      AuthResponseDTO(
        accessToken: json['AccessToken'] ?? '',
        mustChangePassword: json['MustChangePassword'] ?? false,
        accessTokenIssueDate: json['AccessTokenIssueDate'] ?? '',
        accessTokenExpireDate: json['AccessTokenExpireDate'] ?? '',
        refreshToken: json['RefreshToken'] ?? '',
        refreshTokenExpiration: json['RefreshTokenExpiration'] ?? '',
        userInfo: UserDTO.fromJson(json['UserInfo'] ?? {}),
        employee: EmployeeDTO.fromJson(json['Employee'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'AccessToken': accessToken,
    'MustChangePassword': mustChangePassword,
    'AccessTokenIssueDate': accessTokenIssueDate,
    'AccessTokenExpireDate': accessTokenExpireDate,
    'RefreshToken': refreshToken,
    'RefreshTokenExpiration': refreshTokenExpiration,
    'UserInfo': userInfo.toJson(),
    'Employee': employee.toJson(),
  };
}
