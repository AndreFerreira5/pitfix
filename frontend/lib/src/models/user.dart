class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? billingAddress;
  final String password; // Make sure password is included

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
    required this.password, // password should be required
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'], // Optional
      password: json['password'], // Include password in the response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'billingAddress': billingAddress,
      'password': password,
    };
  }
}
