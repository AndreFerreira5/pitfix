import 'user.dart';

class Worker extends User {
  int workshopId;  // The ID of the workshop assigned to this worker

  Worker({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    required this.workshopId,
    required String password,  // Add password field here
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
    password: password,  // Pass password to the User constructor
  );

  // Convert JSON to Worker object
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      workshopId: json['workshopId'] ?? 0,  // Default to 0 if not found
      password: json['password'],  // Ensure password is included in the JSON
    );
  }

  // Convert Worker object to JSON
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['workshopId'] = workshopId;
    return data;
  }
}
