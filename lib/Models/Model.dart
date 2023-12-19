// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print

abstract class Model{
  Map<String, String> toMap();
  String getFilename();
  void clear();

  bool isEmpty(String value){
    if(value==null) {
      return false;
    }
    return (value.isNotEmpty)? true: false;
  }
}