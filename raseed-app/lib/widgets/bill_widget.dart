import 'package:flutter/material.dart';
import 'package:myapp/data/bill.dart';

class BillWidget extends StatelessWidget {
  final BillData data;

  const BillWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.0),
          Text(
            'Biller: ${data.billerName}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text('Bill (Transation) ID: ${data.transactionId}'),
          SizedBox(height: 8.0),
          Text('Amount: ${data.billValue}'),
          SizedBox(height: 8.0),
          Text('Date: ${data.date}'),
        ],
      ),
    );
  }
}
