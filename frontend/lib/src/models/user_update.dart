// UserUpdate model (used when updating the user profile)
class UserUpdate {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? billingAddress;

  UserUpdate({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) {
    return UserUpdate(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
    );
  }

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