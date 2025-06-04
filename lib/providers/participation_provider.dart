import 'package:flutter/material.dart';
import '../models/participation_model.dart';
import '../services/participation_service.dart';
import '../utils/logger_util.dart';

class ParticipationProvider with ChangeNotifier {
  final ParticipationService _participationService = ParticipationService();
  final _logger = LoggerUtil.instance;

  // Estado para participaciones
  List<Participation> _participations = [];
  List<Participation> get participations => _participations;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Estado de paginación
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalParticipations = 0;
  bool _hasMoreParticipations = true;

  bool get hasMoreParticipations => _hasMoreParticipations;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalParticipations => _totalParticipations;

  // Estados de filtros
  int? _selectedCourseId;
  int? _selectedSubjectId;
  int? _selectedPeriodId;
  String? _selectedLevel;
  String? _fromDate;
  String? _toDate;

  int? get selectedCourseId => _selectedCourseId;
  int? get selectedSubjectId => _selectedSubjectId;
  int? get selectedPeriodId => _selectedPeriodId;
  String? get selectedLevel => _selectedLevel;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;

  void setSelectedCourseId(int? value) {
    _selectedCourseId = value;
    notifyListeners();
  }

  void setSelectedSubjectId(int? value) {
    _selectedSubjectId = value;
    notifyListeners();
  }

  void setSelectedPeriodId(int? value) {
    _selectedPeriodId = value;
    notifyListeners();
  }

  void setSelectedLevel(String? value) {
    _selectedLevel = value;
    notifyListeners();
  }

  void setFromDate(String? value) {
    _fromDate = value;
    notifyListeners();
  }

  void setToDate(String? value) {
    _toDate = value;
    notifyListeners();
  }

  // Método para cargar participaciones iniciales
  Future<void> loadParticipations({
    bool refresh = false,
    String? search,
    String? ordering,
    int? studentId,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _participations = [];
      _hasMoreParticipations = true;
    }

    if (!_hasMoreParticipations && !refresh) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _participationService.getParticipations(
        page: _currentPage,
        pageSize: 10,
        search: search,
        ordering: ordering,
        courseId: _selectedCourseId,
        subjectId: _selectedSubjectId,
        studentId: studentId,
        periodId: _selectedPeriodId,
        level: _selectedLevel,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // Si es una actualización, añadir a la lista existente
      if (_currentPage > 1 && !refresh) {
        _participations.addAll(result.items);
      } else {
        _participations = result.items;
      }

      // Actualizar información de paginación
      _totalPages = result.pages;
      _totalParticipations = result.total;
      _hasMoreParticipations = result.hasNext;

      // Incrementar página para la próxima carga
      if (_hasMoreParticipations) {
        _currentPage++;
      }

      _logger.i(
        'Participaciones cargadas: ${_participations.length} de $_totalParticipations total',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al cargar participaciones', error: e);
      _errorMessage = 'Error al cargar participaciones: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar más participaciones (paginación)
  Future<void> loadMoreParticipations({
    String? search,
    String? ordering,
    int? studentId,
  }) async {
    if (!_hasMoreParticipations) return;
    await loadParticipations(
      search: search,
      ordering: ordering,
      studentId: studentId,
    );
  }

  // Método para aplicar filtros
  Future<void> applyFilters({
    int? courseId,
    int? subjectId,
    int? periodId,
    String? level,
    String? fromDate,
    String? toDate,
    int? studentId,
  }) async {
    _selectedCourseId = courseId;
    _selectedSubjectId = subjectId;
    _selectedPeriodId = periodId;
    _selectedLevel = level;
    _fromDate = fromDate;
    _toDate = toDate;

    await loadParticipations(refresh: true, studentId: studentId);
  }

  // Método para restablecer filtros
  Future<void> resetFilters({int? studentId}) async {
    _selectedCourseId = null;
    _selectedSubjectId = null;
    _selectedPeriodId = null;
    _selectedLevel = null;
    _fromDate = null;
    _toDate = null;

    await loadParticipations(refresh: true, studentId: studentId);
  }
}
