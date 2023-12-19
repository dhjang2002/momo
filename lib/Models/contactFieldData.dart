class ContactFieldData {
  String? field;
  String? display;
  String? value;

  ContactFieldData({
    this.field   = "",
    this.display = "",
    this.value   = "",
  });

  Map<String, String> toValueMap() => {
    '$field': value.toString(),
  };
}