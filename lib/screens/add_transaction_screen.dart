import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transactionToEdit;

  const AddTransactionScreen({Key? key, this.transactionToEdit}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  CategoryModel? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      _title = widget.transactionToEdit!['title'];
      _amount = (widget.transactionToEdit!['amount'] as num).toDouble();
      _selectedDate = DateTime.parse(widget.transactionToEdit!['date']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transactionToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaksi' : 'Catat Transaksi'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          
          if (provider.isCategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada kategori.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Silakan buat kategori pertama Anda di menu Pengaturan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  )
                ],
              ),
            );
          }

          if (isEdit && _selectedCategory == null) {
             try {
                _selectedCategory = categories.firstWhere(
                  (c) => c.id == widget.transactionToEdit!['category_id']
                );
             } catch(e) {}
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(
                      labelText: 'Judul Transaksi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Judul tidak boleh kosong' : null,
                    onSaved: (val) => _title = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _amount == 0 ? '' : _amount.toInt().toString(),
                    decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Nominal tidak boleh kosong';
                      if (double.tryParse(val) == null) return 'Nominal harus angka';
                      return null;
                    },
                    onSaved: (val) => _amount = double.tryParse(val ?? '0') ?? 0,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CategoryModel>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('${cat.name} (${cat.type == 'income' ? 'Pemasukan' : 'Pengeluaran'})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val);
                    },
                    validator: (val) => val == null ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Tanggal Transaksi'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final newTx = TransactionModel(
                          id: isEdit ? widget.transactionToEdit!['id'] : null,
                          title: _title,
                          amount: _amount,
                          date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                          categoryId: _selectedCategory!.id!,
                        );
                        
                        if (isEdit) {
                           provider.updateTransaction(newTx);
                        } else {
                           provider.addTransaction(newTx);
                        }
                        
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
