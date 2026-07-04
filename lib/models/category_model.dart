class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'income' or 'expense'

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'type': type,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}
