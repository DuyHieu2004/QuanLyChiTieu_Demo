class GiaoDich {
  int? id;
  String date;
  String type; // 'thu' (income) or 'chi' (expense)
  double amount;
  double totalAmount; // This might be redundant if calculated on the fly, but based on your schema.
  String? description;
  String? category; // Name of the category from DanhMuc
  String? illustration;
  int userId;

  GiaoDich({
    this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.totalAmount,
    this.description,
    this.category,
    this.illustration,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'amount': amount,
      'totalAmount': totalAmount,
      'description': description,
      'category': category,
      'illustration': illustration,
      'userId': userId,
    };
  }

  factory GiaoDich.fromMap(Map<String, dynamic> map) {
    return GiaoDich(
      id: map['id'],
      date: map['date'],
      type: map['type'],
      amount: map['amount'],
      totalAmount: map['totalAmount'],
      description: map['description'],
      category: map['category'],
      illustration: map['illustration'],
      userId: map['userId'],
    );
  }
}