class Zone {
  final int id;
  final String name;

  const Zone({
    required this.id,
    required this.name,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
