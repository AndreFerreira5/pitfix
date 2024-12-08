import 'user.dart';  // Import the User class

class Admin extends User {
  Admin({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    required String password,  // Password should be required here too
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
    password: password,  // Pass password to the User constructor
  );

  // Convert JSON to Admin object
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      password: json['password'],  // Ensure password is in the JSON
    );
  }

  // Convert Admin object to JSON
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();  // Call User's toJson method
  }
}
