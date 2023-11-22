import 'package:get/get.dart';

class UserController extends GetxController {
  RxString userRole = ''.obs;
  RxBool loggedIn = false.obs;

  setUserRole(String role) {
    userRole.value = role;
  }

  setLoggedIn(bool value) {
    loggedIn.value = value;
  }
}
