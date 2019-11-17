class EWallet {
  double eCreadits;
  List<CreditCard> creditCards;

  EWallet({this.eCreadits, this.creditCards});

  factory EWallet.fromMap(Map data) {
    List<CreditCard> creditCards = new List<CreditCard>();
    List<dynamic> cardData = data["creditCards"];
    for (int i = 0; i < cardData.length; i++) {
      Map expiryDate = {
        "month": cardData[i]["expiryDate"]["month"],
        "year": cardData[i]["expiryDate"]["year"]
      };

      CreditCard temp = CreditCard(
          fullName: cardData[i]["fullName"],
          cardNum: cardData[i]["cardNum"],
          expiryDate: expiryDate,
          bankName: cardData[i]["bankName"]);

      creditCards.add(temp);
    }

    return EWallet(creditCards: creditCards, eCreadits: data["eCredit"] ?? 0);
  }

  @override
  String toString() {
    return "eCredits=$eCreadits, creditCards=$creditCards";
  }
}

class CreditCard {
  String fullName, cardNum, bankName;
  Map expiryDate;

  CreditCard({this.fullName, this.cardNum, this.bankName, this.expiryDate});

  @override
  String toString() {
    return "fullName=$fullName, cardNum=$cardNum, bankName=$bankName, expiryDate=$expiryDate";
  }
}
