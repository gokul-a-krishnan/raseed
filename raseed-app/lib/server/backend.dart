import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/data/bill.dart';

class Server {
  Server();

  final String host = "https://raseed.gokulakrishnan.in/receipt";

  Future<List<BillData>> getAllReceipts() async {
    List<BillData> bills = [];
    try {
      final response = await Dio().get('$host/get-all');
      if (response.data is List) {
        for (var data in response.data as List) {
          String uuid = "";
          if (data["id"] != null) {
            uuid = data["id"].toString();
          }
          String billerName = "";
          if (data["biller_name"] != null) {
            billerName = data["biller_name"].toString();
          }

          double billValue = 0;
          if (data["bill_value"] != null) {
            billValue = double.tryParse(data["bill_value"].toString()) ?? 0;
          }

          String? transactionId;
          if (data["transaction_id"] != null) {
            transactionId = data["transaction_id"].toString();
          }

          List<BillItem> items = [];

          if (data["items"] is List) {
            for (var item in data["items"] as List) {
              if (item is Map<String, dynamic>) {
                String itemName = item["item"]?.toString() ?? '';
                String itemPrice = item["price"]?.toString() ?? '0.0';
                debugPrint("Price: $itemPrice");
                items.add(
                  BillItem(itemName, double.tryParse(itemPrice) ?? 0.0),
                );
              }
            }
          }

          BillData finalData = BillData(
            uuid,
            transactionId,
            billerName,
            billValue,
            DateTime.tryParse(data["date"].toString()) ??
                DateTime.parse("0000-00-00"),
            items,
          );

          bills.add(finalData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching receipts: $e');
    }

    return bills;
  }

  Future<BillData?> getReceipt(String id) async {
    try {
      final response = await Dio().get('$host/get-by-id/$id');
      debugPrint(response.data);

      String uuid = "";
      if (response.data["id"] != null) {
        uuid = response.data["id"].toString();
      }

      String billerName = "";
      if (response.data["biller_name"] != null) {
        billerName = response.data["biller_name"].toString();
      }

      double billValue = 0;
      if (response.data["bill_value"] != null) {
        billValue =
            double.tryParse(response.data["bill_value"].toString()) ?? 0;
      }

      String? transactionId;
      if (response.data["transaction_id"] != null) {
        transactionId = response.data["transaction_id"].toString();
      }

      List<BillItem> items = [];

      if (response.data["items"] is List) {
        for (var item in response.data["items"] as List) {
          if (item is Map<String, dynamic>) {
            String itemName = item["item"]?.toString() ?? '';
            String itemPrice = item["price"]?.toString() ?? '0.0';
            debugPrint("Price: $itemPrice");
            items.add(BillItem(itemName, double.tryParse(itemPrice) ?? 0.0));
          }
        }
      }

      BillData data = BillData(
        uuid,
        transactionId,
        billerName,
        billValue,
        DateTime.tryParse(response.data["date"].toString()) ??
            DateTime.parse("0000-00-00"),
        items,
      );

      return data;
    } catch (e) {
      debugPrint('Error fetching receipts: $e');
    }

    return null;
  }

  Future<bool> addReceipt(BillData data) async {
    debugPrint(data.toJson().toString());
    try {
      final response = await Dio().post(
        '$host/add-receipts',
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error fetching receipts: $e');
      return false;
    }
  }

  Future<bool> editReceipt(String id, BillData data) async {
    try {
      final response = await Dio().patch(
        '$host/update-receipts/$id',
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
        ),
        data: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error fetching receipts: $e');
      return false;
    }
  }
}
