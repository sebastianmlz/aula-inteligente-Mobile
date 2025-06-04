import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/academic_provider.dart';
import '../../models/subject_model.dart';
import '../../widgets/sidebar_drawer.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Cargar materias al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(
        context,
        listen: false,
      ).loadSubjects(refresh: true);
    });

    // Configurar scroll controller para cargar más materias al llegar al final
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<AcademicProvider>(context, listen: false);
      if (provider.hasMoreSubjects && !provider.isLoading) {
        provider.loadMoreSubjects();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Materias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AcademicProvider>(
                context,
                listen: false,
              ).loadSubjects(refresh: true);
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
                hintText: 'Buscar materias...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<AcademicProvider>(
                      context,
                      listen: false,
                    ).loadSubjects(refresh: true);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onSubmitted: (value) {
                Provider.of<AcademicProvider>(
                  context,
                  listen: false,
                ).loadSubjects(refresh: true, search: value);
              },
            ),
          ),

          // Contador de materias
          Consumer<AcademicProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${provider.subjects.length} materias',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (provider.isLoading && provider.subjects.isNotEmpty)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              );
            },
          ),

          // Lista de materias
          Expanded(
            child: Consumer<AcademicProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.subjects.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.subjects.isEmpty && !provider.isLoading) {
                  return const Center(
                    child: Text(
                      'No se encontraron materias',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadSubjects(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.subjects.length +
                        (provider.hasMoreSubjects ? 1 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemBuilder: (context, index) {
                      // Mostrar indicador de carga al final si hay más materias
                      if (index == provider.subjects.length &&
                          provider.hasMoreSubjects) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // Mostrar tarjeta de materia
                      if (index < provider.subjects.length) {
                        final subject = provider.subjects[index];
                        return _buildSubjectCard(subject);
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

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            subject.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Código: ${subject.code}'),
            Text('Créditos: ${subject.creditHours}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar a detalles de la materia (implementar según sea necesario)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Materia seleccionada: ${subject.name}')),
          );
        },
      ),
    );
  }
}
