class User {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? billingAddress;
  final List<String>? requests;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.billingAddress,
    this.requests,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      requests: List<String>.from(json['requests'] as List<dynamic>),
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
      'requests': requests,
    };
  }
}


class Client extends User {
  Client({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    List<String>? requests,
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
  );

  // Convert JSON to Client object
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
    );
  }

  // Convert Client object to JSON
  @override
  Map<String, dynamic> toJson() {
    return super.toJson();  // Call User's toJson method
  }
}


class Worker extends User {
  String? workshopId;  // The ID of the workshop assigned to this worker

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
      workshopId: json['workshopId'],
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

class Manager extends User {
  List<String?> workshopIds;  // List of workshops managed by the manager

  Manager({
    required String name,
    required String email,
    required String phone,
    required String address,
    String? billingAddress,
    required this.workshopIds,
  }) : super(
    name: name,
    email: email,
    phone: phone,
    address: address,
    billingAddress: billingAddress,
  );

  // Convert JSON to Manager object
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      billingAddress: json['billingAddress'],
      workshopIds: List<String?>.from(json['workshops'] ?? []),
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
    return super.toJson();  // Call User's toJson method
  }
}
