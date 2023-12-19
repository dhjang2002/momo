// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print
import 'Model.dart';

class Shops extends Model {
  String? id;              // 레코드번호
  String? users_id;        // 사용자 id: mb_no
  String? moims_id;        // 모임 id
  
  String? shop_name;       // 사업장이름
  String? shop_number;     // 사업자번호
  
  String? shop_addr;       // 사업장주소
  String? shop_addr_ext;   // 사업장주소
  String? shop_area;       // 지역(대전 서구, 천안시, 세종시 등)
  String? shop_addr_gps_latitude;   // 사업장주소 GPS
  String? shop_addr_gps_longitude;

  String? shop_tel;        // 가게전화번호
  String? shop_url;        // 홈페이지
  
  String? shop_category;   // 업종코드
  String? shop_tag;        // tag
  
  String? shop_grade;      // 평점
  String? shop_order;      // 정렬순서
  String? shop_desc;       // 사업장설명
  String? shop_thumnails;

  String? shop_data_ready; // 데이터준비(Y/N)
  String? shop_dist;
  String? created_at;      // 생성시각
  String? updated_at;      // 변경시각

  Shops({
    this.id="",
    this.users_id="",
    this.moims_id="",
    this.shop_name="",
    this.shop_number="",
    this.shop_addr="",
    this.shop_addr_ext="",
    this.shop_area="",
    this.shop_addr_gps_latitude="0",
    this.shop_addr_gps_longitude="0",
    this.shop_tel="",
    this.shop_url="",
    this.shop_category="",
    this.shop_tag="",
    this.shop_grade="0",
    this.shop_order="0",
    this.shop_desc="",
    this.shop_thumnails = "",
    this.shop_data_ready="", //this.reversed_flag="",
    this.created_at="",
    this.updated_at="",
    this.shop_dist = "",
  });

  factory Shops.fromJson(Map<String, dynamic> parsedJson)
  {
      return Shops(
        id: parsedJson['id'],
          users_id: parsedJson['users_id'],
          moims_id: parsedJson ['moims_id'],
          shop_name: parsedJson ['shop_name'],
          shop_number: parsedJson ['shop_number'],
          shop_addr: parsedJson ['shop_addr'],
          shop_addr_ext: parsedJson ['shop_addr_ext'],
          shop_area: parsedJson ['shop_area'],
          shop_addr_gps_longitude: parsedJson ['shop_addr_gps_longitude'],
          shop_addr_gps_latitude: parsedJson ['shop_addr_gps_latitude'],
          shop_tel: parsedJson ['shop_tel'],
          shop_url: parsedJson ['shop_url'],
          shop_category: parsedJson ['shop_category'],
          shop_tag: parsedJson ['shop_tag'],
          shop_grade: parsedJson ['shop_grade'],
          shop_order: parsedJson ['shop_order'],
          shop_desc: parsedJson ['shop_desc'],
          shop_thumnails: parsedJson ['shop_thumnails'],
          shop_data_ready: parsedJson ['shop_data_ready'],
          shop_dist: parsedJson ['shop_dist'],
          created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<Shops> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Shops.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Shops {id:$id, '
        'users_id:$users_id, '
        'moims_id:$moims_id, '
        'shop_name:$shop_name, '
        'shop_number:$shop_number, '
        'shop_addr:$shop_addr, '
        'shop_addr_ext:$shop_addr_ext, '
        'shop_addr_gps_latitude:$shop_addr_gps_latitude, '
        'shop_addr_gps_longitude:$shop_addr_gps_longitude,'
        'shop_tel:$shop_tel, '
        'shop_url:$shop_url, '
        'shop_area:$shop_area, '
        'shop_category:$shop_category, '
        'shop_tag:$shop_tag, '
        'shop_grade:$shop_grade, '
        'shop_order:$shop_order, '
        'shop_desc:$shop_desc, '
        'shop_thumnails:$shop_thumnails, '
        'shop_data_ready:$shop_data_ready, '
        'created_at:$created_at, '
        'updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'moims_id': moims_id.toString(),
    'shop_name': shop_name.toString(),
    'shop_number': shop_number.toString(),
    'shop_addr': shop_addr.toString(),
    'shop_addr_ext': shop_addr_ext.toString(),
    'shop_addr_gps_longitude': shop_addr_gps_longitude.toString(),
    'shop_addr_gps_latitude': shop_addr_gps_latitude.toString(),
    'shop_tel': shop_tel.toString(),
    'shop_url': shop_url.toString(),
    'shop_area': shop_area.toString(),
    'shop_category': shop_category.toString(),
    'shop_tag': shop_tag.toString(),
    'shop_grade': shop_grade.toString(),
    'shop_order': shop_order.toString(),
    'shop_desc': shop_desc.toString(),
    'shop_thumnails': shop_thumnails.toString(),
    'shop_data_ready': shop_data_ready.toString(),
    //'created_at': created_at.toString(),
    //'updated_at': updated_at.toString()
  };

  Map<String, String> toAddMap() => {
    'id': id.toString(),
    'users_id': users_id.toString(),
    'moims_id': moims_id.toString(),
    'shop_name': shop_name.toString(),
    'shop_number': shop_number.toString(),
    'shop_addr': shop_addr.toString(),
    'shop_addr_ext': shop_addr_ext.toString(),
    'shop_addr_gps_longitude': shop_addr_gps_longitude.toString(),
    'shop_addr_gps_latitude': shop_addr_gps_latitude.toString(),
    'shop_tel': shop_tel.toString(),
    'shop_url': shop_url.toString(),
    'shop_area': shop_area.toString(),
    'shop_category': shop_category.toString(),
    'shop_tag': shop_tag.toString(),
    'shop_grade': shop_grade.toString(),
    'shop_order': shop_order.toString(),
    'shop_desc': shop_desc.toString(),
    'shop_thumnails': shop_thumnails.toString(),
    'shop_data_ready': shop_data_ready.toString(),
  };

  @override
  String getFilename(){
    return "Shops.dat";
  }

  @override
  void clear() {
    // TODO: implement clear
  }
}