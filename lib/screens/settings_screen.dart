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
          // Banner Premium
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFC084FC)], // Purple gradients
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tingkatkan ke Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Buka kunci Backup Google Drive & Bebas Iklan', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Backup ke Google Drive'),
            subtitle: const Text('Fitur Premium'),
            trailing: const Icon(Icons.lock, color: Colors.grey, size: 20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anda perlu berlangganan Premium untuk mencadangkan database.'))
              );
            },
          ),
        ],
      ),
    );
  }
}
