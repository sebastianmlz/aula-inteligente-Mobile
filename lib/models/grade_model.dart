import 'package:intl/intl.dart';

class Student {
  final int userId;
  final String studentId;
  final String fullName;
  final String email;
  final String currentCourseName;

  Student({
    required this.userId,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.currentCourseName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['user_id'],
      studentId: json['student_id'],
      fullName: json['full_name'],
      email: json['email'],
      currentCourseName: json['current_course_name'],
    );
  }
}

class Subject {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int creditHours;
  final List<int> courses;
  final String createdAt;
  final String updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.creditHours,
    required this.courses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      creditHours: json['credit_hours'],
      courses: List<int>.from(json['courses']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Period {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Period({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Course {
  final int id;
  final String name;
  final String code;
  final String? description;
  final int year;
  final int capacity;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.year,
    required this.capacity,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      year: json['year'],
      capacity: json['capacity'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Trimester {
  final int id;
  final String name;
  final int period;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;

  Trimester({
    required this.id,
    required this.name,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Trimester.fromJson(Map<String, dynamic> json) {
    return Trimester(
      id: json['id'],
      name: json['name'],
      period: json['period'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class AssessmentItem {
  final int id;
  final String name;
  final String assessmentType;
  final String date;
  final String maxScore;
  final Subject subject;
  final Course course;
  final Trimester trimester;
  final String createdAt;
  final String updatedAt;

  AssessmentItem({
    required this.id,
    required this.name,
    required this.assessmentType,
    required this.date,
    required this.maxScore,
    required this.subject,
    required this.course,
    required this.trimester,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id'],
      name: json['name'],
      assessmentType: json['assessment_type'],
      date: json['date'],
      maxScore: json['max_score'],
      subject: Subject.fromJson(json['subject']),
      course: Course.fromJson(json['course']),
      trimester: Trimester.fromJson(json['trimester']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Grade {
  final int id;
  final Student student;
  final Subject subject;
  final Period period;
  final AssessmentItem assessmentItem;
  final String value;
  final String? comment;
  final String dateRecorded;
  final String createdAt;
  final String updatedAt;

  Grade({
    required this.id,
    required this.student,
    required this.subject,
    required this.period,
    required this.assessmentItem,
    required this.value,
    this.comment,
    required this.dateRecorded,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      student: Student.fromJson(json['student']),
      subject: Subject.fromJson(json['subject']),
      period: Period.fromJson(json['period']),
      assessmentItem: AssessmentItem.fromJson(json['assessment_item']),
      value: json['value'],
      comment: json['comment'],
      dateRecorded: json['date_recorded'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Método para formatear la fecha
  String get formattedDate {
    final DateTime? parsedDate = DateTime.tryParse(dateRecorded);
    return parsedDate != null
        ? DateFormat('dd/MM/yyyy').format(parsedDate)
        : dateRecorded;
  }

  // Método para formatear el valor como porcentaje
  String get formattedValue {
    final double? valueDouble = double.tryParse(value);
    return valueDouble != null ? '${valueDouble.toStringAsFixed(1)}%' : value;
  }
}

class PaginatedGrades {
  final List<Grade> items; // Cambiar de results a items
  final int total;
  final int page;
  final int pageSize;
  final int pages;
  final bool hasNext; // Cambiar de hasNext a has_next para coincidir con API
  final bool hasPrev; // Coincide con API

  PaginatedGrades({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedGrades.fromJson(Map<String, dynamic> json) {
    return PaginatedGrades(
      items:
          (json['items'] as List<dynamic>)
              .map((item) => Grade.fromJson(item as Map<String, dynamic>))
              .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      pages: json['pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );
  }
}
