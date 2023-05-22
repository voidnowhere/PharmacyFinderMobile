class Pharmacy {
  final String name;
  final String address;
  final String phoneNumber;
  final double latitude;
  final double longitude;

  const Pharmacy({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      name: json['name'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}
