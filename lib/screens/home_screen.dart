import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'chart_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp', 
    decimalDigits: 0
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(provider),
                _buildSummaryCard(provider),
                _buildRecentTransactionsHeader(),
                _buildTransactionList(provider),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Catat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppBar(TransactionProvider provider) {
    final monthYear = DateFormat('MMMM yyyy').format(provider.selectedMonth);

    return SliverAppBar(
      floating: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          InkWell(
            onTap: () async {
               // Show simple month picker or date picker focused on month
               final DateTime? picked = await showDatePicker(
                 context: context,
                 initialDate: provider.selectedMonth,
                 firstDate: DateTime(2000),
                 lastDate: DateTime(2100),
                 helpText: 'Pilih Bulan Transaksi',
               );
               if (picked != null) {
                 provider.changeMonth(picked);
               }
            },
            child: Row(
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(TransactionProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Bersih Bulan Ini',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(provider.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIncomeExpenseInfo(
                    title: 'Pemasukan',
                    amount: provider.totalIncome,
                    icon: Icons.arrow_downward,
                    color: Colors.greenAccent,
                  ),
                  _buildIncomeExpenseInfo(
                    title: 'Pengeluaran',
                    amount: provider.totalExpense,
                    icon: Icons.arrow_upward,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseInfo({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormatter.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Detail Transaksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    if (provider.transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('Tidak ada transaksi bulan ini', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final t = provider.transactions[index];
          final isIncome = t['category_type'] == 'income';
          
          return Dismissible(
            key: Key(t['id'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Hapus Transaksi?'),
                    content: const Text('Tindakan ini tidak bisa dibatalkan.'),
                    actions: <Widget>[
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus')),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              provider.deleteTransaction(t['id']);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
            },
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(transactionToEdit: t)));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    child: Icon(
                      isIncome ? Icons.account_balance_wallet : Icons.shopping_bag,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(t['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(t['category_name']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${currencyFormatter.format((t['amount'] as num).toDouble())}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(DateTime.parse(t['date'])),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: provider.transactions.length,
      ),
    );
  }
}
