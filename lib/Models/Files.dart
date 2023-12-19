import 'Model.dart';

class Files extends Model {
  String? id;
  String? members_id;   // 레코드번호
  String? photo_id;                 
  String? photo_type;                
  String? name;                    
  String? path;
  String? url;
  String? thum_name;
  String? thum_path;
  String? thum_url;
  String? file_size;
  String? ext;
  String? created_at;
  String? updated_at;

  Files({this.id="", this.members_id="", this.photo_id="", this.photo_type="",
    this.name="", this.path="", this.url="",
    this.thum_name="", this.thum_path="", this.thum_url="",
    this.file_size="", this.ext="", this.created_at="",this.updated_at="",
  });

  factory Files.fromJson(Map<String, dynamic> parsedJson)
  {
      return Files(
        id: parsedJson['id'],
        photo_id: parsedJson['photo_id'],
        photo_type: parsedJson ['photo_type'],
        name: parsedJson ['name'],
        path: parsedJson ['path'],
        url: parsedJson ['url'],
        thum_name: parsedJson ['thum_name'],
        thum_path: parsedJson ['thum_path'],
        thum_url: parsedJson ['thum_url'],
        file_size: parsedJson ['file_size'],
          ext: parsedJson ['ext'],
        created_at: parsedJson ['created_at'],
          updated_at: parsedJson ['updated_at']
      );
    }

  static List<Files> fromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Files.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Files {id:$id, photo_id:$photo_id, photo_type:$photo_type, '
        'name:$name, path:$path, url:$url, '
        'thum_name:$thum_name, thum_path:$thum_path, thum_url:$thum_url, '
        'file_size:$file_size, ext:$ext, created_at:$created_at, updated_at:$updated_at}';
  }

  @override
  Map<String, String> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  @override
  String getFilename(){
    return "Files.dat";
  }

  @override
  void clear() {
    // TODO: implement clear
  }
}