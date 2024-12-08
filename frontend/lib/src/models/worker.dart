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
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
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

