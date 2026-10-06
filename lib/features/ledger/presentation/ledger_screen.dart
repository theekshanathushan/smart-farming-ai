import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/ledger_repository.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/widgets/animated_farm_background.dart';

final ledgerEntriesProvider = FutureProvider<List<LedgerEntry>>((ref) {
  return ref.watch(ledgerRepositoryProvider).getEntries();
});

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(ledgerEntriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Agri Ledger', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedFarmBackground(),
          ),
          SafeArea(
            child: entriesAsync.when(
              data: (entries) {
                double totalIncome = 0;
                double totalExpense = 0;
                for (var e in entries) {
                  if (e.type == 'Income') totalIncome += e.amount;
                  if (e.type == 'Expense') totalExpense += e.amount;
                }
                double netProfit = totalIncome - totalExpense;

                return Column(
                  children: [
                    _buildDashboard(context, totalIncome, totalExpense, netProfit),
                    Expanded(
                      child: entries.isEmpty
                          ? Center(child: Text("No transactions yet.", style: TextStyle(color: subtextColor, fontSize: 16)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final isIncome = entry.type == 'Income';
                                return _buildTransactionCard(context, entry, isIncome, ref);
                              },
                            ),
                    ),
                  ],
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
              error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: theme.colorScheme.error))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ledger/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, double income, double expense, double profit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.9);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Net Profit', style: TextStyle(color: subtextColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Rs. ${profit.toStringAsFixed(2)}',
            style: TextStyle(
              color: profit >= 0 ? (isDark ? Colors.greenAccent : Colors.green.shade700) : Theme.of(context).colorScheme.error,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDashboardMetric('Income', income, isDark ? Colors.greenAccent : Colors.green.shade700, subtextColor),
              _buildDashboardMetric('Expense', expense, Theme.of(context).colorScheme.error, subtextColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboardMetric(String label, double value, Color color, Color subtextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subtextColor, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          'Rs. ${value.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, LedgerEntry entry, bool isIncome, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    final cardBg = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.92);
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0);

    return Dismissible(
      key: Key(entry.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(ledgerRepositoryProvider).deleteEntry(entry);
        ref.invalidate(ledgerEntriesProvider);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? (isDark ? Colors.greenAccent : Colors.green.shade700).withValues(alpha: 0.15) : Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? (isDark ? Colors.greenAccent : Colors.green.shade700) : Theme.of(context).colorScheme.error,
            ),
          ),
          title: Text(entry.category, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          subtitle: Text(
            '${dateFormat.format(entry.date)} ${entry.description != null ? "• ${entry.description}" : ""}',
            style: TextStyle(color: subtextColor, fontSize: 12),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}Rs. ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isIncome ? (isDark ? Colors.greenAccent : Colors.green.shade700) : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
