class BillData {
  String? uuid;
  String? transactionId;
  String billerName;
  double billValue;
  DateTime date;
  List<BillItem> items;

  BillData(this.uuid, this.transactionId, this.billerName, this.billValue, this.date, this.items);

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'biller_name': billerName,
      'bill_value': billValue,
      'date': date.toString(),
      'items': items.map((elem) => elem.toJson()).toList(),
    };
  }

}

class BillItem {
  String name;
  double value;

  BillItem(this.name, this.value);

  Map<String, dynamic> toJson() {
    return {
      'item': name,
      'price': value,
    };
  }
}

List<BillData> sampleData() {
  List<BillData> list = [];

  list.add(BillData(null, 'TXN001', 'Electric Company', 150, DateTime.now(), [
    BillItem('Electricity Charge', 100),
    BillItem('Service Fee', 50),
  ]));

  list.add(BillData(null, 'TXN002', 'Water Supply', 75, DateTime.now(), [
    BillItem('Water Charge', 50),
    BillItem('Sewer Charge', 25),
  ]));

  list.add(BillData("Loop", 'TXN003', 'Internet Provider', 60, DateTime.now(), [
    BillItem('Monthly Subscription', 60),
  ]));

  return list;
}