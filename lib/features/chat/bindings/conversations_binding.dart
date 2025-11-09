import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/controllers/conversations_controller.dart';

class ConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationsController>(() => ConversationsController());
  }
}

