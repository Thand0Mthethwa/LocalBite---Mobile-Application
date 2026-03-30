import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comchat/models/shop.dart';

class ShopRepository {
  final FirebaseFirestore _firestore;

  ShopRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Shop>> getShops() {
    return _firestore.collection('shops').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Shop.fromJson(doc.data())).toList();
    });
  }

  Future<void> addShop(Shop shop) {
    return _firestore.collection('shops').doc(shop.id).set(shop.toJson());
  }

  Future<void> updateShop(Shop shop) {
    return _firestore.collection('shops').doc(shop.id).update(shop.toJson());
  }
}
