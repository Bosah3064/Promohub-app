import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedSubcategory;
  final Function(String, String?) onCategoryChanged;
  final Function(List<Map<String, dynamic>>)? onPropertiesSelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    this.selectedSubcategory,
    required this.onCategoryChanged,
    this.onPropertiesSelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Vehicles',
      'icon': 'directions_car',
      'subcategories': [
        {
          'name': 'Cars',
          'properties': [
            {
              'name': 'Make',
              'values': [
                'Toyota',
                'Honda',
                'BMW',
                'Mercedes',
                'Nissan',
                'Ford',
                'Volkswagen',
                'Hyundai',
                'Kia',
                'Other'
              ],
              'allowCustom': true
            },
            {'name': 'Model', 'values': [], 'allowCustom': true},
            {
              'name': 'Year',
              'values': List.generate(30, (i) => (2025 - i).toString()),
              'allowCustom': false
            },
            {
              'name': 'Condition',
              'values': ['Brand New', 'Foreign Used', 'Locally Used'],
              'allowCustom': false
            },
            {
              'name': 'Transmission',
              'values': ['Automatic', 'Manual'],
              'allowCustom': false
            },
            {
              'name': 'Fuel Type',
              'values': ['Petrol', 'Diesel', 'Electric', 'Hybrid', 'Other'],
              'allowCustom': true
            },
            {'name': 'Mileage (km)', 'values': [], 'allowCustom': true},
            {
              'name': 'Body Type',
              'values': [
                'Sedan',
                'SUV',
                'Hatchback',
                'Pickup',
                'Coupe',
                'Convertible',
                'Minivan'
              ],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Motorcycles & Scooters',
          'properties': [
            {
              'name': 'Brand',
              'values': [
                'Yamaha',
                'Honda',
                'Kawasaki',
                'Suzuki',
                'Bajaj',
                'TVS',
                'Other'
              ],
              'allowCustom': true
            },
            {'name': 'Model', 'values': [], 'allowCustom': true},
            {
              'name': 'Year',
              'values': List.generate(20, (i) => (2025 - i).toString()),
              'allowCustom': false
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
            {
              'name': 'Engine Capacity',
              'values': [
                '50cc',
                '125cc',
                '150cc',
                '250cc',
                '400cc',
                '600cc',
                '1000cc',
                'Other'
              ],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Trucks & Commercial Vehicles',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Pickup',
                'Lorry',
                'Tipper',
                'Tanker',
                'Trailer',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Make',
              'values': [
                'Toyota',
                'Isuzu',
                'Mitsubishi',
                'Mercedes',
                'MAN',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Capacity',
              'values': [
                '1 Ton',
                '3 Ton',
                '5 Ton',
                '10 Ton',
                '15 Ton',
                'Other'
              ],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Buses & Minibuses',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Minibus',
                'Coaster',
                'School Bus',
                'Luxury Bus',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Seats',
              'values': ['14', '22', '30', '50', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Vehicle Parts & Accessories',
          'properties': [
            {
              'name': 'Part Type',
              'values': [
                'Engine',
                'Transmission',
                'Brakes',
                'Suspension',
                'Lights',
                'Body Parts',
                'Tyres',
                'Batteries',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Compatibility',
              'values': ['Make Specific', 'Universal'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Boats & Watercraft',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Speedboat',
                'Fishing Boat',
                'Yacht',
                'Canoe',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Length',
              'values': ['<10 ft', '10-20 ft', '20-30 ft', '30+ ft'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Real Estate',
      'icon': 'home',
      'subcategories': [
        {
          'name': 'Houses & Apartments for Sale',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'House',
                'Apartment',
                'Duplex',
                'Townhouse',
                'Villa',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Bedrooms',
              'values': ['1', '2', '3', '4', '5+'],
              'allowCustom': false
            },
            {
              'name': 'Bathrooms',
              'values': ['1', '2', '3', '4+'],
              'allowCustom': false
            },
            {
              'name': 'Furnished',
              'values': ['Fully', 'Semi', 'Unfurnished'],
              'allowCustom': false
            },
            {'name': 'Size (sq ft)', 'values': [], 'allowCustom': true},
            {
              'name': 'Listing Type',
              'values': ['For Sale', 'Auction'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Houses & Apartments for Rent',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'House',
                'Apartment',
                'Duplex',
                'Townhouse',
                'Villa',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Bedrooms',
              'values': ['1', '2', '3', '4', '5+'],
              'allowCustom': false
            },
            {
              'name': 'Bathrooms',
              'values': ['1', '2', '3', '4+'],
              'allowCustom': false
            },
            {
              'name': 'Furnished',
              'values': ['Fully', 'Semi', 'Unfurnished'],
              'allowCustom': false
            },
            {
              'name': 'Rent Period',
              'values': ['Monthly', 'Yearly', 'Daily'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Land & Plots',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Residential',
                'Commercial',
                'Agricultural',
                'Industrial'
              ],
              'allowCustom': false
            },
            {
              'name': 'Size',
              'values': [
                '50x100 ft',
                '100x100 ft',
                '1/2 acre',
                '1 acre',
                '5 acres',
                '10+ acres'
              ],
              'allowCustom': true
            },
            {
              'name': 'Title',
              'values': ['Freehold', 'Leasehold', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Short Term Rentals',
          'properties': [
            {
              'name': 'Type',
              'values': ['Apartment', 'House', 'Villa', 'Guesthouse', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Bedrooms',
              'values': ['1', '2', '3', '4+'],
              'allowCustom': false
            },
            {
              'name': 'Minimum Stay',
              'values': ['1 night', '1 week', '1 month'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Commercial Property',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Office',
                'Shop',
                'Warehouse',
                'Hotel',
                'Restaurant',
                'Other'
              ],
              'allowCustom': true
            },
            {'name': 'Size (sq ft)', 'values': [], 'allowCustom': true},
            {
              'name': 'Purpose',
              'values': ['Sale', 'Rent', 'Lease'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Electronics',
      'icon': 'devices',
      'subcategories': [
        {
          'name': 'Phones & Tablets',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Smartphone',
                'Feature Phone',
                'Tablet',
                'Smart Watch'
              ],
              'allowCustom': false
            },
            {
              'name': 'Brand',
              'values': [
                'Apple',
                'Samsung',
                'Tecno',
                'Infinix',
                'Huawei',
                'Nokia',
                'Other'
              ],
              'allowCustom': true
            },
            {'name': 'Model', 'values': [], 'allowCustom': true},
            {
              'name': 'Condition',
              'values': ['New', 'Refurbished', 'Used'],
              'allowCustom': false
            },
            {
              'name': 'Storage',
              'values': [
                '16GB',
                '32GB',
                '64GB',
                '128GB',
                '256GB',
                '512GB',
                '1TB'
              ],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Computers & Laptops',
          'properties': [
            {
              'name': 'Type',
              'values': ['Laptop', 'Desktop', 'All-in-One', 'Server', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': [
                'Apple',
                'HP',
                'Dell',
                'Lenovo',
                'Asus',
                'Acer',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Processor',
              'values': [
                'Intel Core i3',
                'i5',
                'i7',
                'i9',
                'AMD Ryzen 3',
                '5',
                '7',
                '9'
              ],
              'allowCustom': true
            },
            {
              'name': 'RAM',
              'values': ['4GB', '8GB', '16GB', '32GB', '64GB'],
              'allowCustom': true
            },
            {
              'name': 'Storage',
              'values': ['HDD', 'SSD', 'Hybrid'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'TVs & Home Theater',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Smart TV',
                'LED TV',
                'OLED TV',
                'Home Theater System',
                'Projector'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['Samsung', 'LG', 'Sony', 'TCL', 'Hisense', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Size',
              'values': ['32"', '40"', '50"', '55"', '65"', '75"', '85"'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Cameras & Photography',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'DSLR',
                'Mirrorless',
                'Point & Shoot',
                'Action Camera',
                'Drone'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': [
                'Canon',
                'Nikon',
                'Sony',
                'Fujifilm',
                'GoPro',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Resolution',
              'values': ['12MP', '20MP', '24MP', '30MP+'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Audio & MP3',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Headphones',
                'Earphones',
                'Speaker',
                'Sound System',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['JBL', 'Sony', 'Bose', 'Beats', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Connectivity',
              'values': ['Wired', 'Bluetooth', 'Both'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Gaming',
          'properties': [
            {
              'name': 'Type',
              'values': ['Console', 'Games', 'Accessories', 'VR Headset'],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['PlayStation', 'Xbox', 'Nintendo', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Model',
              'values': ['PS5', 'PS4', 'Xbox Series X', 'Switch', 'Other'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Jobs',
      'icon': 'work',
      'subcategories': [
        {
          'name': 'Accounting & Finance',
          'properties': [
            {
              'name': 'Job Type',
              'values': ['Full-time', 'Part-time', 'Contract', 'Internship'],
              'allowCustom': false
            },
            {
              'name': 'Experience',
              'values': ['Entry Level', 'Mid Level', 'Senior', 'Executive'],
              'allowCustom': false
            },
            {
              'name': 'Salary Period',
              'values': ['Monthly', 'Weekly', 'Daily', 'Project-based'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Administrative',
          'properties': [
            {
              'name': 'Job Type',
              'values': ['Full-time', 'Part-time', 'Contract', 'Temporary'],
              'allowCustom': false
            },
            {
              'name': 'Role',
              'values': [
                'Secretary',
                'Receptionist',
                'Office Assistant',
                'Data Entry'
              ],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Agriculture',
          'properties': [
            {
              'name': 'Job Type',
              'values': ['Full-time', 'Seasonal', 'Contract'],
              'allowCustom': false
            },
            {
              'name': 'Role',
              'values': ['Farm Manager', 'Laborer', 'Technician', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Customer Service',
          'properties': [
            {
              'name': 'Job Type',
              'values': ['Full-time', 'Part-time', 'Remote'],
              'allowCustom': false
            },
            {
              'name': 'Industry',
              'values': ['Retail', 'Hospitality', 'Call Center', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'IT & Telecoms',
          'properties': [
            {
              'name': 'Job Type',
              'values': ['Full-time', 'Contract', 'Freelance', 'Remote'],
              'allowCustom': false
            },
            {
              'name': 'Role',
              'values': [
                'Developer',
                'Network Engineer',
                'Data Analyst',
                'Cybersecurity'
              ],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Services',
      'icon': 'construction',
      'subcategories': [
        {
          'name': 'Cleaning',
          'properties': [
            {
              'name': 'Type',
              'values': ['Home', 'Office', 'Carpet', 'Window', 'After Party'],
              'allowCustom': true
            },
            {
              'name': 'Frequency',
              'values': ['One-time', 'Daily', 'Weekly', 'Monthly'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Moving & Relocation',
          'properties': [
            {
              'name': 'Service Type',
              'values': ['Local Move', 'International', 'Packing', 'Storage'],
              'allowCustom': true
            },
            {
              'name': 'Vehicle',
              'values': ['Pickup', 'Truck', 'Van', 'Container'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Repairs & Maintenance',
          'properties': [
            {
              'name': 'Category',
              'values': [
                'Electronics',
                'Appliances',
                'Plumbing',
                'Electrical',
                'Furniture'
              ],
              'allowCustom': true
            },
            {
              'name': 'Service Type',
              'values': ['Home', 'Office', 'Industrial'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Health & Beauty',
          'properties': [
            {
              'name': 'Service Type',
              'values': ['Hair', 'Nails', 'Massage', 'Makeup', 'Barber'],
              'allowCustom': true
            },
            {
              'name': 'Location',
              'values': ['Salon', 'Mobile', 'Home Service'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Education & Training',
          'properties': [
            {
              'name': 'Subject',
              'values': ['Academic', 'Language', 'Music', 'IT', 'Vocational'],
              'allowCustom': true
            },
            {
              'name': 'Format',
              'values': ['In-person', 'Online', 'Hybrid'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Fashion',
      'icon': 'checkroom',
      'subcategories': [
        {
          'name': "Men's Clothing",
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Shirts',
                'Trousers',
                'Suits',
                'Jackets',
                'Traditional'
              ],
              'allowCustom': true
            },
            {
              'name': 'Size',
              'values': ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': "Women's Clothing",
          'properties': [
            {
              'name': 'Type',
              'values': ['Dresses', 'Tops', 'Skirts', 'Jeans', 'Traditional'],
              'allowCustom': true
            },
            {
              'name': 'Size',
              'values': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Footwear',
          'properties': [
            {
              'name': 'Gender',
              'values': ["Men's", "Women's", "Unisex", "Kids"],
              'allowCustom': false
            },
            {
              'name': 'Type',
              'values': ['Sneakers', 'Sandals', 'Formal', 'Boots', 'Sports'],
              'allowCustom': true
            },
            {'name': 'Size', 'values': [], 'allowCustom': true},
          ]
        },
        {
          'name': 'Watches & Jewelry',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Watches',
                'Necklaces',
                'Rings',
                'Bracelets',
                'Earrings'
              ],
              'allowCustom': true
            },
            {
              'name': 'Material',
              'values': ['Gold', 'Silver', 'Diamond', 'Leather', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Bags & Accessories',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Handbags',
                'Backpacks',
                'Wallets',
                'Belts',
                'Sunglasses'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['Gucci', 'Louis Vuitton', 'Local', 'Other'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Home & Garden',
      'icon': 'home_work',
      'subcategories': [
        {
          'name': 'Furniture',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Sofa',
                'Bed',
                'Dining Set',
                'Wardrobe',
                'Office Furniture'
              ],
              'allowCustom': true
            },
            {
              'name': 'Material',
              'values': ['Wood', 'Metal', 'Plastic', 'Fabric', 'Leather'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Home Appliances',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Refrigerator',
                'Cooker',
                'Washing Machine',
                'Microwave',
                'Air Conditioner'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['LG', 'Samsung', 'Midea', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Home Decor',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Curtains',
                'Carpets',
                'Paintings',
                'Wallpaper',
                'Lighting'
              ],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Garden & Outdoor',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Plants',
                'Furniture',
                'Tools',
                'Grills',
                'Pool Equipment'
              ],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Kitchenware',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Cookware',
                'Cutlery',
                'Dinnerware',
                'Small Appliances'
              ],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    // Additional categories would continue here...
    {
      'name': 'Sports & Fitness',
      'icon': 'fitness_center',
      'subcategories': [
        {
          'name': 'Exercise Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Treadmill',
                'Dumbbells',
                'Exercise Bike',
                'Yoga Mat',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Team Sports',
          'properties': [
            {
              'name': 'Sport',
              'values': [
                'Football',
                'Basketball',
                'Volleyball',
                'Cricket',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Equipment Type',
              'values': ['Balls', 'Nets', 'Goals', 'Protective Gear'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Pets',
      'icon': 'pets',
      'subcategories': [
        {
          'name': 'Dogs',
          'properties': [
            {
              'name': 'Breed',
              'values': [
                'Local',
                'German Shepherd',
                'Rottweiler',
                'Labrador',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Age',
              'values': ['Puppy', 'Adult', 'Senior'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Cats',
          'properties': [
            {
              'name': 'Breed',
              'values': ['Local', 'Persian', 'Siamese', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Age',
              'values': ['Kitten', 'Adult', 'Senior'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Pet Supplies',
          'properties': [
            {
              'name': 'Type',
              'values': ['Food', 'Cages', 'Toys', 'Grooming', 'Health'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Food & Agriculture',
      'icon': 'restaurant',
      'subcategories': [
        {
          'name': 'Fresh Produce',
          'properties': [
            {
              'name': 'Type',
              'values': ['Fruits', 'Vegetables', 'Grains', 'Tubers'],
              'allowCustom': true
            },
            {
              'name': 'Quantity',
              'values': ['Per Kg', 'Per Sack', 'Per Piece'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Livestock',
          'properties': [
            {
              'name': 'Type',
              'values': ['Cattle', 'Goats', 'Sheep', 'Poultry', 'Pigs'],
              'allowCustom': true
            },
            {
              'name': 'Age',
              'values': ['Young', 'Adult'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Farm Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': ['Tractors', 'Plows', 'Harvesters', 'Irrigation'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Business Equipment',
      'icon': 'business',
      'subcategories': [
        {
          'name': 'Office Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': ['Printers', 'Copiers', 'Projectors', 'Shredders'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Industrial Machinery',
          'properties': [
            {
              'name': 'Type',
              'values': ['Manufacturing', 'Packaging', 'Construction', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Art & Collectibles',
      'icon': 'palette',
      'subcategories': [
        {
          'name': 'Art',
          'properties': [
            {
              'name': 'Type',
              'values': ['Paintings', 'Sculptures', 'Photography', 'Digital'],
              'allowCustom': true
            },
            {
              'name': 'Originality',
              'values': ['Original', 'Reproduction'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Collectibles',
          'properties': [
            {
              'name': 'Type',
              'values': ['Coins', 'Stamps', 'Comics', 'Memorabilia'],
              'allowCustom': true
            },
            {
              'name': 'Era',
              'values': ['Vintage', 'Modern'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Health & Beauty',
      'icon': 'spa',
      'subcategories': [
        {
          'name': 'Makeup & Cosmetics',
          'properties': [
            {
              'name': 'Type',
              'values': [
                'Foundation',
                'Lipstick',
                'Eyeshadow',
                'Skincare',
                'Other'
              ],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['MAC', 'Maybelline', 'L\'Oreal', 'Local', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Unused', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Hair Care',
          'properties': [
            {
              'name': 'Type',
              'values': ['Extensions', 'Wigs', 'Products', 'Tools'],
              'allowCustom': true
            },
            {
              'name': 'Hair Type',
              'values': ['Human', 'Synthetic', 'Mixed'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Fragrances',
          'properties': [
            {
              'name': 'Type',
              'values': ['Perfume', 'Cologne', 'Body Spray'],
              'allowCustom': false
            },
            {
              'name': 'Size',
              'values': ['50ml', '100ml', '200ml', 'Other'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Baby & Kids',
      'icon': 'child_care',
      'subcategories': [
        {
          'name': 'Baby Gear',
          'properties': [
            {
              'name': 'Type',
              'values': ['Strollers', 'Car Seats', 'Cribs', 'High Chairs'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Like New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Toys & Games',
          'properties': [
            {
              'name': 'Age Range',
              'values': ['0-1', '1-3', '3-5', '5-10', '10+'],
              'allowCustom': false
            },
            {
              'name': 'Type',
              'values': ['Educational', 'Action Figures', 'Dolls', 'Outdoor'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Kids Clothing',
          'properties': [
            {
              'name': 'Age Range',
              'values': ['Newborn', '0-2', '2-5', '5-10', '10-15'],
              'allowCustom': false
            },
            {
              'name': 'Gender',
              'values': ['Boys', 'Girls', 'Unisex'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Books & Education',
      'icon': 'menu_book',
      'subcategories': [
        {
          'name': 'Textbooks',
          'properties': [
            {
              'name': 'Subject',
              'values': ['Math', 'Science', 'Literature', 'History', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Level',
              'values': ['Primary', 'Secondary', 'University'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Fiction',
          'properties': [
            {
              'name': 'Genre',
              'values': ['Romance', 'Thriller', 'Sci-Fi', 'Fantasy', 'Other'],
              'allowCustom': true
            },
            {
              'name': 'Format',
              'values': ['Paperback', 'Hardcover', 'E-book'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Non-Fiction',
          'properties': [
            {
              'name': 'Category',
              'values': ['Biography', 'Self-Help', 'Business', 'Religion'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Music & Instruments',
      'icon': 'music_note',
      'subcategories': [
        {
          'name': 'Instruments',
          'properties': [
            {
              'name': 'Type',
              'values': ['Guitar', 'Piano', 'Drums', 'Violin', 'Wind'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'DJ Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': ['Mixer', 'Turntable', 'Controller', 'Speakers'],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['Pioneer', 'Numark', 'Denon', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Music Media',
          'properties': [
            {
              'name': 'Format',
              'values': ['CD', 'Vinyl', 'Cassette', 'Digital'],
              'allowCustom': false
            },
            {
              'name': 'Genre',
              'values': ['Afrobeats', 'Hip Hop', 'Gospel', 'Reggae', 'Other'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Construction & Heavy Equipment',
      'icon': 'construction',
      'subcategories': [
        {
          'name': 'Heavy Machinery',
          'properties': [
            {
              'name': 'Type',
              'values': ['Excavator', 'Bulldozer', 'Crane', 'Forklift'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Building Materials',
          'properties': [
            {
              'name': 'Type',
              'values': ['Cement', 'Blocks', 'Rods', 'Roofing'],
              'allowCustom': true
            },
            {
              'name': 'Quantity',
              'values': ['Per Bag', 'Per Ton', 'Per Piece'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Tools',
          'properties': [
            {
              'name': 'Type',
              'values': ['Power Tools', 'Hand Tools', 'Measuring', 'Safety'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Industrial Equipment',
      'icon': 'factory',
      'subcategories': [
        {
          'name': 'Manufacturing',
          'properties': [
            {
              'name': 'Type',
              'values': ['Machinery', 'Molds', 'Packaging', 'Conveyors'],
              'allowCustom': true
            },
            {
              'name': 'Industry',
              'values': ['Food', 'Textile', 'Plastic', 'Metal'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Storage',
          'properties': [
            {
              'name': 'Type',
              'values': ['Shelving', 'Racking', 'Containers', 'Pallets'],
              'allowCustom': true
            },
            {
              'name': 'Material',
              'values': ['Metal', 'Wood', 'Plastic'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Office Supplies',
      'icon': 'description',
      'subcategories': [
        {
          'name': 'Stationery',
          'properties': [
            {
              'name': 'Type',
              'values': ['Pens', 'Notebooks', 'Paper', 'Folders'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Office Furniture',
          'properties': [
            {
              'name': 'Type',
              'values': ['Desks', 'Chairs', 'Filing Cabinets', 'Tables'],
              'allowCustom': true
            },
            {
              'name': 'Material',
              'values': ['Wood', 'Metal', 'Glass'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Security',
      'icon': 'security',
      'subcategories': [
        {
          'name': 'Surveillance',
          'properties': [
            {
              'name': 'Type',
              'values': ['CCTV', 'Alarms', 'Access Control'],
              'allowCustom': true
            },
            {
              'name': 'Brand',
              'values': ['Hikvision', 'Dahua', 'Other'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Safes',
          'properties': [
            {
              'name': 'Type',
              'values': ['Home', 'Office', 'Wall', 'Floor'],
              'allowCustom': true
            },
            {
              'name': 'Size',
              'values': ['Small', 'Medium', 'Large'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Agriculture',
      'icon': 'agriculture',
      'subcategories': [
        {
          'name': 'Farm Inputs',
          'properties': [
            {
              'name': 'Type',
              'values': ['Seeds', 'Fertilizers', 'Pesticides', 'Animal Feed'],
              'allowCustom': true
            },
            {
              'name': 'Quantity',
              'values': ['Per Kg', 'Per Bag', 'Per Liter'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Farming Tools',
          'properties': [
            {
              'name': 'Type',
              'values': ['Hand Tools', 'Irrigation', 'Harvesting'],
              'allowCustom': true
            },
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Energy & Solar',
      'icon': 'solar_power',
      'subcategories': [
        {
          'name': 'Solar Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': ['Panels', 'Inverters', 'Batteries', 'Lights'],
              'allowCustom': true
            },
            {
              'name': 'Capacity',
              'values': ['100W', '200W', '500W', '1KW+'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Generators',
          'properties': [
            {
              'name': 'Type',
              'values': ['Diesel', 'Petrol', 'Gas', 'Inverter'],
              'allowCustom': false
            },
            {
              'name': 'Power',
              'values': ['2KVA', '5KVA', '10KVA', '20KVA+'],
              'allowCustom': true
            },
          ]
        },
      ],
    },
    {
      'name': 'Events & Entertainment',
      'icon': 'celebration',
      'subcategories': [
        {
          'name': 'Event Services',
          'properties': [
            {
              'name': 'Type',
              'values': ['Catering', 'Photography', 'MC', 'Decor'],
              'allowCustom': true
            },
            {
              'name': 'Event Type',
              'values': ['Wedding', 'Birthday', 'Corporate'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Event Equipment',
          'properties': [
            {
              'name': 'Type',
              'values': ['Tents', 'Chairs', 'Sound', 'Lighting'],
              'allowCustom': true
            },
            {
              'name': 'Rental Period',
              'values': ['Per Day', 'Per Hour', 'Weekly'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Travel & Tourism',
      'icon': 'flight',
      'subcategories': [
        {
          'name': 'Vacation Packages',
          'properties': [
            {
              'name': 'Destination',
              'values': ['Local', 'International'],
              'allowCustom': true
            },
            {
              'name': 'Package Type',
              'values': ['Honeymoon', 'Family', 'Adventure'],
              'allowCustom': true
            },
          ]
        },
        {
          'name': 'Travel Services',
          'properties': [
            {
              'name': 'Type',
              'values': ['Visa Assistance', 'Tickets', 'Tours'],
              'allowCustom': true
            },
            {
              'name': 'Service Area',
              'values': ['Domestic', 'International'],
              'allowCustom': false
            },
          ]
        },
      ],
    },
    {
      'name': 'Miscellaneous',
      'icon': 'apps',
      'subcategories': [
        {
          'name': 'Other Items',
          'properties': [
            {'name': 'Description', 'values': [], 'allowCustom': true},
            {
              'name': 'Condition',
              'values': ['New', 'Used'],
              'allowCustom': false
            },
          ]
        },
        {
          'name': 'Free Stuff',
          'properties': [
            {'name': 'Item Type', 'values': [], 'allowCustom': true},
          ]
        },
      ],
    },
  ];
  Map<String, dynamic>? _selectedSubcategoryData;
  List<Map<String, dynamic>> _selectedProperties = [];
  Map<String, dynamic> _propertyValues = {};

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Select Category',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected =
                        widget.selectedCategory == category['name'];

                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                                  .withOpacity(0.1)
                              : AppTheme.lightTheme.colorScheme.surface
                                  .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: category['icon'],
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        category['name'],
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.textTheme.titleMedium?.color,
                        ),
                      ),
                      trailing: CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onTap: () => _showSubcategoryPicker(category),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubcategoryPicker(Map<String, dynamic> category) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCategoryPicker();
                    },
                    icon: CustomIconWidget(
                      iconName: 'arrow_back',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      category['name'],
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: (category['subcategories'] as List).length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withOpacity(0.2),
                  ),
                  itemBuilder: (context, index) {
                    final subcategory = (category['subcategories']
                        as List)[index] as Map<String, dynamic>;
                    final isSelected =
                        widget.selectedSubcategory == subcategory['name'];

                    return ListTile(
                      title: Text(
                        subcategory['name'],
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.lightTheme.primaryColor
                              : AppTheme
                                  .lightTheme.textTheme.titleMedium?.color,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.primaryColor,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedSubcategoryData = subcategory;
                          _selectedProperties =
                              List.from(subcategory['properties'] ?? []);
                          _propertyValues =
                              {}; // Reset property values when subcategory changes
                        });
                        widget.onCategoryChanged(
                            category['name'], subcategory['name']);
                        Navigator.pop(context);
                        _showProperties(); // Show properties after selection
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProperties() {
    if (_selectedSubcategoryData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSubcategoryPicker(categories.firstWhere(
                            (cat) => cat['name'] == widget.selectedCategory));
                      },
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.selectedCategory} - ${widget.selectedSubcategory}',
                        style: AppTheme.lightTheme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedProperties.length,
                    itemBuilder: (context, index) {
                      final property = _selectedProperties[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property['name'],
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            ),
                            SizedBox(height: 1.h),
                            _buildPropertyInput(property, setState),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2.h, top: 2.h),
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.onPropertiesSelected != null) {
                        widget.onPropertiesSelected!(_selectedProperties);
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Save Properties'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyInput(
      Map<String, dynamic> property, StateSetter setState) {
    final propertyName = property['name'];
    final currentValue = _propertyValues[propertyName] ?? '';
    final allowCustom = property['allowCustom'] ?? false;
    final values = List.from(property['values'] ?? []);

    if (values.isEmpty || allowCustom) {
      return TextFormField(
        decoration: InputDecoration(
          hintText: 'Enter ${property['name']}',
          border: OutlineInputBorder(),
        ),
        initialValue: currentValue is String ? currentValue : '',
        onChanged: (value) {
          setState(() {
            _propertyValues[propertyName] = value;
          });
          // Update the property in _selectedProperties
          final index =
              _selectedProperties.indexWhere((p) => p['name'] == propertyName);
          if (index != -1) {
            _selectedProperties[index]['value'] = value;
          }
        },
      );
    } else {
      return DropdownButtonFormField<String>(
        value: currentValue.isNotEmpty ? currentValue : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select ${property['name']}',
        ),
        items: values.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _propertyValues[propertyName] = value;
          });
          // Update the property in _selectedProperties
          final index =
              _selectedProperties.indexWhere((p) => p['name'] == propertyName);
          if (index != -1) {
            _selectedProperties[index]['value'] = value;
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'category',
              color: AppTheme.lightTheme.primaryColor,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  widget.selectedCategory != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.selectedCategory!,
                              style: AppTheme.lightTheme.textTheme.titleMedium,
                            ),
                            if (widget.selectedSubcategory != null) ...[
                              SizedBox(height: 0.5.h),
                              Text(
                                widget.selectedSubcategory!,
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          'Select a category',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
