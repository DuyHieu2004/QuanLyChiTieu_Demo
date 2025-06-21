class DanhMuc {
  int? id;
  String name;
  int? parentId;
  String categoryType; // 'thu' or 'chi'

  DanhMuc({
    this.id,
    required this.name,
    this.parentId,
    required this.categoryType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'categoryType': categoryType,
    };
  }

  factory DanhMuc.fromMap(Map<String, dynamic> map) {
    return DanhMuc(
      id: map['id'],
      name: map['name'],
      parentId: map['parentId'],
      categoryType: map['categoryType'],
    );
  }
}