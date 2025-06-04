import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/grade_provider.dart';
import '../../models/grade_model.dart';
import '../../widgets/sidebar_drawer.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minGradeController = TextEditingController();
  final TextEditingController _maxGradeController = TextEditingController();

  bool _isFiltersExpanded = false;

  // Filtros seleccionados
  int? _selectedSubjectId;
  int? _selectedPeriodId;
  int? _selectedTrimesterId;

  @override
  void initState() {
    super.initState();

    // Solo cargar materias para los filtros, NO cargar calificaciones automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).loadSubjects();
      // No cargamos calificaciones aquí, esperamos que el usuario aplique filtros
    });

    // Configurar scroll controller para cargar más calificaciones
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final gradeProvider = Provider.of<GradeProvider>(context, listen: false);
      if (gradeProvider.hasMoreGrades && !gradeProvider.isLoading) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id;

        if (userId != null) {
          final token = await authProvider.token;
          if (token != null) {
            gradeProvider.loadMoreGrades(token: token, studentId: userId);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minGradeController.dispose();
    _maxGradeController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = Provider.of<AcademicProvider>(context);
    final gradeProvider = Provider.of<GradeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
        actions: [
          // Para el botón de refresco en el AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final userId = authProvider.user?.id;
              if (userId != null && gradeProvider.grades.isNotEmpty) {
                final token = await authProvider.token;
                if (token != null) {
                  gradeProvider.loadGrades(
                    token: token,
                    studentId: userId,
                    refresh: true,
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: const SidebarDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar calificaciones...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    // Para el botón clear del campo de búsqueda
                    onPressed: () async {
                      _searchController.clear();
                      final userId = authProvider.user?.id;
                      if (userId != null && gradeProvider.grades.isNotEmpty) {
                        final token = await authProvider.token;
                        if (token != null) {
                          gradeProvider.loadGrades(
                            token: token,
                            studentId: userId,
                            refresh: true,
                          );
                        }
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // Para la búsqueda al enviar texto
                onSubmitted: (value) async {
                  final userId = authProvider.user?.id;
                  if (userId != null && value.isNotEmpty) {
                    final token = await authProvider.token;
                    if (token != null) {
                      gradeProvider.applyFilters(
                        token: token,
                        studentId: userId,
                        searchTerm: value,
                      );
                    }
                  }
                },
              ),
            ),

            // Panel de filtros
            Card(
              margin: const EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: const Text(
                  'Filtros de Calificación',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  _isFiltersExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _isFiltersExpanded = expanded;
                  });
                },
                initiallyExpanded: _isFiltersExpanded,
                children: [
                  SizedBox(
                    height:
                        _isFiltersExpanded ? 400 : 0, // Altura máxima definida
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dropdown de Materia
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Materia',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              value: _selectedSubjectId,
                              hint: const Text('Selecciona una materia'),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Todas las materias'),
                                ),
                                ...academicProvider.subjects.map((subject) {
                                  return DropdownMenuItem<int>(
                                    value: subject.id,
                                    child: Text(subject.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubjectId = value;
                                });
                              },
                            ),
                          ),

                          // Dropdown de Periodo
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Periodo',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              value: _selectedPeriodId,
                              hint: const Text('Selecciona un periodo'),
                              items: const [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Todos los periodos'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 1,
                                  child: Text('Año Escolar 2024'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 2,
                                  child: Text('Año Escolar 2025'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeriodId = value;
                                });
                              },
                            ),
                          ),

                          // Dropdown de Trimestre
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: 'Trimestre',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              value: _selectedTrimesterId,
                              hint: const Text('Selecciona un trimestre'),
                              items: const [
                                DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('Todos los trimestres'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 7,
                                  child: Text('Trimestre 1 (2025)'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 8,
                                  child: Text('Trimestre 2 (2025)'),
                                ),
                                DropdownMenuItem<int>(
                                  value: 9,
                                  child: Text('Trimestre 3 (2025)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedTrimesterId = value;
                                });
                              },
                            ),
                          ),

                          // Campo de calificación mínima
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextField(
                              controller: _minGradeController,
                              decoration: const InputDecoration(
                                labelText: 'Calificación mínima',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                hintText: '0',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          // Campo de calificación máxima
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextField(
                              controller: _maxGradeController,
                              decoration: const InputDecoration(
                                labelText: 'Calificación máxima',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                hintText: '100',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),

                          // Botones de acción para filtros
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    // Guardar el ID del usuario actual para el filtro
                                    final userId = authProvider.user?.id;
                                    if (userId != null) {
                                      final token = await authProvider.token;
                                      if (token != null) {
                                        gradeProvider.applyFilters(
                                          token: token,
                                          studentId: userId,
                                          subjectId: _selectedSubjectId,
                                          periodId: _selectedPeriodId,
                                          trimesterId: _selectedTrimesterId,
                                          minGrade:
                                              _minGradeController.text.isEmpty
                                                  ? null
                                                  : double.tryParse(
                                                    _minGradeController.text,
                                                  ),
                                          maxGrade:
                                              _maxGradeController.text.isEmpty
                                                  ? null
                                                  : double.tryParse(
                                                    _maxGradeController.text,
                                                  ),
                                        );
                                      }
                                    }

                                    setState(() {
                                      _isFiltersExpanded = false;
                                    });
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Buscar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedSubjectId = null;
                                    _selectedPeriodId = null;
                                    _selectedTrimesterId = null;
                                    _minGradeController.clear();
                                    _maxGradeController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Limpiar'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contador de calificaciones
            if (gradeProvider.grades.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${gradeProvider.grades.length} de ${gradeProvider.totalGrades}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (gradeProvider.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

            // Lista de calificaciones
            Expanded(
              child: Consumer<GradeProvider>(
                builder: (context, provider, child) {
                  // Mostrar mensaje inicial cuando no se han aplicado filtros
                  if (provider.grades.isEmpty &&
                      !provider.isLoading &&
                      provider.errorMessage.isEmpty &&
                      _selectedSubjectId == null &&
                      _selectedPeriodId == null &&
                      _selectedTrimesterId == null &&
                      _minGradeController.text.isEmpty &&
                      _maxGradeController.text.isEmpty) {
                    return Center(
                      child: ConstrainedBox(
                        // Añadir esta restricción
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // Añadir esto
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Utiliza los filtros para ver tus calificaciones',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isFiltersExpanded = true;
                                  });
                                },
                                icon: const Icon(Icons.search),
                                label: const Text('Aplicar filtros'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Mostrar indicador de carga
                  if (provider.isLoading && provider.grades.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Mostrar mensaje de error
                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${provider.errorMessage}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // Mostrar mensaje cuando no hay calificaciones
                  if (provider.grades.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron calificaciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  }

                  // Mostrar lista de calificaciones
                  return RefreshIndicator(
                    onRefresh: () async {
                      final userId = authProvider.user?.id;
                      if (userId != null) {
                        final token = await authProvider.token;
                        if (token != null) {
                          await provider.applyFilters(
                            token: token,
                            studentId: userId,
                            subjectId: _selectedSubjectId,
                            periodId: _selectedPeriodId,
                            trimesterId: _selectedTrimesterId,
                            minGrade:
                                _minGradeController.text.isEmpty
                                    ? null
                                    : double.tryParse(_minGradeController.text),
                            maxGrade:
                                _maxGradeController.text.isEmpty
                                    ? null
                                    : double.tryParse(_maxGradeController.text),
                          );
                        }
                      }
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount:
                          provider.grades.length +
                          (provider.hasMoreGrades ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Mostrar indicador de carga al final si hay más calificaciones
                        if (index == provider.grades.length &&
                            provider.hasMoreGrades) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        // Mostrar tarjeta de calificación
                        if (index < provider.grades.length) {
                          final grade = provider.grades[index];
                          return _buildGradeCard(grade);
                        }

                        return null;
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modificar las filas dentro del _buildGradeCard para que se ajusten correctamente
  Widget _buildGradeCard(Grade grade) {
    // Determinar color según la calificación
    final double gradeValue = double.tryParse(grade.value) ?? 0;
    Color gradeColor;
    IconData gradeIcon;

    if (gradeValue >= 90) {
      gradeColor = Colors.green;
      gradeIcon = Icons.emoji_events;
    } else if (gradeValue >= 75) {
      gradeColor = Colors.blue;
      gradeIcon = Icons.check_circle;
    } else if (gradeValue >= 60) {
      gradeColor = Colors.amber;
      gradeIcon = Icons.stars;
    } else {
      gradeColor = Colors.red;
      gradeIcon = Icons.warning;
    }

    // Determinar icono según el tipo de evaluación
    IconData assessmentIcon;
    String assessmentTypeText;

    switch (grade.assessmentItem.assessmentType) {
      case 'EXAM':
        assessmentIcon = Icons.assignment;
        assessmentTypeText = 'Examen';
        break;
      case 'TASK':
        assessmentIcon = Icons.task;
        assessmentTypeText = 'Tarea';
        break;
      case 'PROJECT':
        assessmentIcon = Icons.engineering;
        assessmentTypeText = 'Proyecto';
        break;
      case 'PARTICIPATION':
        assessmentIcon = Icons.record_voice_over;
        assessmentTypeText = 'Participación';
        break;
      default:
        assessmentIcon = Icons.description;
        assessmentTypeText = 'Otro';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: gradeColor.withAlpha(26),
          child: Text(
            '${gradeValue.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: gradeColor,
            ),
          ),
        ),
        title: Text(
          grade.assessmentItem.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          // Añadir maxLines y overflow para evitar desbordamiento
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              grade.subject.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              // Añadir overflow para evitar desbordamiento
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Modificar este Row para hacerlo flexible
            // PRIMERA FILA - TIPO Y FECHA
            Wrap(
              spacing: 8.0, // espacio horizontal entre elementos
              children: [
                // Tipo de evaluación
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Importante: minimizar el tamaño
                  children: [
                    Icon(assessmentIcon, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      assessmentTypeText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                // Fecha
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Importante: minimizar el tamaño
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      grade.formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Modificar este Row para hacerlo flexible
            // SEGUNDA FILA - NOTA Y MÁXIMO
            Wrap(
              spacing: 8.0, // espacio horizontal entre elementos
              children: [
                // Nota
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Importante: minimizar el tamaño
                  children: [
                    Icon(gradeIcon, size: 14, color: gradeColor),
                    const SizedBox(width: 4),
                    Text(
                      'Nota: ${gradeValue.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: gradeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Máximo
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Importante: minimizar el tamaño
                  children: [
                    const Icon(Icons.speed, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'Máximo: ${grade.assessmentItem.maxScore}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (grade.comment != null && grade.comment!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Comentario: ${grade.comment!}",
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
      ),
    );
  }
}
