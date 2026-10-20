import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/core/local_db/app_database.dart';
import 'package:agri_ai/core/services/pdf_report_service.dart';

void main() {
  group('PdfReportService Tests', () {
    test('generateMonthlyFinancialReportPdf produces valid PDF byte stream', () async {
      final now = DateTime(2026, 10, 15);
      final entries = [
        LedgerEntry(
          id: 1,
          amount: 50000.0,
          type: 'Income',
          category: 'Harvest Sale',
          date: DateTime(2026, 10, 5),
          description: 'Sold 200kg Paddy to regional mill',
        ),
        LedgerEntry(
          id: 2,
          amount: 12500.0,
          type: 'Expense',
          category: 'Fertilizer',
          date: DateTime(2026, 10, 8),
          description: 'Urea and Organic Compost bags',
        ),
        LedgerEntry(
          id: 3,
          amount: 4500.0,
          type: 'Expense',
          category: 'Labor',
          date: DateTime(2026, 10, 12),
          description: 'Weeding labor wages',
        ),
      ];

      final pdfBytes = await PdfReportService.generateMonthlyFinancialReportPdf(
        month: now,
        entries: entries,
        farmerName: 'Sunil Bandara',
        contactInfo: '+94771234567',
        farmName: 'Green Valley Plot',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);

      // Verify PDF file magic header (%PDF-)
      final header = ascii.decode(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generateMonthlyCropSituationReportPdf produces valid PDF byte stream', () async {
      final now = DateTime(2026, 10, 15);
      final crops = [
        Crop(
          id: 'crop_1',
          name: 'Paddy / Rice',
          variety: 'Bg 352',
          plantDate: DateTime(2026, 8, 20),
          expectedHarvestDate: DateTime(2026, 11, 25),
          area: 2.5,
          areaUnit: 'acres',
          createdAt: DateTime(2026, 8, 20),
        ),
        Crop(
          id: 'crop_2',
          name: 'Chili',
          variety: 'MI 2',
          plantDate: DateTime(2026, 9, 10),
          expectedHarvestDate: DateTime(2026, 12, 15),
          area: 1.0,
          areaUnit: 'acres',
          createdAt: DateTime(2026, 9, 10),
        ),
      ];

      final tasks = [
        Task(
          id: 'task_1',
          cropId: 'crop_1',
          title: 'Apply 2nd round Urea fertilizer',
          description: 'Top dressing before panicle initiation',
          dueDate: DateTime(2026, 10, 10),
          isCompleted: true,
          createdAt: DateTime(2026, 10, 1),
        ),
        Task(
          id: 'task_2',
          cropId: 'crop_2',
          title: 'Drip line irrigation check',
          description: 'Check emitter pressure in row 4',
          dueDate: DateTime(2026, 10, 22),
          isCompleted: false,
          createdAt: DateTime(2026, 10, 12),
        ),
      ];

      final scans = [
        ScanResult(
          id: 1,
          imagePath: '/mock/path/rice_leaf.jpg',
          predictedLabel: 'Rice Leaf Blast (Early Stage)',
          confidence: 0.94,
          timestamp: DateTime(2026, 10, 4),
          notes: 'Sprayed bio-fungicide copper wash',
        ),
        ScanResult(
          id: 2,
          imagePath: '/mock/path/chili.jpg',
          predictedLabel: 'Chili - Healthy',
          confidence: 0.98,
          timestamp: DateTime(2026, 10, 11),
          notes: 'Foliage looking robust',
        ),
      ];

      final harvests = [
        HarvestListing(
          id: 'harvest_1',
          cropName: 'Green Chili',
          category: 'Vegetable',
          quantity: 150.0,
          unit: 'kg',
          pricePerUnit: 350.0,
          grade: 'Grade A',
          harvestDate: DateTime(2026, 10, 14),
          district: 'Anuradhapura',
          farmerName: 'Sunil Bandara',
          farmerPhone: '+94771234567',
          isSold: false,
          createdAt: DateTime(2026, 10, 14),
        ),
      ];

      final pdfBytes = await PdfReportService.generateMonthlyCropSituationReportPdf(
        month: now,
        crops: crops,
        tasks: tasks,
        scans: scans,
        harvests: harvests,
        farmerName: 'Sunil Bandara',
        contactInfo: '+94771234567',
        farmName: 'Green Valley Plot',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);

      final header = ascii.decode(pdfBytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });
  });
}
