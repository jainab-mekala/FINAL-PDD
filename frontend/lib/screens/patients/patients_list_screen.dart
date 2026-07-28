import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/patient_card.dart';
import '../../widgets/custom_bottom_nav.dart';

class PatientsListScreen extends ConsumerStatefulWidget {
  const PatientsListScreen({super.key});

  @override
  ConsumerState<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends ConsumerState<PatientsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientsStreamProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PATIENTS',
                            style: TextStyle(
                                color: const Color(0xFF0284C7),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text('Registry',
                            style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF0284C7).withOpacity(0.3)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.person_add_outlined,
                            color: Color(0xFF0284C7)),
                        onPressed: () => context.go('/patients/add'),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).update(v),
                    style: const TextStyle(
                        color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: Color(0xFF0284C7), size: 22),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: Color(0xFF94A3B8), size: 20),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(searchQueryProvider.notifier)
                                    .update('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Patient list
              Expanded(
                child: patientsAsync.when(
                  data: (allPatients) {
                    final patients = query.isEmpty
                        ? allPatients
                        : allPatients
                            .where((p) =>
                                p.fullName
                                    .toLowerCase()
                                    .contains(query.toLowerCase()) ||
                                (p.email
                                        ?.toLowerCase()
                                        .contains(query.toLowerCase()) ??
                                    false))
                            .toList();

                    if (patients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_rounded,
                                size: 72, color: const Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            Text(
                              query.isEmpty
                                  ? 'No patient records found'
                                  : 'No results for "$query"',
                              style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PatientCard(
                            patient: patient,
                            onTap: () => context.go('/patients/${patient.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF0284C7))),
                  error: (e, _) => Center(
                    child: Text('Error: $e',
                        style: const TextStyle(color: Color(0xFFEF4444))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
