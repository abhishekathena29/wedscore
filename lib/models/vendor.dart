class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.category,
    required this.city,
    required this.wedScore,
    required this.priceRange,
    required this.image,
    required this.description,
    this.shortlisted = false,
  });

  final String id;
  final String name;
  final String category;
  final String city;
  final double wedScore;
  final int priceRange;
  final String image;
  final String description;
  final bool shortlisted;

  Vendor copyWith({
    bool? shortlisted,
  }) {
    return Vendor(
      id: id,
      name: name,
      category: category,
      city: city,
      wedScore: wedScore,
      priceRange: priceRange,
      image: image,
      description: description,
      shortlisted: shortlisted ?? this.shortlisted,
    );
  }
}
