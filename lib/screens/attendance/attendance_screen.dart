import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../widgets/sidebar_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ScrollController _scrollController = ScrollController();

  // Controladores para las fechas de los filtros
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  // Filtros seleccionados
  int? _selectedSubjectId;
  int? _selectedPeriodId;
  String? _selectedStatus;
  bool _filtersExpanded = false;

  @override
  void initState() {
    super.initState();

    // Configurar el scroll controller para cargar más cuando se llega al final
    _scrollController.addListener(_onScroll);

    // Inicializar los datos cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar materias para el dropdown
      final academicProvider = Provider.of<AcademicProvider>(
        context,
        listen: false,
      );
      academicProvider.loadSubjects(refresh: true);

      // Establecer el ID del usuario actual como filtro
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<AttendanceProvider>(
          context,
          listen: false,
        ).setFilters(userId: authProvider.user!.id);
      }

      // No cargamos las asistencias automáticamente, esperamos que el usuario aplique filtros
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final academicProvider = Provider.of<AcademicProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentCourse = academicProvider.currentCourse;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Asistencia')),
      drawer: const SidebarDrawer(),
      body: Column(
        children: [
          // Sección de filtros
          Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: const Text(
                'Filtros de Asistencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                _filtersExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onExpansionChanged: (expanded) {
                setState(() {
                  _filtersExpanded = expanded;
                });
              },
              initiallyExpanded: _filtersExpanded,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown de Curso (si está disponible)
                      if (currentCourse != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Curso',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                            ),
                            value: currentCourse.id,
                            items: [
                              DropdownMenuItem<int>(
                                value: currentCourse.id,
                                child: Text(currentCourse.name),
                              ),
                            ],
                            onChanged:
                                null, // Deshabilitado ya que solo hay una opción
                          ),
                        ),

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

                      // Dropdown de Estado
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Estado de Asistencia',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          value: _selectedStatus,
                          hint: const Text('Selecciona un estado'),
                          items: const [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todos los estados'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'present',
                              child: Text('Presente'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'absent',
                              child: Text('Ausente'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'late',
                              child: Text('Tardanza'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
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

                                attendanceProvider.setFilters(
                                  courseId: currentCourse?.id,
                                  subjectId: _selectedSubjectId,
                                  periodId: _selectedPeriodId,
                                  userId: userId,
                                  status: _selectedStatus,
                                  fromDate:
                                      _fromDateController.text.isEmpty
                                          ? null
                                          : _fromDateController.text,
                                  toDate:
                                      _toDateController.text.isEmpty
                                          ? null
                                          : _toDateController.text,
                                );

                                attendanceProvider.applyFilters();

                                setState(() {
                                  _filtersExpanded = false;
                                });
                              },
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar'),
                              style: ElevatedButton.styleFrom(
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
                                _selectedStatus = null;
                                _fromDateController.clear();
                                _toDateController.clear();
                              });

                              // Mantener solo el ID del usuario actual para el filtro
                              final userId = authProvider.user?.id;
                              attendanceProvider.setFilters(userId: userId);
                              attendanceProvider.clearFilters();
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

          // Contador de registros y estado de carga
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${attendanceProvider.attendanceRecords.length} registros',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (attendanceProvider.isLoading &&
                    attendanceProvider.attendanceRecords.isNotEmpty)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          // Lista de registros de asistencia
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, provider, child) {
                // Mostrar mensaje inicial cuando no se han aplicado filtros
                if (provider.attendanceRecords.isEmpty &&
                    !provider.isLoading &&
                    provider.errorMessage.isEmpty &&
                    _selectedSubjectId == null &&
                    _selectedPeriodId == null &&
                    _selectedStatus == null &&
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
                          'Utiliza los filtros para ver tus registros de asistencia',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _filtersExpanded = true;
                            });
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Aplicar filtros'),
                        ),
                      ],
                    ),
                  );
                }

                // Mostrar indicador de carga
                if (provider.isLoading && provider.attendanceRecords.isEmpty) {
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

                // Mostrar mensaje cuando no hay registros
                if (provider.attendanceRecords.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron registros de asistencia',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                // Mostrar lista de asistencias
                return RefreshIndicator(
                  onRefresh: () => provider.applyFilters(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.attendanceRecords.length +
                        (provider.hasMore ? 1 : 0),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      // Mostrar indicador de carga al final si hay más registros
                      if (index == provider.attendanceRecords.length &&
                          provider.hasMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Mostrar tarjeta de asistencia
                      if (index < provider.attendanceRecords.length) {
                        final attendance = provider.attendanceRecords[index];
                        return _buildAttendanceCard(attendance);
                      }

                      return null;
                    },
                  ),
                );
              },
            ),
          ),

          // Paginación
          Consumer<AttendanceProvider>(
            builder: (context, provider, child) {
              if (provider.totalPages <= 1 ||
                  provider.attendanceRecords.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed:
                          provider.currentPage <= 1
                              ? null
                              : () =>
                                  provider.goToPage(provider.currentPage - 1),
                    ),
                    Text(
                      'Página ${provider.currentPage} de ${provider.totalPages}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed:
                          provider.currentPage >= provider.totalPages
                              ? null
                              : () =>
                                  provider.goToPage(provider.currentPage + 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    // Determinar el color y el icono según el estado de asistencia
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (attendance.status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Presente';
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Ausente';
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusText = 'Tardanza';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = attendance.status;
    }

    // Formatear la fecha
    final DateTime? parsedDate = DateTime.tryParse(attendance.date);
    final String formattedDate =
        parsedDate != null
            ? DateFormat('dd/MM/yyyy').format(parsedDate)
            : attendance.date;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor, size: 28),
        ),
        title: Text(
          attendance.subjectName,
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
            Text(
              'Estado: $statusText',
              style: TextStyle(fontSize: 14, color: statusColor),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.black54,
        ),
        onTap: () {
          // Navegar a la pantalla de detalles de asistencia
          Navigator.pushNamed(
            context,
            '/attendance-detail',
            arguments: attendance,
          );
        },
      ),
    );
  }
}
