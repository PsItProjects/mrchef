import 'package:get/get.dart';
import 'package:mrsheaf/features/chat/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}

