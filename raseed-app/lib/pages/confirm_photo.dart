import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myapp/data/bill.dart';
import 'package:myapp/pages/add_receipt.dart';

class ConfirmPhoto extends StatelessWidget {
  final File file;
  const ConfirmPhoto({super.key, required this.file});

  void receiptFunctionCall(BuildContext context) async {
    EasyLoading.show(status: 'loading...');

    final Uint8List imageBytes = await file.readAsBytes();

    final extractReceiptFunction = FunctionDeclaration(
      "extract_receipt_details",
      "Extract information deatails from receipts.",
      parameters: {
        "biller_name": Schema(
          SchemaType.string,
          description: "Extract the bill issuer's name",
        ),
        "transaction_id": Schema(
          SchemaType.string,
          description: "Extract the transaction id in the bill",
        ),
        "bill_value": Schema(
          SchemaType.number,
          description: "Extract the total amount paid in the bill. remove currency symbol and other symbol.",
        ),
        "date": Schema(
          SchemaType.string,
          description: "Extract the date at which the bill is issued. format should be: YYYY-MM-DD hh:mm:ss",
        ),
        'bill_items': Schema(
          SchemaType.array,
          description: "A list of items found in the text.",
          items: Schema(
            SchemaType.object,
            properties: {
              'item': Schema(
                SchemaType.string,
                description: "The name of the item.",
              ),
              'price': Schema(
                SchemaType.number,
                description: "The price of the item. remove currency symbol and other symbol",
              ),
            },
            optionalProperties: ["item", "price"],
          ),
        ),
      },
      optionalParameters: ["transaction_id", "bill_items"],
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      tools: [
        Tool.functionDeclarations([extractReceiptFunction]),
      ],
    );

    final promptText = Content.text(
      "You are an expert at finding items and their prices from a receipt image. "
      "Extract all items and their corresponding prices."
      "Do not output anything else, just use the function call.",
    );

    final promptimage = InlineDataPart('image/jpeg', imageBytes);

    final response = await model.generateContent([
      Content.multi([...promptText.parts, promptimage]),
    ]);

    if (response.functionCalls.isEmpty) {
      EasyLoading.showToast('Unable to parse the receipt.');
      return;
    }

    final func = response.functionCalls.first;
    
    String billerName = "";
    if  (func.args["biller_name"] != null) {
      billerName = func.args["biller_name"].toString();
    }

    double billValue = 0;
    if (func.args["bill_value"] != null) {
      billValue = double.tryParse(func.args["bill_value"].toString()) ?? 0;
    }

    String? transactionId;
    if (func.args["transaction_id"] != null) {
      transactionId = func.args["transaction_id"].toString();
    }

    List<BillItem> items = [];

    if (func.args["bill_items"] is List) {
      for (var item in func.args["bill_items"] as List) {
        if (item is Map<String, dynamic>) {
          String itemName = item["item"]?.toString() ?? '';
          String itemPrice = item["price"]?.toString() ?? '0.0';
          debugPrint("Price: $itemPrice");
          items.add(BillItem(itemName, double.tryParse(itemPrice) ?? 0.0));
        }
      }
    }

    BillData data = BillData(
      null,
      transactionId,
      billerName,
      billValue,
      DateTime.tryParse(func.args["date"].toString()) ?? DateTime.parse("0000-00-00"),
      items,
    );

    EasyLoading.dismiss();

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddReceiptPage(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Photo'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            file.delete();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              receiptFunctionCall(context);
            },
          ),
        ],
      ),
      body: Image.file(file),
    );
  }
}
