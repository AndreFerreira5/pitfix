import 'user.dart';

class Manager extends User {
  List<int> workshopIds;  // List of workshops managed by the manager

  Manager({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    required this.workshopIds,
    required String password,  // Add password field here
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
    password: password,  // Pass password to the User constructor
  );

  // Convert JSON to Manager object
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      workshopIds: List<int>.from(json['workshops'] ?? []),
      password: json['password'],  // Ensure password is included in the JSON
    );
  }

  // Convert Manager object to JSON
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['workshops'] = workshopIds;
    return data;
  }
}
