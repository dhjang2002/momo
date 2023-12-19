class FieldData {
  String? field;
  String? display;
  String? value;

  FieldData({
    this.field   = "",
    this.display = "",
    this.value   = "",
  });

  Map<String, String> toValueMap() => {
    '$field': value.toString(),
  };
}