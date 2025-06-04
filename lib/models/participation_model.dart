import 'dart:convert';

class Participation {
  final int id;
  final String date;
  final String level;
  final int value;
  final int studentId;
  final String studentName;
  final int subjectId;
  final String subjectName;
  final String notes;

  Participation({
    required this.id,
    required this.date,
    required this.level,
    required this.value,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    this.notes = '',
  });

  factory Participation.fromJson(Map<String, dynamic> json) {
    return Participation(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      level: json['level'] ?? 'medium',
      value: json['value'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class PaginatedParticipations {
  final List<Participation> items;
  final int total;
  final int page;
  final int pageSize;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedParticipations({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedParticipations.fromJson(Map<String, dynamic> json) {
    return PaginatedParticipations(
      items:
          (json['items'] as List? ?? [])
              .map((item) => Participation.fromJson(item))
              .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      pages: json['pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}
