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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Agri Ledger', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
                          ? const Center(child: Text("No transactions yet.", style: TextStyle(color: Colors.white70)))
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
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ledger/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, double income, double expense, double profit) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('Net Profit', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Rs. ${profit.toStringAsFixed(2)}',
            style: TextStyle(
              color: profit >= 0 ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDashboardMetric('Income', income, Theme.of(context).colorScheme.secondary),
              _buildDashboardMetric('Expense', expense, Theme.of(context).colorScheme.error),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboardMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
            ),
          ),
          title: Text(entry.category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('${dateFormat.format(entry.date)} ${entry.description != null ? "• ${entry.description}" : ""}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          trailing: Text(
            '${isIncome ? '+' : '-'}Rs. ${entry.amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isIncome ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
