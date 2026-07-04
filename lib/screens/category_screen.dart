import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Kategori'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          
          if (categories.isEmpty) {
            return const Center(child: Text('Belum ada kategori'));
          }

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isIncome = cat.type == 'income';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(isIncome ? Icons.download : Icons.upload, color: isIncome ? Colors.green : Colors.red),
                ),
                title: Text(cat.name),
                subtitle: Text(isIncome ? 'Pemasukan' : 'Pengeluaran'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    provider.deleteCategory(cat.id!);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String type = 'expense';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Kategori'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Kategori'),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: type,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    Provider.of<TransactionProvider>(context, listen: false).addCategory(
                      CategoryModel(name: nameCtrl.text, type: type)
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        }
      ),
    );
  }
}
