import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../database/db_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allTransactions = []; // Unfiltered
  List<Map<String, dynamic>> _transactions = []; // Filtered by month
  List<CategoryModel> _categories = [];

  List<Map<String, dynamic>> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;

  bool isCategoriesLoading = true;
  DateTime selectedMonth = DateTime.now();

  int _mockTxId = 3;
  int _mockCatId = 3;

  double get totalIncome {
    return _transactions
        .where((t) => t['category_type'] == 'income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  double get totalExpense {
    return _transactions
        .where((t) => t['category_type'] == 'expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  double get balance => totalIncome - totalExpense;

  void changeMonth(DateTime newMonth) {
    selectedMonth = newMonth;
    _filterTransactionsByMonth();
  }

  void _filterTransactionsByMonth() {
    _transactions = _allTransactions.where((t) {
      DateTime dt = DateTime.parse(t['date']);
      return dt.month == selectedMonth.month && dt.year == selectedMonth.year;
    }).toList();
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading = true;
    notifyListeners();

    if (kIsWeb) {
      if (_categories.isEmpty) {
        _categories = [
          CategoryModel(id: 1, name: 'Gaji Web (Mock)', type: 'income'),
          CategoryModel(id: 2, name: 'Makanan Web', type: 'expense'),
        ];
      }
    } else {
      _categories = await DatabaseHelper.instance.getAllCategories();
    }
    
    isCategoriesLoading = false;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    if (kIsWeb) {
      if (_allTransactions.isEmpty) {
        _allTransactions = [
           {'id': 1, 'title': 'Gaji Mock Web', 'amount': 5000000.0, 'date': '2026-07-04', 'category_id': 1, 'category_name': 'Gaji Web (Mock)', 'category_type': 'income'},
           {'id': 2, 'title': 'Beli Makanan', 'amount': 50000.0, 'date': '2026-07-04', 'category_id': 2, 'category_name': 'Makanan Web', 'category_type': 'expense'},
        ];
      }
    } else {
      _allTransactions = await DatabaseHelper.instance.getAllTransactionsWithCategory();
    }
    _filterTransactionsByMonth();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final cat = _categories.firstWhere((c) => c.id == transaction.categoryId);
      _allTransactions.insert(0, {
        'id': _mockTxId++,
        'title': transaction.title,
        'amount': transaction.amount,
        'date': transaction.date,
        'category_id': transaction.categoryId,
        'category_name': cat.name,
        'category_type': cat.type,
      });
      _filterTransactionsByMonth();
    } else {
      await DatabaseHelper.instance.insertTransaction(transaction);
      await fetchTransactions();
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final index = _allTransactions.indexWhere((t) => t['id'] == transaction.id);
      if (index != -1) {
        final cat = _categories.firstWhere((c) => c.id == transaction.categoryId);
        _allTransactions[index] = {
          'id': transaction.id,
          'title': transaction.title,
          'amount': transaction.amount,
          'date': transaction.date,
          'category_id': transaction.categoryId,
          'category_name': cat.name,
          'category_type': cat.type,
        };
      }
      _filterTransactionsByMonth();
    } else {
      await DatabaseHelper.instance.updateTransaction(transaction);
      await fetchTransactions();
    }
  }

  Future<void> deleteTransaction(int id) async {
    if (kIsWeb) {
      _allTransactions.removeWhere((t) => t['id'] == id);
      _filterTransactionsByMonth();
    } else {
      await DatabaseHelper.instance.deleteTransaction(id);
      await fetchTransactions();
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    if (kIsWeb) {
      _categories.add(CategoryModel(
        id: _mockCatId++,
        name: category.name,
        type: category.type,
      ));
      notifyListeners();
    } else {
      await DatabaseHelper.instance.insertCategory(category);
      await fetchCategories();
    }
  }

  Future<void> deleteCategory(int id) async {
    if (kIsWeb) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } else {
      await DatabaseHelper.instance.deleteCategory(id);
      await fetchCategories();
    }
  }
}
