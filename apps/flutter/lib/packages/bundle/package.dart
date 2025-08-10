class Package {
  String title;
  String name;

  Package({required this.title, required this.name});

  factory Package.fromJson(Map<String, dynamic> data) {
    return Package(title: data['label'] as String, name: data['packageName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'label': title, 'packageName': name};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Package && other.name == name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }
}
