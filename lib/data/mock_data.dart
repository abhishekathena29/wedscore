import 'package:flutter/material.dart';

import '../models/budget_category.dart';
import '../models/gallery_item.dart';
import '../models/task.dart';
import '../models/vendor.dart';

const List<String> cities = [
  'Jaipur',
  'Mumbai',
  'Delhi',
  'Udaipur',
  'Goa',
  'Bangalore',
  'Chennai',
  'Kolkata',
];

const List<String> categories = [
  'Photographer',
  'Venue',
  'Decorator',
  'Caterer',
  'Makeup Artist',
  'Mehendi Artist',
  'DJ & Music',
  'Planner',
];

const List<Vendor> _vendors = [
  Vendor(
    id: '1',
    name: 'Royal Frames Photography',
    category: 'Photographer',
    city: 'Jaipur',
    wedScore: 4.8,
    priceRange: 3,
    image: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=300&fit=crop',
    description: 'Capturing timeless moments with artistic flair and attention to detail.',
  ),
  Vendor(
    id: '2',
    name: 'The Taj Palace',
    category: 'Venue',
    city: 'Jaipur',
    wedScore: 4.9,
    priceRange: 4,
    image: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400&h=300&fit=crop',
    description: 'Majestic heritage venue with breathtaking architecture and royal ambiance.',
  ),
  Vendor(
    id: '3',
    name: 'Bloom & Petal Decor',
    category: 'Decorator',
    city: 'Mumbai',
    wedScore: 4.7,
    priceRange: 3,
    image: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=400&h=300&fit=crop',
    description: 'Creating enchanting floral arrangements and stunning wedding decor.',
  ),
  Vendor(
    id: '4',
    name: 'Spice Route Catering',
    category: 'Caterer',
    city: 'Delhi',
    wedScore: 4.6,
    priceRange: 2,
    image: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=400&h=300&fit=crop',
    description: 'Authentic Indian cuisine with a modern twist for memorable celebrations.',
  ),
  Vendor(
    id: '5',
    name: 'Glamour Studio',
    category: 'Makeup Artist',
    city: 'Mumbai',
    wedScore: 4.9,
    priceRange: 3,
    image: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400&h=300&fit=crop',
    description: 'Expert bridal makeup artists creating stunning, camera-ready looks.',
  ),
  Vendor(
    id: '6',
    name: 'Henna Dreams',
    category: 'Mehendi Artist',
    city: 'Jaipur',
    wedScore: 4.8,
    priceRange: 2,
    image: 'https://images.unsplash.com/photo-1595426482673-e786ad52a6a5?w=400&h=300&fit=crop',
    description: 'Intricate and beautiful mehendi designs for your special day.',
  ),
  Vendor(
    id: '7',
    name: 'Beats & Rhythm DJ',
    category: 'DJ & Music',
    city: 'Goa',
    wedScore: 4.5,
    priceRange: 2,
    image: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
    description: 'High-energy entertainment and seamless music for every celebration.',
  ),
  Vendor(
    id: '8',
    name: 'Dream Weddings Co.',
    category: 'Planner',
    city: 'Udaipur',
    wedScore: 4.9,
    priceRange: 4,
    image: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400&h=300&fit=crop',
    description: 'Full-service wedding planning with meticulous attention to detail.',
  ),
  Vendor(
    id: '9',
    name: 'Lens Magic Studios',
    category: 'Photographer',
    city: 'Mumbai',
    wedScore: 4.7,
    priceRange: 2,
    image: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400&h=300&fit=crop',
    description: 'Creative photography and cinematic videography for modern couples.',
  ),
  Vendor(
    id: '10',
    name: 'Garden of Eden',
    category: 'Venue',
    city: 'Bangalore',
    wedScore: 4.6,
    priceRange: 3,
    image: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400&h=300&fit=crop',
    description: 'Beautiful outdoor venue with lush gardens and elegant spaces.',
  ),
];

List<Vendor> seedVendors() => _vendors.map((vendor) => vendor.copyWith()).toList();

