import 'package:get/get.dart';
import 'package:wisemonster/view_model/newMem_view_model.dart';

class NewMemberController extends GetxController{
  @override
  void onInit() {
    print("onInit");
    super.onInit();

  }

  @override
  void onClose() {
    NewMemberViewModel model = NewMemberViewModel();
    model.timer.cancel();
    model.min.value = '0';
    model.sec.value = '0';
    super.onClose();
  }

}