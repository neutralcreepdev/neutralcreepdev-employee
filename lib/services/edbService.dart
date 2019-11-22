import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';

class EDBService {
  final Firestore _db = Firestore.instance;

//  Future<int> getTransactionId(String uid) async {
//    var snap = await _db
//        .collection("Staff")
//        .document(uid)
//        .collection("transactions")
//        .getDocuments();
//
//    return snap.documents.length + 1;
//  }

//  void updateProfile(Employee employee) {
//    Firestore.instance
//      ..collection("Staff").document(employee.id).updateData({
//        "firstName": employee.firstName,
//        "lastName": employee.lastName,
//        "contactNum": employee.contactNum,
//        "address": employee.address,
//        "dob": employee.dob,
//      });
//  }
  Future<Employee> getEmployeeData(String uid) async {
    var snap = await _db.collection("Staff").document(uid).get();
    Employee employee = Employee.fromMap(snap.data);

    return employee;
  }

}
