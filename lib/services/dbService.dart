import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer.dart';
import '../models/eWallet.dart';

class DBService {
  final Firestore _db = Firestore.instance;

  Future<int> getTransactionId(String uid) async {
    var snap = await _db
        .collection("users")
        .document(uid)
        .collection("transactions")
        .getDocuments();

    return snap.documents.length + 1;
  }

  Future<EWallet> getEWalletData(String uid) async {
    var snap = await _db.collection("users").document(uid).get();
    EWallet eWallet = EWallet.fromMap(snap.data);

    return eWallet;
  }

  Future<Customer> getCustomerData(String uid) async {
    var snap = await _db.collection("users").document(uid).get();
    Customer customer = Customer.fromMap(snap.data);

    return customer;
  }
}
