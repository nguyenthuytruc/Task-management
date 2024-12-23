class User {
  String username;
  String password;
  String email;
  String? phone; // Để phone có thể nhận giá trị null
  String? avatar; // Để avatar có thể nhận giá trị null

  User({
    required this.username,
    required this.password,
    required this.email,
    this.phone,
    this.avatar,
  });

  // Chuyển đổi từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      email: json['email'],
      phone: json['phone'], // Nếu không có sẽ là null
      avatar: json['avatar'], // Nếu không có sẽ là null
    );
  }

  // Chuyển đối tượng User thành JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phone': phone ?? "", // Nếu phone là null, sẽ chuyển thành chuỗi rỗng
      'avatar': avatar ?? "", // Nếu avatar là null, sẽ chuyển thành chuỗi rỗng
    };
  }
}

class LoginResponse {
  String token;

  LoginResponse({required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['token'] == null) {
      throw Exception('Token not found in response');
    }
    return LoginResponse(token: json['token']);
  }
}
