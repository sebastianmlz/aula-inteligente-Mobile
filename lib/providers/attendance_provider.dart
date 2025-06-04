import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../utils/logger_util.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final _logger = LoggerUtil.instance;

  // Estado para las asistencias
  List<Attendance> _attendanceRecords = [];
  List<Attendance> get attendanceRecords => _attendanceRecords;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Estado de paginación
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  bool _hasMore = true;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;
  bool get hasMore => _hasMore;

  // Estado de filtros
  int? _courseId;
  int? _subjectId;
  int? _periodId;
  int? _userId;
  String? _fromDate;
  String? _toDate;
  String? _status;
  String? _ordering;

  // Getters para filtros
  int? get courseId => _courseId;
  int? get subjectId => _subjectId;
  int? get periodId => _periodId;
  int? get userId => _userId;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;
  String? get status => _status;
  String? get ordering => _ordering;

  // Establecer filtros
  void setFilters({
    int? courseId,
    int? subjectId,
    int? periodId,
    int? userId,
    String? fromDate,
    String? toDate,
    String? status,
    String? ordering,
  }) {
    _courseId = courseId;
    _subjectId = subjectId;
    _periodId = periodId;
    _userId = userId;
    _fromDate = fromDate;
    _toDate = toDate;
    _status = status;
    _ordering = ordering;
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _courseId = null;
    _subjectId = null;
    _periodId = null;
    _fromDate = null;
    _toDate = null;
    _status = null;
    _ordering = null;
    notifyListeners();
  }

  // Cargar registros de asistencia
  Future<void> loadAttendanceRecords({bool refresh = false, int? page}) async {
    if (refresh) {
      _currentPage = 1;
      _attendanceRecords = [];
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _attendanceService.getAttendanceRecords(
        page: page ?? _currentPage,
        pageSize: 10, // Ajustar según necesidad
        courseId: _courseId,
        subjectId: _subjectId,
        periodId: _periodId,
        userId: _userId,
        fromDate: _fromDate,
        toDate: _toDate,
        status: _status,
        ordering: _ordering,
      );

      if (_currentPage > 1 && !refresh && page == null) {
        _attendanceRecords.addAll(result.items);
      } else {
        _attendanceRecords = result.items;
      }

      _totalPages = result.pages;
      _totalRecords = result.total;
      _hasMore = result.hasNext;

      if (_hasMore && page == null) {
        _currentPage++;
      } else if (page != null) {
        _currentPage = page;
      }

      _logger.i(
        'Asistencias cargadas: ${_attendanceRecords.length} de $_totalRecords total',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al cargar asistencias', error: e);
      _errorMessage = 'Error al cargar asistencias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aplicar filtros y cargar datos
  Future<void> applyFilters() async {
    await loadAttendanceRecords(refresh: true);
  }

  // Cargar más registros de asistencia
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadAttendanceRecords();
  }

  // Navegar a una página específica
  Future<void> goToPage(int page) async {
    await loadAttendanceRecords(refresh: true, page: page);
  }
}
