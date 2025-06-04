import 'dart:convert';

class Subject {
  final int id;
  final String name;
  final String code;
  final int? courseId;
  final int creditHours;
  final int? courseCount;
  final bool isActive;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.courseId,
    required this.creditHours,
    this.courseCount,
    this.isActive = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      courseId: json['course_id'],
      creditHours: json['credit_hours'] ?? 0,
      courseCount: json['course_count'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class PaginatedSubjects {
  final List<Subject> items;
  final int total;
  final int page;
  final int pageSize;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedSubjects({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedSubjects.fromJson(Map<String, dynamic> json) {
    return PaginatedSubjects(
      items:
          (json['items'] as List? ?? [])
              .map((item) => Subject.fromJson(item))
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
