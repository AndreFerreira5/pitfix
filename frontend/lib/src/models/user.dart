class User {
  final String? id;
  final String username;
  final String? name;
  final String role;
  final String email;
  final String? phone;
  final String? address;
  final List<String>? requests;

  User({
    this.id,
    required this.username,
    this.name,
    required this.role,
    required this.email,
    this.phone,
    this.address,
    this.requests,
  });

  // Convert JSON to User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      requests: List<String>.from(json['requests'] as List<dynamic>),
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'name': name,
      'role': role,
      'email': email,
      'phone': phone,
      'address': address,
      'requests': requests,
    };
  }
}


class Client extends User {
  final String? billingAddress;

  Client({
    super.id,
    required super.username,
    super.name,
    required super.role,
    required super.email,
    super.phone,
    super.address,
    super.requests,
    this.billingAddress,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      requests: List<String>.from(json['requests'] ?? []),
      billingAddress: json['billingAddress'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (billingAddress != null) data['billingAddress'] = billingAddress;
    return data;
  }
}


class Worker extends User {
  String? workshopId;  // The ID of the workshop assigned to this worker

  Worker({
    super.id,
    required super.username,
    required super.role,
    required super.email,
    required String super.phone,
    required String super.address,
    super.name,
    String? billingAddress,
    this.workshopId,
    super.requests,
  });

  // Factory constructor to parse the JSON response
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['_id'],  // Assuming _id is the identifier for the worker
      username: json['username'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'] ?? '',  // Default to empty string if phone is not provided
      address: json['address'] ?? '',  // Default to empty string if address is not provided
      name: json['name'],  // Name can be null
      billingAddress: json['billingAddress'],  // Optional billingAddress
      workshopId: json['workshop_id'],  // Note the use of 'workshop_id' from the JSON
      requests: List<String>.from(json['requests'] ?? []),  // Ensure that 'requests' is safely handled
    );
  }

  // Method to convert the Worker object back to a JSON map
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (workshopId != null) data['workshop_id'] = workshopId;  // Use 'workshop_id' as per the received JSON
    return data;
  }
}


class Manager extends User {
  String? workshopId;  // The ID of the workshop managed by this manager

  Manager({
    super.id,
    required super.username,
    required super.role,
    required super.email,
    required String super.phone,
    required String super.address,
    super.name,
    String? billingAddress,
    required this.workshopId,
    super.requests,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      username: json['username'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      name: json['name'],
      billingAddress: json['billingAddress'],
      workshopId: json['workshopId'],
      requests: List<String>.from(json['requests'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (workshopId != null) data['workshopId'] = workshopId;
    return data;
  }
}


class Admin extends User {
  Admin({
    super.id,
    required super.username,
    required super.role,
    required super.email,
    super.phone,
    super.address,
    super.name
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      username: json['username'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      name: json['name'],
    );
  }
}