const List<BudgetCategory> budgetCategories = [
  BudgetCategory(
    id: '1',
    name: 'Venue',
    allocated: 500000,
    spent: 450000,
    icon: Icons.account_balance,
  ),
  BudgetCategory(
    id: '2',
    name: 'Catering',
    allocated: 300000,
    spent: 280000,
    icon: Icons.restaurant,
  ),
  BudgetCategory(
    id: '3',
    name: 'Photography',
    allocated: 150000,
    spent: 120000,
    icon: Icons.photo_camera,
  ),
  BudgetCategory(
    id: '4',
    name: 'Decoration',
    allocated: 200000,
    spent: 180000,
    icon: Icons.auto_awesome,
  ),
  BudgetCategory(
    id: '5',
    name: 'Attire',
    allocated: 250000,
    spent: 200000,
    icon: Icons.checkroom,
  ),
  BudgetCategory(
    id: '6',
    name: 'Makeup & Hair',
    allocated: 80000,
    spent: 75000,
    icon: Icons.brush,
  ),
  BudgetCategory(
    id: '7',
    name: 'Entertainment',
    allocated: 100000,
    spent: 50000,
    icon: Icons.music_note,
  ),
  BudgetCategory(
    id: '8',
    name: 'Miscellaneous',
    allocated: 120000,
    spent: 45000,
    icon: Icons.auto_awesome_mosaic,
  ),
];

const List<Task> _tasks = [
  Task(id: '1', title: 'Set wedding date', completed: true, timeline: '12 months', category: 'Planning'),
  Task(id: '2', title: 'Create guest list', completed: true, timeline: '12 months', category: 'Planning'),
  Task(id: '3', title: 'Book venue', completed: true, timeline: '10 months', category: 'Venue'),
  Task(id: '4', title: 'Hire wedding planner', completed: false, timeline: '10 months', category: 'Planning'),
  Task(id: '5', title: 'Choose wedding theme', completed: true, timeline: '9 months', category: 'Design'),
  Task(id: '6', title: 'Book photographer', completed: false, timeline: '8 months', category: 'Vendors'),
  Task(id: '7', title: 'Book caterer', completed: false, timeline: '8 months', category: 'Vendors'),
  Task(id: '8', title: 'Send save-the-dates', completed: false, timeline: '6 months', category: 'Invitations'),
  Task(id: '9', title: 'Book decorator', completed: false, timeline: '6 months', category: 'Vendors'),
  Task(id: '10', title: 'Choose wedding attire', completed: false, timeline: '5 months', category: 'Attire'),
  Task(id: '11', title: 'Book makeup artist', completed: false, timeline: '4 months', category: 'Vendors'),
  Task(id: '12', title: 'Finalize menu', completed: false, timeline: '3 months', category: 'Catering'),
  Task(id: '13', title: 'Send invitations', completed: false, timeline: '2 months', category: 'Invitations'),
  Task(id: '14', title: 'Final venue walkthrough', completed: false, timeline: '1 month', category: 'Venue'),
  Task(id: '15', title: 'Confirm all vendors', completed: false, timeline: '2 weeks', category: 'Vendors'),
];

List<Task> seedTasks() => _tasks.map((task) => task.copyWith()).toList();

const List<GalleryItem> galleryItems = [
  GalleryItem(
    id: '1',
    image: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&h=400&fit=crop',
    title: 'Royal Palace Wedding',
    style: 'Traditional',
    vendorName: 'Royal Frames Photography',
  ),
  GalleryItem(
    id: '2',
    image: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600&h=400&fit=crop',
    title: 'Garden Celebration',
    style: 'Modern',
    vendorName: 'Dream Weddings Co.',
  ),
  GalleryItem(
    id: '3',
    image: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=600&h=400&fit=crop',
    title: 'Beach Sunset Vows',
    style: 'Destination',
    vendorName: 'Lens Magic Studios',
  ),
  GalleryItem(
    id: '4',
    image: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600&h=400&fit=crop',
    title: 'Heritage Grandeur',
    style: 'Traditional',
    vendorName: 'The Taj Palace',
  ),
  GalleryItem(
    id: '5',
    image: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=600&h=400&fit=crop',
    title: 'Floral Fantasy',
    style: 'Romantic',
    vendorName: 'Bloom & Petal Decor',
  ),
  GalleryItem(
    id: '6',
    image: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600&h=400&fit=crop',
    title: 'Intimate Garden Party',
    style: 'Modern',
    vendorName: 'Garden of Eden',
  ),
];
