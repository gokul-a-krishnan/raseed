import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myapp/data/bill.dart';
import 'package:myapp/main.dart';
import 'package:myapp/server/backend.dart';

class AddReceiptPage extends StatefulWidget {
  final BillData? data;

  const AddReceiptPage({super.key, this.data});

  @override
  State<AddReceiptPage> createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptPage> {
  bool update = false;
  final TextEditingController _transactionIdController =
      TextEditingController();
  final TextEditingController _billerNameController = TextEditingController();
  final TextEditingController _billValueController = TextEditingController();

  List<BillItem> _items = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemValueController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.data == null) return;

    if (widget.data!.uuid != null) {
      setState(() {
        update = true;
      });
    }

    BillData data = widget.data!;

    if (data.transactionId != null) {
      _transactionIdController.text = data.transactionId!;
    }

    _billerNameController.text = data.billerName;
    _billValueController.text = data.billValue.toString();
    _selectedDate = data.date;
    _items = data.items;
  }

  void _addItem() {
    if (_itemController.text.isNotEmpty) {
      setState(() {
        _items.add(
          BillItem(
            _itemController.text,
            double.tryParse(_itemValueController.text) ?? 0.0,
          ),
        );
        _itemController.clear();
        _itemValueController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> saveData(BuildContext context) async {
    EasyLoading.show(status: 'loading...');

    BillData data = BillData(
      null,
      _transactionIdController.text,
      _billerNameController.text,
      double.tryParse(_billValueController.text) ?? 0.0,
      _selectedDate ?? DateTime.parse("0000-00-00 00:00:00"),
      _items,
    );
    bool success = await Server().addReceipt(data);

    EasyLoading.dismiss();

    if (success) {
      EasyLoading.showToast("Receipt Successfully Added.");
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      }
    } else {
      EasyLoading.showToast("Unable To Add Receipt, Please Try Again.");
    }
  }

  Future<void> updateData(BuildContext context) async {
    EasyLoading.show(status: 'loading...');

    BillData data = BillData(
      widget.data!.uuid,
      _transactionIdController.text,
      _billerNameController.text,
      double.tryParse(_billValueController.text) ?? 0.0,
      _selectedDate ?? DateTime.parse("0000-00-00 00:00:00"),
      _items,
    );

    bool success = await Server().editReceipt(widget.data!.uuid!, data);

    EasyLoading.dismiss();

    if (success) {
      EasyLoading.showToast("Receipt Successfully Updated.");
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
        );
      }
    } else {
      EasyLoading.showToast("Unable To Updated Receipt, Please Try Again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _transactionIdController,
                decoration: InputDecoration(labelText: 'Transaction ID'),
              ),
              TextField(
                controller: _billerNameController,
                decoration: InputDecoration(labelText: 'Biller Name'),
              ),
              TextField(
                controller: _billValueController,
                decoration: InputDecoration(labelText: 'Bill Value'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 7, // 70% width
                    child: TextField(
                      controller: _itemController,
                      decoration: InputDecoration(labelText: 'Item'),
                      onSubmitted: (_) => _addItem(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3, // 30% width
                    child: TextField(
                      controller: _itemValueController,
                      decoration: InputDecoration(labelText: 'Value'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_itemController.text.isNotEmpty &&
                      _itemValueController.text.isNotEmpty) {
                    _addItem();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36), // Full width
                ),
                child: const Text('Add Item'),
              ),
              SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: Text('Items:')),
              ..._items.map(
                (item) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 7, // 70% width
                        child: Text(item.name),
                      ),
                      Expanded(
                        flex: 2, // 70% width
                        child: Text(item.value.toString()),
                      ),
                      Expanded(
                        flex: 2, // 70% width
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _items.remove(item);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : 'Select Date',
                ),
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : '',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  update ? updateData(context) : saveData(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36), // Full width
                ),
                child: Text(update ? 'Update' : 'Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
