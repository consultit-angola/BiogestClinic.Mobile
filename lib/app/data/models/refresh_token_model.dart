import 'index.dart';

class RefreshTokenDTO {
  final String accessToken;
  final String accessTokenIssueDate;
  final String accessTokenExpireDate;
  final String refreshToken;
  final String refreshTokenExpiration;
  final UserDTO userInfo;

  RefreshTokenDTO({
    required this.accessToken,
    required this.accessTokenIssueDate,
    required this.accessTokenExpireDate,
    required this.refreshToken,
    required this.refreshTokenExpiration,
    required this.userInfo,
  });

  factory RefreshTokenDTO.fromJson(Map<String, dynamic> json) =>
      RefreshTokenDTO(
        accessToken: json['AccessToken'] ?? '',
        accessTokenIssueDate: json['AccessTokenIssueDate'] ?? '',
        accessTokenExpireDate: json['AccessTokenExpireDate'] ?? '',
        refreshToken: json['RefreshToken'] ?? '',
        refreshTokenExpiration: json['RefreshTokenExpiration'] ?? '',
        userInfo: UserDTO.fromJson(json['UserInfo'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'AccessToken': accessToken,
    'AccessTokenIssueDate': accessTokenIssueDate,
    'AccessTokenExpireDate': accessTokenExpireDate,
    'RefreshToken': refreshToken,
    'RefreshTokenExpiration': refreshTokenExpiration,
    'UserInfo': userInfo.toJson(),
  };
}
