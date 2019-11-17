import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer.dart';
import '../models/employee.dart';
import '../models/eWallet.dart';
import '../models/delivery.dart';

class EDBService {
  final Firestore _db = Firestore.instance;

  Future<int> getTransactionId(String uid) async {
    var snap = await _db
        .collection("Staff")
        .document(uid)
        .collection("transactions")
        .getDocuments();

    return snap.documents.length + 1;
  }

//  Future<EWallet> getEWalletData(String uid) async {
//    var snap = await _db.collection("users").document(uid).get();
//    EWallet eWallet = EWallet.fromMap(snap.data);
//
//    return eWallet;
//  }

  Future<Employee> getEmployeeData(String uid) async {
    var snap = await _db.collection("users").document(uid).get();
    Employee employee = Employee.fromMap(snap.data);

    return employee;
  }

}
