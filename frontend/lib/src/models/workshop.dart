class Workshop {
  final String? id;
  final String name;
  final String? description;
  final double? rating;
  final String? imageUrl;
  final DateTime? creationDate;

  Workshop({
    this.id,
    required this.name,
    this.description,
    this.rating,
    this.imageUrl,
    this.creationDate,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      creationDate: json['creation_date'] != null
          ? DateTime.parse(json['creation_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'rating': rating,
      'image_url': imageUrl,
      if (creationDate != null) 'creation_date': creationDate?.toIso8601String(),
    };

    json.removeWhere((key, value) => value == null);
    return json;
  }
}