import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../core/widgets/animated_farm_background.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/ledger_repository.dart';

class MonthlyFinancialReportScreen extends ConsumerStatefulWidget {
  const MonthlyFinancialReportScreen({super.key});

  @override
  ConsumerState<MonthlyFinancialReportScreen> createState() => _MonthlyFinancialReportScreenState();
}

class _MonthlyFinancialReportScreenState extends ConsumerState<MonthlyFinancialReportScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    final authState = ref.watch(authProvider);
    final entriesAsync = ref.watch(ledgerEntriesFutureProvider);

    final monthTitle = DateFormat('MMMM yyyy').format(_selectedMonth);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Financial Statement',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedFarmBackground()),
          SafeArea(
            child: entriesAsync.when(
              data: (allEntries) {
                // Filter entries for the selected month
                final monthEntries = allEntries.where((e) {
                  return e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month;
                }).toList();

                double totalIncome = 0;
                double totalExpense = 0;
                for (var e in monthEntries) {
                  if (e.type.toLowerCase() == 'income') {
                    totalIncome += e.amount;
                  } else {
                    totalExpense += e.amount;
                  }
                }
                final netProfit = totalIncome - totalExpense;

                return Column(
                  children: [
                    // Month Navigator Bar
                    _buildMonthSelector(context, monthTitle, textColor, subtextColor, isDark),

                    // Quick Financial KPI Snapshot Cards
                    _buildMetricsRow(context, totalIncome, totalExpense, netProfit, monthEntries.length, isDark),

                    // Interactive PDF Document Preview & Action Bar
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: PdfPreview(
                          key: ValueKey('ledger_pdf_${_selectedMonth.year}_${_selectedMonth.month}_${monthEntries.length}'),
                          build: (format) => PdfReportService.generateMonthlyFinancialReportPdf(
                            month: _selectedMonth,
                            entries: allEntries,
                            farmerName: authState.name ?? 'Farmer',
                            contactInfo: authState.phoneNumber ?? authState.email,
                            farmName: 'My Farm Plot',
                          ),
                          allowPrinting: true,
                          allowSharing: true,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          pdfFileName: 'Monthly_Farm_Financial_Report_${DateFormat("yyyy_MM").format(_selectedMonth)}.pdf',
                          loadingWidget: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: theme.colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  'Generating Financial Statement...',
                                  style: TextStyle(color: textColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            PdfPreviewAction(
                              icon: const Icon(Icons.download_rounded),
                              onPressed: (context, buildTree, pageFormat) async {
                                final bytes = await buildTree(pageFormat);
                                final fileName = 'Monthly_Farm_Financial_Report_${DateFormat("yyyy_MM").format(_selectedMonth)}.pdf';
                                await PdfReportService.printOrSavePdf(bytes: bytes, fileName: fileName);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: theme.colorScheme.primary),
              ),
              error: (err, st) => Center(
                child: Text('Error loading ledger: $err', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    String title,
    Color textColor,
    Color subtextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: textColor,
            tooltip: 'Previous Month',
            onPressed: _previousMonth,
          ),
          Row(
            children: [
              Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: textColor,
            tooltip: 'Next Month',
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(
    BuildContext context,
    double income,
    double expense,
    double profit,
    int count,
    bool isDark,
  ) {
    final currencyFormatter = NumberFormat('#,##0');
    final profitColor = profit >= 0
        ? (isDark ? Colors.greenAccent : Colors.green.shade700)
        : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricTile(
              label: 'Income',
              value: 'Rs. ${currencyFormatter.format(income)}',
              color: isDark ? Colors.greenAccent : Colors.green.shade700,
              icon: Icons.arrow_downward_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricTile(
              label: 'Expense',
              value: 'Rs. ${currencyFormatter.format(expense)}',
              color: isDark ? Colors.redAccent : Colors.red.shade700,
              icon: Icons.arrow_upward_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildMetricTile(
              label: 'Net Profit',
              value: 'Rs. ${currencyFormatter.format(profit)}',
              color: profitColor,
              icon: profit >= 0 ? Icons.trending_up : Icons.trending_down,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

final ledgerEntriesFutureProvider = FutureProvider.autoDispose<List<LedgerEntry>>((ref) {
  return ref.watch(ledgerRepositoryProvider).getEntries();
});
