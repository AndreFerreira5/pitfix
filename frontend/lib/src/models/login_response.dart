class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userRole;  // Add userRole here

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userRole,  // Add userRole to constructor
  });

  // Factory constructor to parse the response into a LoginResponse object
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userRole: json['user_role'],  // Make sure the API returns 'user_role'
    );
  }

  // Convert the LoginResponse object to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_role': userRole,  // Include userRole in toJson
    };
  }
}
