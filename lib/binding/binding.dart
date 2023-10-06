import 'package:get/get.dart';
import 'package:wisemonster/controller/splash_controller.dart';

import '../view_model/login_view_model.dart';

class SplahBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}
class LoginBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(LoginViewModel());
  }
}