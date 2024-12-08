class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? billingAddress;
  final String password;  // Include password in User

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
    required this.password,  // Make password required
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      password: json['password'],  // Ensure password is part of the JSON
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'billingAddress': billingAddress,
      'password': password,  // Include password in toJson
    };
  }
}
