import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';

class EDBService {
  final Firestore _db = Firestore.instance;

  Future<Employee> getEmployeeData(String uid) async {
    var snap = await _db.collection("Staff").document(uid).get();
    Employee employee = Employee.fromMap(snap.data);

    return employee;
  }

}
