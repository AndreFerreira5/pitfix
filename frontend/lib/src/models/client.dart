import 'user.dart';

class Client extends User {
  Client({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    required String password,  // Add password field here
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
    password: password,  // Pass password to the User constructor
  );

  // Convert JSON to Client object
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      password: json['password'],  // Ensure password is included in the JSON
    );
  }

  // Convert Client object to JSON
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();  // Call User's toJson method
  }
}
