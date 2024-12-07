import 'dart:convert';

class AssistanceRequest {
  final String? id;
  final String title;
  final String description;
  final String workshopId;
  final List<String> workersIds;
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

  factory AssistanceRequest.fromJson(Map<String, dynamic> json) {
    return AssistanceRequest(
      id: json['_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      workshopId: json['workshop_id'] as String,
      workersIds: List<String>.from(json['workers_ids'] as List<dynamic>),
      isCompleted: json['is_completed'] as bool? ?? false,
      creationDate: DateTime.parse(json['creation_date'] as String),
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