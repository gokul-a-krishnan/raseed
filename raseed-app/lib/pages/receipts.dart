import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/data/bill.dart';
import 'package:myapp/pages/add_receipt.dart';
import 'package:myapp/pages/bill_view.dart';
import 'package:myapp/pages/confirm_photo.dart';
import 'package:myapp/pages/photo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myapp/server/backend.dart';
import 'package:myapp/widgets/bill_widget.dart';

class Receipts extends StatefulWidget {
  const Receipts({super.key});

  @override
  State<Receipts> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<Receipts> {
  List<BillData> _list = [];

  @override
  void initState() {
    super.initState();

    fetchReceipts();
    // _list = sampleData();
  }

  void fetchReceipts() async {
    EasyLoading.show(status: 'loading...');
    var resList = await Server().getAllReceipts();
    setState(() {
      _list = resList;
    });
    EasyLoading.dismiss();
  }

  void readImage(BuildContext context) async {
    EasyLoading.show(status: 'loading...');
    List<String> exts = ['jpg', 'jpeg', 'png'];
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: exts,
    );

    EasyLoading.dismiss();
    if (result != null) {
      String path = result.files.single.path!;

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfirmPhoto(file: File(path))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
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
                MaterialPageRoute(builder: (context) => AddReceiptPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              readImage(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Photo()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ..._list.map(
              (item) => Center(
                child: Column(
                  children: [
                    InkWell(
                      child: BillWidget(data: item),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BillView(data: item),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
