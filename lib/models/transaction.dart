import './cart.dart';
import './eWallet.dart';

enum TransactionType { topup, transfer, purchase }

class Transaction {
  String id;
  double totalAmount;
  DateTime dateOfTransaction;
  TransactionType type;

  @override
  String toString() {
    return "id=$id, dateOfTransaction=$dateOfTransaction, totalAmount=$totalAmount";
  }
}

class TopupTransaction extends Transaction {
  CreditCard cardUsed;

  @override
  String toString() {
    return "${super.toString()}, type=Topup, cardUsed=$cardUsed";
  }
}

class TransferTransaction extends Transaction {
  String receiverId;

  @override
  String toString() {
    return "${super.toString()}, type=Transfer, receiverId=$receiverId";
  }
}

class PurchaseTransaction extends Transaction {
  Cart cart;

  PurchaseTransaction({this.cart}) {
    totalAmount = cart.getTotalCost() * 1.07;
    type = TransactionType.purchase;
  }

  void setTransactionDate() {
    this.dateOfTransaction = DateTime.now();
  }

  Cart getCart() {
    return this.cart;
  }

  void setId(String id) {
    this.id = id;
  }

  @override
  String toString() {
    return "${super.toString()}, type=Purchase, cart=$cart";
  }
}
