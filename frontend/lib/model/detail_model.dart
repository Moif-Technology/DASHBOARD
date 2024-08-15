class DetailModel {
  final String icon;
  final String value;
  final String title;
  final String? value2;
  final String? title2;
  final String? value3;
  final String? title3;

  const DetailModel({
    required this.icon,
    required this.value,
    required this.title,
    this.value2,
    this.title2,
    this.value3,
    this.title3,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      icon: json['icon'],
      value: json['value'],
      title: json['title'],
      value2: json['value2'],
      title2: json['title2'],
      value3: json['value3'],
      title3: json['title3'],
    );
  }
}
