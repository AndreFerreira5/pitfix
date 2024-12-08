class User {
  String name;
  String email;
  String phone;
  String address;
  String? billingAddress;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
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
    };
  }
}
