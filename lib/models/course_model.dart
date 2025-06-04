import 'dart:convert';

class Course {
  final int id;
  final String name;
  final String code;
  final int year;
  final bool isActive;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.year,
    required this.isActive,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'year': year,
      'is_active': isActive,
    };
  }
}

class PaginatedCourses {
  final List<Course> items;
  final int page;
  final int pageSize;
  final int totalCount;

  PaginatedCourses({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  factory PaginatedCourses.fromJson(Map<String, dynamic> json) {
    return PaginatedCourses(
      items:
          (json['items'] as List? ?? [])
              .map((item) => Course.fromJson(item))
              .toList(),
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalCount: json['total_count'] ?? 0,
    );
  }
}
