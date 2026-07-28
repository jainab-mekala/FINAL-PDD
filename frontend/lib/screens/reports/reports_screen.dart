import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/report_storage_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  DateTime _selectedDay = DateTime.now();
  late final PageController _calendarController;
  late final AnimationController _fadeController;
  static const int _pastDays = 60;

  // ─── Theme colours ──────────────────────────────────────────────
  static const Color _bg = Color(0xFFF0F4FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF5B6EF5);
  static const Color _accentSoft = Color(0xFFEEF0FE);
  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF7B809A);
  static const Color _border = Color(0xFFE4E7F0);

  @override
  void initState() {
    super.initState();
    _calendarController = PageController(
      initialPage: _pastDays,
      viewportFraction: 1 / 7,
    );
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350))
      ..forward();
    _loadHistory();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ReportStorageService.loadAllHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Set<String> get _datesWithReports => _history.map((item) {
        final d = DateTime.tryParse(item['date'] ?? '');
        return d == null ? '' : DateFormat('yyyy-MM-dd').format(d);
      }).where((s) => s.isNotEmpty).toSet();

  List<Map<String, dynamic>> get _filteredHistory {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDay);
    return _history.where((item) {
      final d = DateTime.tryParse(item['date'] ?? '');
      return d != null && DateFormat('yyyy-MM-dd').format(d) == key;
    }).toList();
  }

  Color _riskColor(double score) {
    if (score >= 0.75) return const Color(0xFFE53935);
    if (score >= 0.50) return const Color(0xFFFF6D00);
    if (score >= 0.25) return const Color(0xFFF59E0B);
    return const Color(0xFF22C55E);
  }

  Color _riskBg(double score) {
    if (score >= 0.75) return const Color(0xFFFFEDED);
    if (score >= 0.50) return const Color(0xFFFFF3E0);
    if (score >= 0.25) return const Color(0xFFFFFBEB);
    return const Color(0xFFF0FDF4);
  }

  String _riskLabel(double score) {
    if (score >= 0.75) return 'Critical';
    if (score >= 0.50) return 'High Risk';
    if (score >= 0.25) return 'Moderate';
    return 'Low Risk';
  }

  // ─── Calendar ──────────────────────────────────────────────────
  Widget _buildCalendar() {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final total = _pastDays + 14;

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        boxShadow: [
          BoxShadow(
              color: _accent.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Month / today row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDay),
                  style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = today);
                    _calendarController.animateToPage(_pastDays,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.today_rounded, size: 12, color: _accent),
                        const SizedBox(width: 5),
                        Text('Today',
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _accent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Day cells
          SizedBox(
            height: 80,
            child: PageView.builder(
              controller: _calendarController,
              itemCount: total,
              onPageChanged: (i) {
                final d = today.add(Duration(days: i - _pastDays));
                if (!d.isAfter(today)) setState(() => _selectedDay = d);
              },
              itemBuilder: (_, i) {
                final day = today.add(Duration(days: i - _pastDays));
                final dayKey = DateFormat('yyyy-MM-dd').format(day);
                final selKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
                final isSelected = dayKey == selKey;
                final isToday =
                    dayKey == DateFormat('yyyy-MM-dd').format(today);
                final hasReports = _datesWithReports.contains(dayKey);
                final isFuture = day.isAfter(today);

                return GestureDetector(
                  onTap: isFuture
                      ? null
                      : () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isToday && !isSelected
                          ? Border.all(color: _accent, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day).substring(0, 1),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white60
                                : isFuture
                                    ? _textSecondary.withOpacity(0.4)
                                    : _textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : isFuture
                                    ? _textSecondary.withOpacity(0.4)
                                    : _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasReports
                                ? (isSelected
                                    ? Colors.white70
                                    : _accent)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: _border),
        ],
      ),
    );
  }

  // ─── Report card ───────────────────────────────────────────────
  Widget _buildReportCard(Map<String, dynamic> item, int index) {
    final date =
        DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
    final score = (item['score'] as num?)?.toDouble() ?? 0.0;
    final condition = item['condition']?.toString() ?? 'Unknown';
    final color = _riskColor(score);
    final bg = _riskBg(score);
    final label = _riskLabel(score);

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (_, child) => FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.06 * (index + 1)),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: _fadeController, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => context.push('/reports/detail', extra: item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                  color: _accent.withOpacity(0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Top accent bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Score circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: score,
                              strokeWidth: 4,
                              backgroundColor: color.withOpacity(0.15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(score * 100).toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                    height: 1),
                              ),
                              Text('%',
                                  style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: color.withOpacity(0.7))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Condition + label badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  condition,
                                  style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(label,
                                    style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _infoChip(Icons.access_time_rounded,
                                  DateFormat('HH:mm').format(date)),
                              const SizedBox(width: 10),
                              if (item['age'] != null)
                                _infoChip(Icons.person_outline,
                                    'Age ${item['age']}'),
                              if (item['sex'] != null) ...[
                                const SizedBox(width: 10),
                                _infoChip(Icons.wc_rounded,
                                    item['sex'].toString()),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: _textSecondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _textSecondary)),
      ],
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHistory;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Container(
              color: _surface,
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: _accent, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 7),
                            Text('HISTORY',
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _accent,
                                    letterSpacing: 2.5)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('Reports',
                            style: GoogleFonts.outfit(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: _textPrimary,
                                height: 1.1)),
                      ],
                    ),
                  ),
                  // Total reports badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text('${_history.length}',
                            style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: _accent)),
                        Text('total',
                            style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _accent.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Calendar strip ──────────────────────────────────
            _buildCalendar(),

            // ── Day label ───────────────────────────────────────
            Container(
              color: _bg,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDay),
                    style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: filtered.isEmpty
                          ? _border
                          : _accentSoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filtered.length} report${filtered.length == 1 ? '' : 's'}',
                      style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: filtered.isEmpty ? _textSecondary : _accent),
                    ),
                  ),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: _accent, strokeWidth: 2.5))
                  : filtered.isEmpty
                      ? RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: _accent,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.40,
                              child: _buildEmpty(),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: _accent,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) =>
                                _buildReportCard(filtered[i], i),
                          ),
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: _accentSoft, shape: BoxShape.circle),
            child: Icon(Icons.event_busy_rounded, size: 34, color: _accent),
          ),
          const SizedBox(height: 20),
          Text('No reports for this day',
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          Text('Select another date or run an AI Analysis',
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
