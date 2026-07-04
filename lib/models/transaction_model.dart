class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String date; // ISO-8601 string standard YYYY-MM-DD
  final int categoryId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'category_id': categoryId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      categoryId: map['category_id'],
    );
  }
}
