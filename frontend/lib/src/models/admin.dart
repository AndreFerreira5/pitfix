import 'user.dart';

class Admin extends User {
  Admin({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
  );

  // Convert JSON to Admin object
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
    );
  }

  // Convert Admin object to JSON
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}
