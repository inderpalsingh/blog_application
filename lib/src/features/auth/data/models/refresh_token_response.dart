class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
    );
  }
}