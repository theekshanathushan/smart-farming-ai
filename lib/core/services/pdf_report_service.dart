import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../local_db/app_database.dart';

class PdfReportService {
  /// Generate Monthly Income & Expense (Financial Ledger) PDF
  static Future<Uint8List> generateMonthlyFinancialReportPdf({
    required DateTime month,
    required List<LedgerEntry> entries,
    String? farmerName,
    String? contactInfo,
    String? farmName,
  }) async {
    final pdf = pw.Document();

    // Filter entries for the specified month and year
    final monthEntries = entries.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> incomeByCategory = {};
    final Map<String, double> expenseByCategory = {};

    for (final e in monthEntries) {
      if (e.type.toLowerCase() == 'income') {
        totalIncome += e.amount;
        incomeByCategory[e.category] = (incomeByCategory[e.category] ?? 0) + e.amount;
      } else {
        totalExpense += e.amount;
        expenseByCategory[e.category] = (expenseByCategory[e.category] ?? 0) + e.amount;
      }
    }

    final double netProfit = totalIncome - totalExpense;
    final currencyFormatter = NumberFormat('#,##0.00');
    final monthTitle = DateFormat('MMMM yyyy').format(month);
    final printDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'AgriAI Smart Farm Platform',
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'MONTHLY FARM FINANCIAL STATEMENT',
                        style: pw.TextStyle(
                          color: PdfColors.grey800,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Reporting Period: $monthTitle',
                        style: pw.TextStyle(
                          color: PdfColors.green700,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.green300, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'OFFLINE-VERIFIED',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          'Date: $printDate',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.green700),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 12),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AgriAI Farm Ledger | Self-Audited Digital Record',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // Farmer & Farm Details Card
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Farmer: ${farmerName ?? "Registered Farmer"}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    if (contactInfo != null && contactInfo.isNotEmpty)
                      pw.Text(
                        'Contact: $contactInfo',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Farm: ${farmName ?? "Main Farm Plot"}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Total Transactions: ${monthEntries.length}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Executive Financial Summary Banner (3 KPI cards)
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'TOTAL INCOME',
                  value: 'Rs. ${currencyFormatter.format(totalIncome)}',
                  bgColor: PdfColors.green50,
                  borderColor: PdfColors.green400,
                  textColor: PdfColors.green900,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'TOTAL EXPENSE',
                  value: 'Rs. ${currencyFormatter.format(totalExpense)}',
                  bgColor: PdfColors.red50,
                  borderColor: PdfColors.red300,
                  textColor: PdfColors.red900,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'NET PROFIT / LOSS',
                  value: 'Rs. ${currencyFormatter.format(netProfit)}',
                  bgColor: netProfit >= 0 ? PdfColors.teal50 : PdfColors.amber50,
                  borderColor: netProfit >= 0 ? PdfColors.teal400 : PdfColors.amber400,
                  textColor: netProfit >= 0 ? PdfColors.teal900 : PdfColors.amber900,
                  subtitle: netProfit >= 0 ? 'Surplus (+)' : 'Deficit (-)',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),

          // Category Breakdown Section
          pw.Text(
            'Category Breakdown',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Income Breakdown
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Income Sources',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                      ),
                      pw.SizedBox(height: 4),
                      if (incomeByCategory.isEmpty)
                        pw.Text('No income records this month', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600))
                      else
                        ...incomeByCategory.entries.map((entry) {
                          final pct = totalIncome > 0 ? (entry.value / totalIncome * 100).toStringAsFixed(1) : '0';
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('${entry.key} ($pct%)', style: const pw.TextStyle(fontSize: 8)),
                                pw.Text('Rs. ${currencyFormatter.format(entry.value)}',
                                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              // Expense Breakdown
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Expense Allocations',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red800),
                      ),
                      pw.SizedBox(height: 4),
                      if (expenseByCategory.isEmpty)
                        pw.Text('No expense records this month', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600))
                      else
                        ...expenseByCategory.entries.map((entry) {
                          final pct = totalExpense > 0 ? (entry.value / totalExpense * 100).toStringAsFixed(1) : '0';
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('${entry.key} ($pct%)', style: const pw.TextStyle(fontSize: 8)),
                                pw.Text('Rs. ${currencyFormatter.format(entry.value)}',
                                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),

          // Detailed Itemized Transactions Table
          pw.Text(
            'Itemized Transactions Log',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 6),
          if (monthEntries.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'No transactions recorded for $monthTitle.',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(65), // Date
                1: const pw.FixedColumnWidth(85), // Category
                2: const pw.FlexColumnWidth(2),   // Description
                3: const pw.FixedColumnWidth(55), // Type
                4: const pw.FixedColumnWidth(80), // Amount
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.green800),
                  children: [
                    _tableHeaderCell('Date'),
                    _tableHeaderCell('Category'),
                    _tableHeaderCell('Description'),
                    _tableHeaderCell('Type'),
                    _tableHeaderCell('Amount', alignRight: true),
                  ],
                ),
                // Data rows
                ...monthEntries.asMap().entries.map((item) {
                  final i = item.key;
                  final entry = item.value;
                  final isIncome = entry.type.toLowerCase() == 'income';
                  final rowBg = i % 2 == 0 ? PdfColors.white : PdfColors.grey50;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      _tableDataCell(DateFormat('MMM dd').format(entry.date)),
                      _tableDataCell(entry.category),
                      _tableDataCell(entry.description?.isNotEmpty == true ? entry.description! : '-'),
                      _tableDataCell(
                        entry.type,
                        textColor: isIncome ? PdfColors.green900 : PdfColors.red900,
                        bold: true,
                      ),
                      _tableDataCell(
                        '${isIncome ? "+" : "-"} Rs. ${currencyFormatter.format(entry.amount)}',
                        alignRight: true,
                        textColor: isIncome ? PdfColors.green900 : PdfColors.red900,
                        bold: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 18),

          // Farm Financial Insights & Advice
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.green200, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Financial Health & Agronomic Advice',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  netProfit >= 0
                      ? '- Cash Flow Positive: Current month operational revenue covers running farm inputs with a surplus of Rs. ${currencyFormatter.format(netProfit)}.'
                      : '- Input Investment Phase: Expenses exceeded income by Rs. ${currencyFormatter.format(netProfit.abs())}. Ensure upcoming harvest sales are tracked to offset seasonal input costs.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
                pw.Text(
                  '- Recommended Action: Review fertilizer and pesticide expenses against crop yield output in the Farm Situation report.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate Monthly Crop Situation & Farm Health PDF
  static Future<Uint8List> generateMonthlyCropSituationReportPdf({
    required DateTime month,
    required List<Crop> crops,
    required List<Task> tasks,
    required List<ScanResult> scans,
    List<HarvestListing> harvests = const [],
    String? farmerName,
    String? contactInfo,
    String? farmName,
  }) async {
    final pdf = pw.Document();

    final monthTitle = DateFormat('MMMM yyyy').format(month);
    final printDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // Filter scans performed during this month
    final monthScans = scans.where((s) {
      return s.timestamp.year == month.year && s.timestamp.month == month.month;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter tasks due or created in this month
    final monthTasks = tasks.where((t) {
      return (t.dueDate.year == month.year && t.dueDate.month == month.month) ||
          (t.createdAt.year == month.year && t.createdAt.month == month.month);
    }).toList();

    // Filter harvests in this month
    final monthHarvests = harvests.where((h) {
      return h.createdAt.year == month.year && h.createdAt.month == month.month;
    }).toList();

    // Calculate metrics
    final totalArea = crops.fold<double>(0.0, (sum, c) => sum + (c.area ?? 0.0));
    final completedTasks = monthTasks.where((t) => t.isCompleted).length;
    final pendingTasks = monthTasks.where((t) => !t.isCompleted).length;
    final taskCompletionRate = monthTasks.isNotEmpty
        ? (completedTasks / monthTasks.length * 100).toStringAsFixed(0)
        : '100';

    // Scans analysis
    final diseaseScans = monthScans.where((s) {
      final label = s.predictedLabel.toLowerCase();
      return !label.contains('healthy') && !label.contains('normal');
    }).length;
    final healthyScans = monthScans.length - diseaseScans;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'AgriAI Smart Farm Platform',
                        style: pw.TextStyle(
                          color: PdfColors.green800,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'MONTHLY CROP SITUATION & HEALTH REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.grey800,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Agronomic Period: $monthTitle',
                        style: pw.TextStyle(
                          color: PdfColors.green700,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green50,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.green300, width: 0.8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'AI-MONITORED',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          'Issued: $printDate',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.green700),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 12),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'AgriAI Crop Intelligence | Field Scouting & Health Log',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // Farmer & Farm Details Card
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Farmer: ${farmerName ?? "Registered Farmer"}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    if (contactInfo != null && contactInfo.isNotEmpty)
                      pw.Text(
                        'Contact: $contactInfo',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Farm: ${farmName ?? "Main Farm Plot"}',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Total Land Under Cultivation: ${totalArea.toStringAsFixed(1)} Acres',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Monthly Overview KPI Cards (4 metrics)
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'ACTIVE CROPS',
                  value: '${crops.length}',
                  bgColor: PdfColors.green50,
                  borderColor: PdfColors.green400,
                  textColor: PdfColors.green900,
                  subtitle: '${totalArea.toStringAsFixed(1)} Acres',
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'AI SCANS',
                  value: '${monthScans.length}',
                  bgColor: PdfColors.blue50,
                  borderColor: PdfColors.blue300,
                  textColor: PdfColors.blue900,
                  subtitle: '$healthyScans Healthy / $diseaseScans Risk',
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildMetricCard(
                  title: 'TASK COMPLETION',
                  value: '$taskCompletionRate%',
                  bgColor: PdfColors.teal50,
                  borderColor: PdfColors.teal300,
                  textColor: PdfColors.teal900,
                  subtitle: '$completedTasks Done / $pendingTasks Due',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),

          // Section 1: Active Crops & Field Situation
          pw.Text(
            'Active Crops & Cultivation Status',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
          ),
          pw.SizedBox(height: 6),
          if (crops.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text('No crops currently registered in the farm database.',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.4), // Crop Name
                1: const pw.FlexColumnWidth(1.2), // Variety
                2: const pw.FixedColumnWidth(65), // Plant Date
                3: const pw.FixedColumnWidth(65), // Expected Harvest
                4: const pw.FixedColumnWidth(55), // Area
                5: const pw.FlexColumnWidth(1.3), // Days / Stage
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.green800),
                  children: [
                    _tableHeaderCell('Crop Name'),
                    _tableHeaderCell('Variety'),
                    _tableHeaderCell('Planted'),
                    _tableHeaderCell('Est. Harvest'),
                    _tableHeaderCell('Area'),
                    _tableHeaderCell('Field Stage'),
                  ],
                ),
                ...crops.asMap().entries.map((item) {
                  final i = item.key;
                  final c = item.value;
                  final daysInGround = DateTime.now().difference(c.plantDate).inDays;
                  final stage = _estimateGrowthStage(daysInGround);
                  final rowBg = i % 2 == 0 ? PdfColors.white : PdfColors.grey50;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      _tableDataCell(c.name, bold: true),
                      _tableDataCell(c.variety ?? 'Standard'),
                      _tableDataCell(DateFormat('MMM dd, yy').format(c.plantDate)),
                      _tableDataCell(c.expectedHarvestDate != null
                          ? DateFormat('MMM dd, yy').format(c.expectedHarvestDate!)
                          : 'TBD'),
                      _tableDataCell('${c.area ?? 0} ${c.areaUnit ?? "ac"}'),
                      _tableDataCell('$daysInGround d | $stage'),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 18),

          // Section 2: AI Disease & Pest Surveillance Log
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Monthly AI Disease & Pest Surveillance',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Text(
                '${monthScans.length} scans this month',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          if (monthScans.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.green50,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: PdfColors.green200, width: 0.6),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green700,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'No disease outbreaks or emergency scans logged for this month. All fields normal.',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.green900),
                  ),
                ],
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(65),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    _tableHeaderCell('Scan Date'),
                    _tableHeaderCell('Identified Condition / Disease'),
                    _tableHeaderCell('Confidence'),
                    _tableHeaderCell('Scouting Notes / Action'),
                  ],
                ),
                ...monthScans.take(8).toList().asMap().entries.map((item) {
                  final i = item.key;
                  final s = item.value;
                  final isHealthy = s.predictedLabel.toLowerCase().contains('healthy');
                  final rowBg = i % 2 == 0 ? PdfColors.white : PdfColors.grey50;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      _tableDataCell(DateFormat('MMM dd').format(s.timestamp)),
                      _tableDataCell(
                        s.predictedLabel,
                        bold: true,
                        textColor: isHealthy ? PdfColors.green900 : PdfColors.red900,
                      ),
                      _tableDataCell('${(s.confidence * 100).toStringAsFixed(1)}%'),
                      _tableDataCell(s.notes?.isNotEmpty == true ? s.notes! : (isHealthy ? 'Plant looking vigorous' : 'Treatment applied')),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 18),

          // Section 3: Monthly Field Tasks & Agronomic Operations
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Field Tasks & Agronomic Operations',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
              ),
              pw.Text(
                '$completedTasks completed / $pendingTasks pending',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          if (monthTasks.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text('No agronomic tasks scheduled for $monthTitle.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5), // Task Title
                1: const pw.FixedColumnWidth(70),  // Due Date
                2: const pw.FixedColumnWidth(75),  // Status
                3: const pw.FlexColumnWidth(2),    // Instructions
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.green800),
                  children: [
                    _tableHeaderCell('Task / Activity'),
                    _tableHeaderCell('Scheduled'),
                    _tableHeaderCell('Status'),
                    _tableHeaderCell('Details'),
                  ],
                ),
                ...monthTasks.take(10).toList().asMap().entries.map((item) {
                  final i = item.key;
                  final t = item.value;
                  final rowBg = i % 2 == 0 ? PdfColors.white : PdfColors.grey50;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      _tableDataCell(t.title, bold: true),
                      _tableDataCell(DateFormat('MMM dd').format(t.dueDate)),
                      _tableDataCell(
                        t.isCompleted ? 'COMPLETED' : 'PENDING',
                        bold: true,
                        textColor: t.isCompleted ? PdfColors.teal800 : PdfColors.amber800,
                      ),
                      _tableDataCell(t.description?.isNotEmpty == true ? t.description! : 'Standard farm routine'),
                    ],
                  );
                }),
              ],
            ),
          pw.SizedBox(height: 18),

          // Section 4: Harvest & Market Output (if recorded)
          if (monthHarvests.isNotEmpty) ...[
            pw.Text(
              'Monthly Harvest & Yield Output',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FixedColumnWidth(80),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(70),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.teal800),
                  children: [
                    _tableHeaderCell('Harvested Crop'),
                    _tableHeaderCell('Quantity'),
                    _tableHeaderCell('Target Price'),
                    _tableHeaderCell('Market Status'),
                  ],
                ),
                ...monthHarvests.asMap().entries.map((item) {
                  final h = item.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: item.key % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                    ),
                    children: [
                      _tableDataCell('${h.cropName} (${h.grade})', bold: true),
                      _tableDataCell('${h.quantity} ${h.unit}'),
                      _tableDataCell('Rs. ${h.pricePerUnit.toStringAsFixed(2)} / ${h.unit}'),
                      _tableDataCell(h.isSold ? 'Sold' : 'Available', textColor: h.isSold ? PdfColors.green900 : PdfColors.blue800),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 18),
          ],

          // Agronomic Advice & Guidance for next month
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.green300, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Agronomist Monthly Observations & Advisory',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green900),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '- Water & Irrigation: Check soil moisture sensor logs or weekly rainfall patterns to calibrate drip/sprinkler run times for vegetative crops.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
                pw.Text(
                  '- Soil Nutrition: Plan top-dressing of nitrogen or organic compost for crops entering flowering/fruit-set stage.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
                pw.Text(
                  '- Pest Vigilance: Continue weekly AI camera scouting on new leaf flushes to catch leaf curl or fungal blight before spore dispersal.',
                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // --- Helper Widgets & Utility Functions ---

  static String _estimateGrowthStage(int days) {
    if (days < 20) return 'Germination / Seedling';
    if (days < 50) return 'Vegetative Growth';
    if (days < 80) return 'Flowering & Podding';
    if (days < 110) return 'Grain Fill / Fruit Maturity';
    return 'Harvest Ready';
  }

  static pw.Widget _buildMetricCard({
    required String title,
    required String value,
    required PdfColor bgColor,
    required PdfColor borderColor,
    required PdfColor textColor,
    String? subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderColor, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: textColor),
          ),
          if (subtitle != null) ...[
            pw.SizedBox(height: 1),
            pw.Text(
              subtitle,
              style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _tableHeaderCell(String text, {bool alignRight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8.5,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _tableDataCell(
    String text, {
    bool bold = false,
    bool alignRight = false,
    PdfColor textColor = PdfColors.black,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  /// Print or Save PDF
  static Future<void> printOrSavePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: fileName,
    );
  }

  /// Share PDF file via system dialog (WhatsApp, Bluetooth, Email, Files, etc.)
  static Future<void> sharePdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.sharePdf(
      bytes: bytes,
      filename: fileName,
    );
  }
}
