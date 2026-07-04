import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../services/pdf_service.dart';
import 'category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 12),
          const Text('Kustomisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Kelola Kategori'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()));
            },
          ),
          const Divider(),
          const Text('Data & Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export Laporan (PDF)'),
                onTap: () {
                  if (provider.transactions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada data untuk diexport')));
                    return;
                  }
                  PdfService.generateAndPrintReport(provider.transactions);
                },
              );
            }
          ),
        ],
      ),
    );
  }
}
