import 'package:flutter/material.dart';
import '../models/grade_model.dart';
import '../services/grade_service.dart';
import '../utils/logger_util.dart';

class GradeProvider extends ChangeNotifier {
  final GradeService _gradeService;

  List<Grade> _grades = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _totalGrades = 0;
  int _currentPage = 1;
  bool _hasMoreGrades = true;

  // Filtros
  int? _subjectId;
  int? _periodId;
  String? _assessmentType;
  double? _minGrade;
  double? _maxGrade;
  int? _trimesterId;
  String? _searchTerm;

  List<Grade> get grades => _grades;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get totalGrades => _totalGrades;
  bool get hasMoreGrades => _hasMoreGrades;

  GradeProvider({GradeService? gradeService})
    : _gradeService = gradeService ?? GradeService();

  Future<void> loadGrades({
    required String token,
    int? studentId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _grades = [];
      _hasMoreGrades = true;
    }

    if (!_hasMoreGrades) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final paginatedGrades = await _gradeService.fetchGrades(
        token: token,
        student: studentId,
        subject: _subjectId,
        period: _periodId,
        assessmentType: _assessmentType,
        assessmentItemTrimester: _trimesterId,
        valueGte: _minGrade,
        valueLte: _maxGrade,
        search: _searchTerm,
        ordering: '-date_recorded',
        page: _currentPage,
        pageSize: 10,
      );

      if (refresh) {
        _grades = paginatedGrades.items;
      } else {
        _grades.addAll(paginatedGrades.items);
      }

      _totalGrades = paginatedGrades.total;
      _hasMoreGrades = paginatedGrades.hasNext;
      _currentPage++;
    } catch (e) {
      LoggerUtil.instance.i('Error loading grades: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreGrades({
    required String token,
    required int studentId,
  }) async {
    if (!_hasMoreGrades || _isLoading) return;
    await loadGrades(token: token, studentId: studentId);
  }

  Future<void> applyFilters({
    required String token,
    required int studentId,
    int? subjectId,
    int? periodId,
    String? assessmentType,
    int? trimesterId,
    double? minGrade,
    double? maxGrade,
    String? searchTerm,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      // Registrar los parámetros de filtro para depuración
      LoggerUtil.instance.i(
        'Aplicando filtros: studentId=$studentId, subjectId=$subjectId, '
        'periodId=$periodId, assessmentType=$assessmentType, trimesterId=$trimesterId, '
        'minGrade=$minGrade, maxGrade=$maxGrade, searchTerm=$searchTerm',
      );

      // Registrar explícitamente qué valores se envían
      LoggerUtil.instance.i(
        'Aplicando filtros con assessmentType: $assessmentType',
      );

      final result = await _gradeService.fetchGrades(
        token: token,
        student: studentId,
        subject: subjectId,
        period: periodId,
        assessmentType: assessmentType == "" ? null : assessmentType,
        assessmentItemTrimester: trimesterId,
        valueGte: minGrade,
        valueLte: maxGrade,
        search: searchTerm,
        ordering: '-date_recorded',
      );

      _grades = result.items;
      _totalGrades = result.total;
      _currentPage = 2;
      _hasMoreGrades = result.hasNext;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      LoggerUtil.instance.e('Error loading grades: $e');
      _grades = [];
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
