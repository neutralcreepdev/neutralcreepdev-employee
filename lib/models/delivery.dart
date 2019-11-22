class Delivery {
  List<Order> orders = new List<Order>();

  void clear() {
    orders.clear();
  }

  int getOrdersSize() {
    return orders.length;
  }

  Order getOrders(int index) {
    return orders[index];
  }

  void addOrders(Order order) {
    orders.add(order);
  }

  @override
  String toString() {
    return "orders=$orders";
  }
}

class Order {
  String orderID, name, customerId;
  Map address;
  DateTime date;
  List items;
  double totalAmount;
  String collectType;
  Map timeArrival ={'date': {'day':"", 'month':"", 'year':""}, 'time': ""};
  Map actualTime = {'date': {'day':"", 'month':"", 'year':""}, 'time': ""};

  String status;
  String paymentType;

  Order(
      {this.orderID,
      this.name,
      this.address,
      this.date,
      this.customerId,
      this.items,
      this.totalAmount,
      this.collectType,
        this.status,
        this.paymentType,
      this.timeArrival,
      this.actualTime});

  @override
  String toString() {
    return "ORDER#$orderID\n"
        "NAME: $name\n"
        "LOCATION: ${address['street']}\n"
        "UNIT: ${address['unit']}\n"
        "POSTAL CODE: ${address['postalCode']}";
  }

  String expectedTimeString() {
    return "${timeArrival['date']['day']}/${timeArrival['date']['month']}/${timeArrival['date']['year']} ${timeArrival['time']}";
  }

  String actualTimeString() {
    return "${actualTime['date']['day']}/${actualTime['date']['month']}/${actualTime['date']['year']} ${actualTime['time']}";
  }

  String packerHistoryInfo(){
    return "ORDER#$orderID\n"
        "NAME: $name\n";
  }
}
