import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oyeshi_des/models/ingredient.dart';

abstract class IngredientRepository {
  Future<List<Ingredient>> getIngredients(String userId);
  Future<Ingredient?> getIngredient(String userId, String ingredientId);
  Future<void> addIngredient(String userId, Ingredient ingredient);
  Future<void> updateIngredient(String userId, Ingredient ingredient);
  Future<void> deleteIngredient(String userId, String ingredientId);
  Future<List<Ingredient>> searchIngredients(String userId, String query);
  Stream<List<Ingredient>> watchIngredients(String userId);
}

class FirebaseIngredientRepository implements IngredientRepository {
  final FirebaseFirestore _firestore;

  FirebaseIngredientRepository(this._firestore);

  @override
  Future<List<Ingredient>> getIngredients(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ingredients: $e');
    }
  }

  @override
  Future<Ingredient?> getIngredient(String userId, String ingredientId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredientId)
          .get();

      return doc.exists ? Ingredient.fromFirestore(doc) : null;
    } catch (e) {
      throw Exception('Failed to fetch ingredient: $e');
    }
  }

  @override
  Future<void> addIngredient(String userId, Ingredient ingredient) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredient.id)
          .set(ingredient.toMap());
    } catch (e) {
      throw Exception('Failed to add ingredient: $e');
    }
  }

  @override
  Future<void> updateIngredient(String userId, Ingredient ingredient) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredient.id)
          .update(ingredient.toMap());
    } catch (e) {
      throw Exception('Failed to update ingredient: $e');
    }
  }

  @override
  Future<void> deleteIngredient(String userId, String ingredientId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredientId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete ingredient: $e');
    }
  }

  @override
  Future<List<Ingredient>> searchIngredients(String userId, String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search ingredients: $e');
    }
  }

  @override
  Stream<List<Ingredient>> watchIngredients(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('ingredients')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromFirestore(doc))
            .toList());
  }
}