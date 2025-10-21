class AddressDTO {
  final String? city;
  final String? neighborhood;
  final String? commune;
  final String? text;
  final String? postcode;
  final String? location;
  final int country;
  final String? references;

  AddressDTO({
    this.city,
    this.neighborhood,
    this.commune,
    this.text,
    this.postcode,
    this.location,
    required this.country,
    this.references,
  });

  factory AddressDTO.fromJson(Map<String, dynamic> json) => AddressDTO(
    city: json['City'],
    neighborhood: json['Neighborhood'],
    commune: json['Commune'],
    text: json['Text'],
    postcode: json['Postcode'],
    location: json['Location'],
    country: json['Country'] ?? 0,
    references: json['References'],
  );

  Map<String, dynamic> toJson() => {
    'City': city,
    'Neighborhood': neighborhood,
    'Commune': commune,
    'Text': text,
    'Postcode': postcode,
    'Location': location,
    'Country': country,
    'References': references,
  };
}
