
import './user.dart';
import './delivery.dart';

class Employee extends User {
  Delivery currentOrders;
  String gender;
  String role;
  String email;

  Employee(
      {String id,
      String firstName,
      String lastName,
      Map dob,
      String contactNum,
      Map address,
        this.gender,
        this.role,
        this.email,
        this.currentOrders,})
      : super(id, firstName, lastName, dob, contactNum, address);

  factory Employee.fromMap(Map data) {
    return Employee(
        id: data["UID"] ?? "",
        firstName: data["firstName"] ?? "",
        lastName: data["lastName"] ?? "",
        dob: {
          "day": data["dob"]["day"] ?? 0,
          "month": data["dob"]["month"] ?? 0,
          "year": data["dob"]["year"] ?? 0
        },
        contactNum: data["contactNumber"] ?? "",
        address: {
          "street": data["address"]["street"] ?? "",
          "unit": data["address"]["unit"] ?? "",
          "postalCode": data["address"]["postalCode"] ?? ""
        },
        gender: data["gender"] ?? "",
        role: data["role"] ?? "",
        email: data["email"] ?? "",
        currentOrders: new Delivery());
  }

  void clearDeliveries() {
    currentOrders.clear();
  }

  @override
  String toString() {
    return "${super.toString()}, currentOrders=$currentOrders";
  }
}
