import 'package:get/get.dart';
import '../controller/record_video_controller.dart';

class RecordVideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecordVideoController>(() => RecordVideoController(), fenix: true);
  }
}