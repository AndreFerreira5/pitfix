class AuthTokens {
  final String accessToken;
  final String accessTokenExp;
  final String refreshToken;
  final String refreshTokenExp;

  AuthTokens({
    required this.accessToken,
    required this.accessTokenExp,
    required this.refreshToken,
    required this.refreshTokenExp
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
        accessToken: json['access_token'],
        accessTokenExp: json['access_token_exp'],
        refreshToken: json['refresh_token'],
        refreshTokenExp: json['refresh_token_exp']
    );
  }
}