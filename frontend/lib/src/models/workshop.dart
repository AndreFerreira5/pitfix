class Workshop {
  final String name;
  final String? description;
  final double? rating;
  final String? imageUrl;

  Workshop({
    required this.name,
    this.description,
    this.rating,
    this.imageUrl,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      name: json['name'] as String,
      description: json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'rating': rating,
      'image_url': imageUrl,
    };

    json.removeWhere((key, value) => value == null);
    return json;
  }
}