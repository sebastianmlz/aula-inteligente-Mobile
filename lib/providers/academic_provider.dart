import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/course_model.dart';
import '../services/academic_service.dart';
import '../utils/logger_util.dart';

class AcademicProvider with ChangeNotifier {
  final AcademicService _academicService = AcademicService();
  final _logger = LoggerUtil.instance;

  // Estado para materias
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  // Estado para el curso
  Course? _currentCourse;
  Course? get currentCourse => _currentCourse;

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de error
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Estado de paginación
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalSubjects = 0;
  bool _hasMoreSubjects = true;

  bool get hasMoreSubjects => _hasMoreSubjects;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalSubjects => _totalSubjects;

  // Método para cargar las materias iniciales
  Future<void> loadSubjects({
    bool refresh = false,
    String? search,
    String? ordering,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _subjects = [];
      _hasMoreSubjects = true;
    }

    if (!_hasMoreSubjects && !refresh) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Usamos un tamaño de página grande para obtener todas las materias
      // Esto simplifica la implementación para este caso particular
      final result = await _academicService.getSubjects(
        page: _currentPage,
        pageSize: 200, // Un número grande para obtener todas las materias
        search: search,
        ordering: ordering,
      );

      // Si es una actualización, añadir a la lista existente
      if (_currentPage > 1 && !refresh) {
        _subjects.addAll(result.items);
      } else {
        _subjects = result.items;
      }

      // Actualizar información de paginación
      _totalPages = result.pages;
      _totalSubjects = result.total;
      _hasMoreSubjects = result.hasNext;

      // Incrementar página para la próxima carga si hay más páginas
      if (_hasMoreSubjects) {
        _currentPage++;
      }

      _logger.i(
        'Materias cargadas: ${_subjects.length} de $_totalSubjects total',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al cargar materias', error: e);
      _errorMessage = 'Error al cargar materias: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar más materias (paginación)
  Future<void> loadMoreSubjects({String? search, String? ordering}) async {
    if (!_hasMoreSubjects) return;
    await loadSubjects(search: search, ordering: ordering);
  }

  // Método para cargar información del curso actual
  Future<void> loadCurrentCourse() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _academicService.getCourses(
        // Sólo necesitamos el curso actual, así que limitamos a 1
        pageSize: 1,
        // Ordenar por año descendente para obtener el más reciente
        ordering: '-year',
        // Sólo cursos activos
        active: true,
      );

      if (result.items.isNotEmpty) {
        _currentCourse = result.items.first;
      } else {
        _currentCourse = null;
        _errorMessage = 'No se encontraron cursos activos';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.e('Error al cargar curso', error: e);
      _errorMessage = 'Error al cargar curso: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para refrescar todos los datos
  Future<void> refreshData() async {
    await loadCurrentCourse();
    await loadSubjects(refresh: true);
  }
}
