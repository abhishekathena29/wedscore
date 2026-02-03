import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/vendor_seed.dart';
import '../models/vendor.dart';

class VendorImportService {
  VendorImportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<int> uploadAll() async {
    var totalUploaded = 0;
    final vendors = _buildVendorsFromSeed();
    for (final vendor in vendors) {
      await _firestore
          .collection('vendors')
          .doc(vendor.id)
          .set(vendor.toMap(), SetOptions(merge: true));
      totalUploaded += 1;
    }
    return totalUploaded;
  }

  List<Vendor> _buildVendorsFromSeed() {
    return vendorSeedData.map((row) {
      final name = row['name']?.trim() ?? '';
      final category = row['category']?.trim() ?? '';
      final location = row['location']?.trim() ?? '';
      final contact = row['contact']?.trim() ?? '';
      final profileName = row['profileName']?.trim() ?? '';
      final link = row['link']?.trim() ?? '';
      final remarks = row['remarks']?.trim() ?? '';
      final contacts = _parseContacts(contact);
      final normalizedContact = contacts.join(',');

      final city = _normalizeCity(location);
      final description = _buildDescription(
        contact: normalizedContact,
        profileName: profileName,
        link: link,
        remarks: remarks,
        category: category,
      );

      final vendorId = _slugify('$category-$city-$name');
      return Vendor(
        id: vendorId,
        name: name,
        category: category,
        city: city,
        wedScore: 4.5,
        priceRange: 2,
        image: _defaultImageForCategory(category),
        description: description,
        contact: normalizedContact.isEmpty ? null : normalizedContact,
        contacts: contacts,
        profileName: profileName.isEmpty ? null : profileName,
        link: link.isEmpty ? null : link,
        remarks: remarks.isEmpty ? null : remarks,
      );
    }).toList();
  }

  String _normalizeCity(String input) {
    final trimmed = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (trimmed.isEmpty) return 'Unknown';
    return trimmed
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  List<String> _parseContacts(String raw) {
    if (raw.trim().isEmpty) return [];
    final parts = raw.split(',');
    final contacts = <String>{};
    for (final part in parts) {
      final cleaned = part.replaceAll(RegExp(r'\\D'), '');
      if (cleaned.isEmpty) continue;
      contacts.add(cleaned);
    }
    return contacts.toList();
  }

  String _buildDescription({
    required String contact,
    required String profileName,
    required String link,
    required String remarks,
    required String category,
  }) {
    final parts = <String>[];
    if (contact.isNotEmpty) parts.add('Contact: $contact');
    if (profileName.isNotEmpty) parts.add('Profile: $profileName');
    if (link.isNotEmpty) parts.add('Link: $link');
    if (remarks.isNotEmpty) parts.add(remarks);
    if (parts.isEmpty) return 'Verified $category vendor.';
    return parts.join(' • ');
  }

  String _defaultImageForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'makeup artist':
        return 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400&h=300&fit=crop';
      case 'mehendi artist':
        return 'https://images.unsplash.com/photo-1595426482673-e786ad52a6a5?w=400&h=300&fit=crop';
      case 'caterers':
        return 'https://images.unsplash.com/photo-1555244162-803834f70033?w=400&h=300&fit=crop';
      case 'sweets shop':
      case 'chaat wale':
        return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop';
      case 'anchors':
        return 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400&h=300&fit=crop';
      case 'stationery designers':
        return 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop';
      case 'trousseau packers':
        return 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=300&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=300&fit=crop';
    }
  }

  String _slugify(String input) {
    final slug = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return slug.replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
