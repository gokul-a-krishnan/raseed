import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myapp/data/bill.dart';
import 'package:myapp/pages/add_receipt.dart';
import 'package:uuid/uuid.dart';

class BillView extends StatefulWidget {
  final BillData data;
  const BillView({super.key, required this.data});

  @override
  State<BillView> createState() => _BillViewPageState();
}

class _BillViewPageState extends State<BillView> {
  final String _issuerEmail = "gokulakrishnan.new@gmail.com";
  final String _issuerId = "3388000000022973843";
  final String _passId = Uuid().v4();
  final String _passClass = "bill_class";

  String passString = "";

  @override
  void initState() {
    super.initState();

    passString =
        """
    {
      "iss": "$_issuerEmail",
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#4285f4",
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "${widget.data.billerName}"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Transaction ID: ${widget.data.transactionId}"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Date: ${widget.data.date}"
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": "Amount spent: ${widget.data.billValue}"
              }
            }
          }
        ]
      }
    }
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReceiptPage(data: widget.data),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.0),
                  Text(
                    'Biller: ${widget.data.billerName}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text('Bill (Transation) ID: ${widget.data.transactionId}'),
                  SizedBox(height: 8.0),
                  Align(alignment: Alignment.centerLeft, child: Text('Items:')),
                  ...widget.data.items.map(
                    (item) => Container(
                      padding: EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(flex: 8, child: Text(item.name)),
                          Expanded(flex: 2, child: Text(item.value.toString())),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text('Amount: ${widget.data.billValue}'),
                  SizedBox(height: 8.0),
                  Text('Date: ${widget.data.date}'),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: AddToGoogleWalletButton(
                pass: passString,
                onSuccess: () => EasyLoading.showSuccess("Success"),
                onCanceled: () => EasyLoading.showToast('Action canceled.'),
                onError: (Object error) =>
                    EasyLoading.showToast(error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
