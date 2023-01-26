import 'package:get/get.dart';

class GetxControl extends GetxController {
  dynamic x;
    GetxControl({
     this.x
  });
  
  //imagelist için

  RxList imagelistname = [].obs;

 List<dynamic> imagelist() {
    x = imagelistname;
    return imagelistname.value as List;
  }
}
