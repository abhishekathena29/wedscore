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
    this.contact,
    this.contacts = const [],
    this.profileName,
    this.link,
    this.remarks,
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
  final String? contact;
  final List<String> contacts;
  final String? profileName;
  final String? link;
  final String? remarks;
  final bool shortlisted;

  factory Vendor.fromMap(String id, Map<String, dynamic> data) {
    final priceValue = data['priceRange'];
    final priceRange =
        priceValue is int ? priceValue : (priceValue is num ? priceValue.toInt() : 0);
    final wedScoreValue = data['wedScore'];
    final wedScore =
        wedScoreValue is num ? wedScoreValue.toDouble() : double.tryParse('$wedScoreValue') ?? 0;
    final contactsRaw = data['contacts'];
    final contacts = contactsRaw is List
        ? contactsRaw.map((value) => value.toString()).toList()
        : const <String>[];
    return Vendor(
      id: id,
      name: (data['name'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      city: (data['city'] ?? '').toString(),
      wedScore: wedScore,
      priceRange: priceRange,
      image: (data['image'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      contact: data['contact']?.toString(),
      contacts: contacts,
      profileName: data['profileName']?.toString(),
      link: data['link']?.toString(),
      remarks: data['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'city': city,
      'wedScore': wedScore,
      'priceRange': priceRange,
      'image': image,
      'description': description,
      'contact': contact,
      'contacts': contacts,
      'profileName': profileName,
      'link': link,
      'remarks': remarks,
    };
  }

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
      contact: contact,
      contacts: contacts,
      profileName: profileName,
      link: link,
      remarks: remarks,
      shortlisted: shortlisted ?? this.shortlisted,
    );
  }
}
