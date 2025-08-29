import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(() => TransactionController());
    Get.put<ScrollController>(ScrollController(), tag: 'transaction_scroll');
  }
}
