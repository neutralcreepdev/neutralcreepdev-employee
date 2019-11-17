import './transaction.dart';
import './user.dart';
import './eWallet.dart';
import './cart.dart';

class Customer extends User {
  EWallet eWallet;
  List<Transaction> transactions;
  Cart currentCart;

  Customer(
      {String id,
      String firstName,
      String lastName,
      Map dob,
      String contactNum,
      Map address,
      this.eWallet,
      this.transactions,
      this.currentCart})
      : super(id, firstName, lastName, dob, contactNum, address);

  factory Customer.fromMap(Map data) {
    return Customer(
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
        currentCart: new Cart());
  }

  void clearCart() {
    currentCart.clear();
  }

  @override
  String toString() {
    return "${super.toString()}, eWallet=$eWallet, currentCart=$currentCart, transactionHistory=$transactions";
  }
}
