import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/participation_provider.dart';
import '../../models/participation_model.dart';
import '../../models/subject_model.dart';
import '../../widgets/sidebar_drawer.dart';

class ParticipationScreen extends StatefulWidget {
  const ParticipationScreen({super.key});

  @override
  State<ParticipationScreen> createState() => _ParticipationScreenState();
}

class _ParticipationScreenState extends State<ParticipationScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  bool _isFiltersExpanded = false;

  // Filtros seleccionados
  int? _selectedSubjectId;
  int? _selectedPeriodId;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();

    // Solo cargar materias para los filtros, NO cargar participaciones automáticamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).loadSubjects();

      // No cargamos participaciones aquí, esperamos que el usuario aplique filtros
      // como en la pantalla de asistencias
    });

    // Configurar scroll controller para cargar más participaciones
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final participationProvider = Provider.of<ParticipationProvider>(
        context,
        listen: false,
      );
      if (participationProvider.hasMoreParticipations &&
          !participationProvider.isLoading) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id;

        if (userId != null) {
          participationProvider.loadMoreParticipations(studentId: userId);
        }
      }
    }
  }

  // Método para seleccionar fecha de inicio
  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _fromDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Método para seleccionar fecha de fin
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _toDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = Provider.of<AcademicProvider>(context);
    final participationProvider = Provider.of<ParticipationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Participaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = authProvider.user?.id;
              if (userId != null &&
                  participationProvider.participations.isNotEmpty) {
                participationProvider.loadParticipations(
                  refresh: true,
                  studentId: userId,
                );
              }
            },
          ),
        ],
      ),
      drawer: const SidebarDrawer(),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar participaciones...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    final userId = authProvider.user?.id;
                    if (userId != null &&
                        participationProvider.participations.isNotEmpty) {
                      participationProvider.loadParticipations(
                        refresh: true,
                        studentId: userId,
                      );
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onSubmitted: (value) {
                final userId = authProvider.user?.id;
                if (userId != null && value.isNotEmpty) {
                  participationProvider.loadParticipations(
                    refresh: true,
                    search: value,
                    studentId: userId,
                  );
                }
              },
            ),
          ),

          // Panel de filtros con scroll
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: const Text(
                'Filtros de Participación',
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
                SingleChildScrollView(
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
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSubjectId = value;
                            });
                          },
                        ),
                      ),

                      // Dropdown de Nivel de participación
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Nivel de Participación',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          value: _selectedLevel,
                          hint: const Text('Selecciona un nivel'),
                          items: const [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todos los niveles'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'high',
                              child: Text('Alto'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'medium',
                              child: Text('Medio'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'low',
                              child: Text('Bajo'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value;
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
                              child: Text('2024'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('2025'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriodId = value;
                            });
                          },
                        ),
                      ),

                      // Fecha desde
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: _fromDateController,
                          decoration: InputDecoration(
                            labelText: 'Fecha desde',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectFromDate(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectFromDate(context),
                        ),
                      ),

                      // Fecha hasta
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: _toDateController,
                          decoration: InputDecoration(
                            labelText: 'Fecha hasta',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectToDate(context),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectToDate(context),
                        ),
                      ),

                      // Botones de acción para filtros
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Guardar el ID del usuario actual para el filtro
                                final userId = authProvider.user?.id;

                                if (userId != null) {
                                  participationProvider.applyFilters(
                                    subjectId: _selectedSubjectId,
                                    periodId: _selectedPeriodId,
                                    level: _selectedLevel,
                                    fromDate:
                                        _fromDateController.text.isEmpty
                                            ? null
                                            : _fromDateController.text,
                                    toDate:
                                        _toDateController.text.isEmpty
                                            ? null
                                            : _toDateController.text,
                                    studentId: userId,
                                  );
                                }

                                setState(() {
                                  _isFiltersExpanded = false;
                                });
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
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
                                _selectedLevel = null;
                                _fromDateController.clear();
                                _toDateController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpiar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contador de participaciones
          if (participationProvider.participations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${participationProvider.participations.length} de ${participationProvider.totalParticipations}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (participationProvider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

          // Lista de participaciones
          Expanded(
            child: Consumer<ParticipationProvider>(
              builder: (context, provider, child) {
                // Mostrar mensaje inicial cuando no se han aplicado filtros
                if (provider.participations.isEmpty &&
                    !provider.isLoading &&
                    provider.errorMessage.isEmpty &&
                    _selectedSubjectId == null &&
                    _selectedPeriodId == null &&
                    _selectedLevel == null &&
                    _fromDateController.text.isEmpty &&
                    _toDateController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Utiliza los filtros para ver tus participaciones',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Mostrar indicador de carga
                if (provider.isLoading && provider.participations.isEmpty) {
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

                // Mostrar mensaje cuando no hay participaciones
                if (provider.participations.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron participaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                // Mostrar lista de participaciones
                return RefreshIndicator(
                  onRefresh: () async {
                    final userId = authProvider.user?.id;
                    if (userId != null) {
                      await provider.applyFilters(
                        subjectId: _selectedSubjectId,
                        periodId: _selectedPeriodId,
                        level: _selectedLevel,
                        fromDate:
                            _fromDateController.text.isEmpty
                                ? null
                                : _fromDateController.text,
                        toDate:
                            _toDateController.text.isEmpty
                                ? null
                                : _toDateController.text,
                        studentId: userId,
                      );
                    }
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount:
                        provider.participations.length +
                        (provider.hasMoreParticipations ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Mostrar indicador de carga al final si hay más participaciones
                      if (index == provider.participations.length &&
                          provider.hasMoreParticipations) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Mostrar tarjeta de participación
                      if (index < provider.participations.length) {
                        final participation = provider.participations[index];
                        return _buildParticipationCard(participation);
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
    );
  }

  Widget _buildParticipationCard(Participation participation) {
    // Determinar color e icono según el nivel de participación
    Color levelColor;
    IconData levelIcon;
    String levelText;

    switch (participation.level.toLowerCase()) {
      case 'high':
        levelColor = Colors.green;
        levelIcon = Icons.emoji_events;
        levelText = 'Alto';
        break;
      case 'medium':
        levelColor = Colors.amber;
        levelIcon = Icons.trending_up;
        levelText = 'Medio';
        break;
      case 'low':
        levelColor = Colors.blue;
        levelIcon = Icons.trending_flat;
        levelText = 'Bajo';
        break;
      default:
        levelColor = Colors.grey;
        levelIcon = Icons.help;
        levelText = participation.level;
    }

    // Formatear la fecha
    final DateTime? parsedDate = DateTime.tryParse(participation.date);
    final String formattedDate =
        parsedDate != null
            ? DateFormat('dd/MM/yyyy').format(parsedDate)
            : participation.date;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: levelColor.withOpacity(0.1),
          child: Icon(levelIcon, color: levelColor, size: 28),
        ),
        title: Text(
          participation.subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Fecha: $formattedDate',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Row(
              children: [
                Icon(Icons.star, size: 14, color: levelColor),
                const SizedBox(width: 4),
                Text(
                  'Nivel: $levelText',
                  style: TextStyle(fontSize: 14, color: levelColor),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.add_chart, size: 14, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  'Valor: ${participation.value}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            if (participation.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notas: ${participation.notes}',
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
