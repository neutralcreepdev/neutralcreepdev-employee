import './transaction.dart';
import './user.dart';
import './eWallet.dart';
import './cart.dart';
import './delivery.dart';

class Employee extends User {
  //EWallet eWallet;
  List<Transaction> transactions;
  Cart currentCart;
  Delivery currentOrders;

  Employee(
      {String id,
      String firstName,
      String lastName,
      Map dob,
      String contactNum,
      Map address,
        this.currentOrders,
      this.transactions,
      this.currentCart})
      : super(id, firstName, lastName, dob, contactNum, address);

  factory Employee.fromMap(Map data) {
    return Employee(
        id: data["id"] ?? "",
        firstName: data["firstName"] ?? "",
        lastName: data["lastName"] ?? "",
        dob: {
          "day": data["dob"]["day"] ?? 0,
          "month": data["dob"]["month"] ?? 0,
          "year": data["dob"]["year"] ?? 0
        },
        contactNum: data["contactNum"] ?? "",
        address: {
          "street": data["address"]["street"] ?? "",
          "unit": data["address"]["unit"] ?? "",
          "postalCode": data["address"]["postalCode"] ?? ""
        },
        currentOrders: new Delivery());
  }

  void clearCart() {
    currentCart.clear();
  }

  void clearDeliveries() {
    currentOrders.clear();
  }

  @override
  String toString() {
    return "${super.toString()}, currentOrders=$currentOrders";
  }
}
