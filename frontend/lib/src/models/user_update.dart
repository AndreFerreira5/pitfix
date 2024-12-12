class UserUpdate {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? billingAddress;
  final String? password; // Ensure password is part of the update model

  UserUpdate({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
    this.password, // password should be required for updates
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) {
    return UserUpdate(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      password: json['password'],
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
