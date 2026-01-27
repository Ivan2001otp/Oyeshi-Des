import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  final String id;
  final String name;
  final String category;
  final DateTime? expiryDate;
  final int? quantity;
  final String? unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.expiryDate,
    this.quantity,
    this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    DateTime? expiryDate,
    int? quantity,
    String? unit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      expiryDate: map['expiryDate'] != null 
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
      quantity: map['quantity'] as int?,
      unit: map['unit'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  factory Ingredient.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Ingredient.fromMap({...map, 'id': doc.id});
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.expiryDate == expiryDate &&
        other.quantity == quantity &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, category, expiryDate, quantity, unit);
  }
}