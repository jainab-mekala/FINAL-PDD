import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Extension to add Flutter-like opacity support to PdfColor
extension PdfColorExtension on PdfColor {
  PdfColor withOpacity(double opacity) {
    return PdfColor(red, green, blue, opacity);
  }
}

class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportDetailScreen({super.key, required this.report});

  // ─── Theme ───────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF0F4FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF5B6EF5);
  static const Color _accentSoft = Color(0xFFEEF0FE);
  static const Color _textPrimary = Color(0xFF1A1D2E);
  static const Color _textSecondary = Color(0xFF7B809A);
  static const Color _border = Color(0xFFE4E7F0);

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
    if (score >= 0.75) return 'CRITICAL RISK';
    if (score >= 0.50) return 'HIGH RISK';
    if (score >= 0.25) return 'MODERATE RISK';
    return 'LOW RISK';
  }

  // ─── PDF generation ──────────────────────────────────────────────
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final date = DateTime.tryParse(report['date'] ?? '') ?? DateTime.now();
    final score = (report['score'] as num?)?.toDouble() ?? 0.0;
    final condition = report['condition']?.toString().toUpperCase() ?? 'UNKNOWN';

    final medicalBlue = PdfColor.fromInt(0xFF1A5276);
    final darkGrey = PdfColor.fromInt(0xFF2C3E50);
    final lightGrey = PdfColor.fromInt(0xFFF2F4F4);
    final borderGrey = PdfColor.fromInt(0xFFD5DBDB);

    final mainFont = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();
    final titleFont = await PdfGoogleFonts.montserratBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ImplantGuard AI',
                          style: pw.TextStyle(
                              font: titleFont, fontSize: 24, color: medicalBlue)),
                      pw.Text('Advanced Dental Implant Stability Analysis',
                          style: pw.TextStyle(
                              font: mainFont, fontSize: 8, color: darkGrey)),
                    ]),
                pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('MEDICAL REPORT',
                          style: pw.TextStyle(
                              font: boldFont, fontSize: 14, color: medicalBlue)),
                      pw.Text(
                          'ID: IG-${DateFormat('yyyyMMdd').format(date)}-${report['id'] ?? '001'}',
                          style: pw.TextStyle(
                              font: mainFont, fontSize: 8, color: darkGrey)),
                    ]),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: medicalBlue, thickness: 2),
            pw.SizedBox(height: 20),
            pw.Text('PATIENT CLINICAL PROFILE',
                style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 9,
                    color: medicalBlue,
                    letterSpacing: 1)),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: borderGrey),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfField('AGE', '${report['age']} Yrs', mainFont, boldFont, darkGrey),
                  _pdfField('SEX', report['sex'] ?? 'N/A', mainFont, boldFont, darkGrey),
                  _pdfField('DIABETES', report['diabetes'] ?? 'N/A', mainFont, boldFont, darkGrey),
                  _pdfField('HbA1c', '${report['hba1c']}%', mainFont, boldFont, darkGrey),
                  _pdfField('DATE', DateFormat('dd MMM yyyy').format(date), mainFont, boldFont, darkGrey),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 24),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: medicalBlue),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(children: [
                  pw.Text('DIAGNOSTIC ASSESSMENT',
                      style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 10,
                          color: medicalBlue,
                          letterSpacing: 1)),
                  pw.SizedBox(height: 14),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Column(children: [
                        pw.Text('${(score * 100).toStringAsFixed(1)}%',
                            style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 42,
                                color: _pdfRiskColor(score))),
                        pw.Text('FAILURE RISK',
                            style: pw.TextStyle(
                                font: mainFont, fontSize: 8, color: darkGrey)),
                      ]),
                      pw.SizedBox(width: 40),
                      pw.Container(height: 50, width: 1, color: borderGrey),
                      pw.SizedBox(width: 40),
                      pw.Column(children: [
                        pw.Text(condition,
                            style: pw.TextStyle(
                                font: boldFont,
                                fontSize: 20,
                                color: _pdfRiskColor(score))),
                        pw.Text('CONDITION',
                            style: pw.TextStyle(
                                font: mainFont, fontSize: 8, color: darkGrey)),
                      ]),
                    ],
                  ),
                ]),
              ),
            ),
            pw.SizedBox(height: 28),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('IMPLANT SPECS',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 9,
                              color: medicalBlue,
                              letterSpacing: 1)),
                      pw.SizedBox(height: 8),
                      _pdfRow('Surface/Brand', report['surface'] ?? 'N/A', mainFont, darkGrey),
                      _pdfRow('Diameter', '${report['diameter']} mm', mainFont, darkGrey),
                      _pdfRow('Length', '${report['length']} mm', mainFont, darkGrey),
                      _pdfRow('Prosthesis', report['prosthesis'] ?? 'N/A', mainFont, darkGrey),
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CLINICAL HISTORY',
                          style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 9,
                              color: medicalBlue,
                              letterSpacing: 1)),
                      pw.SizedBox(height: 8),
                      _pdfRow('Perio History', report['historyPerio'] ?? 'N/A', mainFont, darkGrey),
                      _pdfRow('Maintenance', report['maintenance'] ?? 'N/A', mainFont, darkGrey),
                    ],
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Divider(color: borderGrey),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('AI-assisted diagnostic — final decision rests with the clinician.',
                    style: pw.TextStyle(
                        font: mainFont,
                        fontSize: 7,
                        color: darkGrey.withOpacity(0.5))),
                pw.Text('Page 1 of 1',
                    style: pw.TextStyle(
                        font: mainFont,
                        fontSize: 7,
                        color: darkGrey.withOpacity(0.5))),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('ImplantGuard AI™ — crafted with excellence by Jainab',
                  style: pw.TextStyle(
                      font: mainFont,
                      fontSize: 9,
                      color: medicalBlue,
                      fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'ImplantGuard_${DateFormat('yyyyMMdd').format(date)}.pdf',
    );
  }

  pw.Widget _pdfField(String label, String value, pw.Font font, pw.Font bold, PdfColor c) =>
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 7, color: c.withOpacity(0.55))),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 10, color: c)),
      ]);

  pw.Widget _pdfRow(String label, String value, pw.Font font, PdfColor c) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(children: [
          pw.Text('$label: ',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: c.withOpacity(0.6))),
          pw.Text(value,
              style: pw.TextStyle(
                  font: font,
                  fontSize: 8,
                  color: c,
                  fontWeight: pw.FontWeight.bold)),
        ]),
      );

  PdfColor _pdfRiskColor(double score) {
    if (score >= 0.75) return PdfColor.fromInt(0xFFC0392B);
    if (score >= 0.50) return PdfColor.fromInt(0xFFE67E22);
    if (score >= 0.25) return PdfColor.fromInt(0xFFF39C12);
    return PdfColor.fromInt(0xFF27AE60);
  }

  // ─── BUILD ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final score = (report['score'] as num?)?.toDouble() ?? 0.0;
    final color = _riskColor(score);
    final bg = _riskBg(score);
    final date = DateTime.tryParse(report['date'] ?? '') ?? DateTime.now();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Report Details',
            style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _textPrimary)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => _generatePdf(context),
              icon: const Icon(Icons.picture_as_pdf_rounded,
                  size: 16, color: _accent),
              label: Text('PDF',
                  style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _accent)),
              style: TextButton.styleFrom(
                backgroundColor: _accentSoft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Risk Score Hero Card ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                children: [
                  // Score ring
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: score,
                            strokeWidth: 10,
                            backgroundColor: color.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${(score * 100).toStringAsFixed(1)}',
                                    style: GoogleFonts.outfit(
                                        fontSize: 38,
                                        fontWeight: FontWeight.w900,
                                        color: color),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: color.withOpacity(0.7)),
                                  ),
                                ],
                              ),
                            ),
                            Text('failure risk',
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: _textSecondary,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 8),
                    decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: color.withOpacity(0.25), width: 1.5)),
                    child: Text(
                      _riskLabel(score),
                      style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report['condition']?.toString() ?? '',
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: _textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMM d yyyy — HH:mm').format(date),
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: _textSecondary.withOpacity(0.7),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── AI message ───────────────────────────────────────
            if ((report['message'] ?? '').toString().isNotEmpty)
              _buildInfoCard(
                icon: Icons.auto_awesome_rounded,
                iconColor: _accent,
                iconBg: _accentSoft,
                title: 'AI Analysis',
                child: Text(
                  report['message'].toString(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: _textSecondary,
                      height: 1.65),
                ),
              ),

            const SizedBox(height: 16),

            // ── Patient Biometrics ────────────────────────────────
            _buildInfoCard(
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF7B61FF),
              iconBg: const Color(0xFFF0EDFF),
              title: 'Patient Biometrics',
              child: Column(
                children: [
                  _detailRow(Icons.cake_outlined, 'Age',
                      '${report['age'] ?? 'N/A'} years'),
                  _divider(),
                  _detailRow(Icons.wc_rounded, 'Sex',
                      report['sex']?.toString() ?? 'N/A'),
                  _divider(),
                  _detailRow(Icons.bloodtype_outlined, 'Diabetes',
                      report['diabetes']?.toString() ?? 'N/A'),
                  _divider(),
                  _detailRow(Icons.percent_rounded, 'HbA1c',
                      '${report['hba1c'] ?? 'N/A'}%'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Implant Specs ─────────────────────────────────────
            _buildInfoCard(
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF22C55E),
              iconBg: const Color(0xFFF0FDF4),
              title: 'Implant Specifications',
              child: Column(
                children: [
                  _detailRow(Icons.category_outlined, 'Brand / Surface',
                      report['surface']?.toString() ?? 'N/A'),
                  _divider(),
                  _detailRow(Icons.width_normal_outlined, 'Diameter',
                      '${report['diameter'] ?? 'N/A'} mm'),
                  _divider(),
                  _detailRow(Icons.height_rounded, 'Length',
                      '${report['length'] ?? 'N/A'} mm'),
                  _divider(),
                  _detailRow(Icons.build_circle_outlined, 'Prosthesis',
                      report['prosthesis']?.toString() ?? 'N/A'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Clinical History ──────────────────────────────────
            _buildInfoCard(
              icon: Icons.history_rounded,
              iconColor: const Color(0xFFFF6D00),
              iconBg: const Color(0xFFFFF3E0),
              title: 'Clinical History',
              child: Column(
                children: [
                  _detailRow(Icons.medical_information_outlined,
                      'Periodontal History',
                      report['historyPerio']?.toString() ?? 'N/A'),
                  _divider(),
                  _detailRow(Icons.event_repeat_rounded, 'Maintenance',
                      report['maintenance']?.toString() ?? 'N/A'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── PDF Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generatePdf(context),
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: Text('Download PDF Report',
                    style: GoogleFonts.outfit(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: _accent.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(title,
                    style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary)),
              ],
            ),
          ),
          Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textSecondary)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: _border.withOpacity(0.6));
}
