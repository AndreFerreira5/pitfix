class AssistanceRequest {
  final String? id;
  final String title;
  final String description;
  final String workshopId;
  late final List<String> workersIds;
  final bool? isCompleted;
  final DateTime creationDate;

  AssistanceRequest({
    this.id,
    required this.title,
    required this.description,
    required this.workshopId,
    this.workersIds = const [],
    this.isCompleted = false,
    required this.creationDate,
  });

  factory AssistanceRequest.fromJson(Map<String, dynamic> jsonInput) {
    return AssistanceRequest(
      id: jsonInput['_id'] as String?,
      title: jsonInput['title'] as String,
      description: jsonInput['description'] as String,
      workshopId: jsonInput['workshop_id'] as String,
      workersIds: List<String>.from(jsonInput['workers_ids'] as List<dynamic>),
      isCompleted: jsonInput['is_completed'] as bool? ?? false,
      creationDate: DateTime.parse(jsonInput['creation_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'workshop_id': workshopId,
      'workers_ids': workersIds,
      'is_completed': isCompleted,
      'creation_date': creationDate.toIso8601String(),
    };
  }
}