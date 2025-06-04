import 'dart:convert';

class Attendance {
  final int id;
  final String date;
  final String status;
  final int studentId;
  final String studentName;
  final int subjectId;
  final String subjectName;
  final int courseId;
  final String courseName;
  final int periodId;
  final String periodName;

  Attendance({
    required this.id,
    required this.date,
    required this.status,
    required this.studentId,
    required this.studentName,
    required this.subjectId,
    required this.subjectName,
    required this.courseId,
    required this.courseName,
    required this.periodId,
    required this.periodName,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      subjectId: json['subject_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      courseId: json['course_id'] ?? 0,
      courseName: json['course_name'] ?? '',
      periodId: json['period_id'] ?? 0,
      periodName: json['period_name'] ?? '',
    );
  }
}

class PaginatedAttendance {
  final List<Attendance> items;
  final int total;
  final int page;
  final int pageSize;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedAttendance({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedAttendance.fromJson(Map<String, dynamic> json) {
    return PaginatedAttendance(
      items:
          (json['items'] as List? ?? [])
              .map((item) => Attendance.fromJson(item))
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
