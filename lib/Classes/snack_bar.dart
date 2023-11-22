import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBarController
    extends GetxService {
  // Function to show a snackbar with a message
  void showSnackBar(String message) {
    Get.snackbar(
      'Notification',
      message,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Function to show a success snackbar
  void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Function to show an error snackbar
  void showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
