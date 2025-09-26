import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterPanelWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onApplyFilters;
  final VoidCallback onClose;

  const FilterPanelWidget({
    super.key,
    required this.onApplyFilters,
    required this.onClose,
  });

  @override
  State<FilterPanelWidget> createState() => _FilterPanelWidgetState();
}

class _FilterPanelWidgetState extends State<FilterPanelWidget> {
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 2000);
  String? _selectedCondition;
  double _locationRadius = 5.0;
  String? _selectedDatePosted;
  String? _selectedSellerType;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Vehicles',
      'icon': 'directions_car',
      'subcategories': [
        'Cars',
        'Motorcycles',
        'Trucks',
        'Buses',
        'Spare Parts',
        'Other Vehicles'
      ],
    },
    {
      'name': 'Real Estate',
      'icon': 'home',
      'subcategories': [
        'Houses for Sale',
        'Houses for Rent',
        'Apartments',
        'Land',
        'Commercial',
        'Vacation Rentals'
      ],
    },
    {
      'name': 'Electronics',
      'icon': 'smartphone',
      'subcategories': [
        'Mobile Phones',
        'Computers',
        'TV & Audio',
        'Gaming',
        'Cameras',
        'Accessories'
      ],
    },
    {
      'name': 'Jobs',
      'icon': 'work',
      'subcategories': [
        'Full-time',
        'Part-time',
        'Contract',
        'Internship',
        'Remote',
        'Freelance'
      ],
    },
    {
      'name': 'Services',
      'icon': 'build',
      'subcategories': [
        'Home Services',
        'Beauty & Wellness',
        'Education',
        'Events',
        'Professional',
        'Other Services'
      ],
    },
    {
      'name': 'Fashion',
      'icon': 'checkroom',
      'subcategories': [
        'Men\'s Clothing',
        'Women\'s Clothing',
        'Shoes',
        'Bags',
        'Accessories',
        'Kids Fashion'
      ],
    },
    {
      'name': 'Home & Garden',
      'icon': 'home_work',
      'subcategories': [
        'Furniture',
        'Appliances',
        'Garden',
        'Decor',
        'Kitchen',
        'Tools'
      ],
    },
    {
      'name': 'Sports & Hobbies',
      'icon': 'sports_soccer',
      'subcategories': [
        'Sports Equipment',
        'Fitness',
        'Outdoor',
        'Books',
        'Music',
        'Collectibles'
      ],
    },
    {
      'name': 'Education',
      'icon': 'school',
      'subcategories': [
        'Books & Study Materials',
        'Online Courses',
        'Tutoring',
        'School Supplies',
        'Language Classes',
        'Workshops'
      ],
    },
    {
      'name': 'Travel & Tourism',
      'icon': 'flight',
      'subcategories': [
        'Tour Packages',
        'Hotels & Stays',
        'Flights',
        'Travel Accessories',
        'Visa Services',
        'Local Guides'
      ],
    },
    {
      'name': 'Health & Fitness',
      'icon': 'fitness_center',
      'subcategories': [
        'Gym Equipment',
        'Supplements',
        'Personal Training',
        'Yoga & Meditation',
        'Health Devices',
        'Wellness Programs'
      ],
    },
    {
      'name': 'Entertainment',
      'icon': 'movie',
      'subcategories': [
        'Movies',
        'Concerts',
        'Events',
        'Tickets',
        'Streaming Services',
        'Merchandise'
      ],
    },
    {
      'name': 'Animals & Livestock',
      'icon': 'pets',
      'subcategories': [
        'Farm Animals',
        'Pet Supplies',
        'Animal Feed',
        'Veterinary Services',
        'Adoption',
        'Animal Accessories'
      ],
    },
    {
      'name': 'Industrial & Commercial',
      'icon': 'factory',
      'subcategories': [
        'Machinery',
        'Tools & Equipment',
        'Safety Gear',
        'Warehousing',
        'Construction Materials',
        'Industrial Services'
      ],
    },
    {
      'name': 'Events & Occasions',
      'icon': 'event',
      'subcategories': [
        'Weddings',
        'Birthday Parties',
        'Corporate Events',
        'Event Planning',
        'Catering',
        'Decorations'
      ],
    },
    {
      'name': 'Others',
      'icon': 'category',
      'subcategories': [
        'Baby & Kids',
        'Pets',
        'Health',
        'Food',
        'Business',
        'Miscellaneous'
      ],
    },
  ];

  final List<String> _conditions = [
    "New",
    "Used",
    "Refurbished",
    "open_box",
    "for_parts"
  ];
  final List<String> _datePostedOptions = [
    "Today",
    "This Week",
    "This Month",
    "Any Time"
  ];
  final List<String> _sellerTypes = ["Individual", "Business", "Any"];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text('Clear All'),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  SizedBox(height: 24.sp),
                  _buildPriceRangeFilter(),
                  SizedBox(height: 24.sp),
                  _buildConditionFilter(),
                  SizedBox(height: 24.sp),
                  _buildLocationFilter(),
                  SizedBox(height: 24.sp),
                  _buildDatePostedFilter(),
                  SizedBox(height: 24.sp),
                  _buildSellerTypeFilter(),
                  SizedBox(height: 32.sp),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return _buildFilterSection(
      title: 'Category',
      child: Column(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category['name'];
          return Container(
            margin: EdgeInsets.only(bottom: 8.sp),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: CustomIconWidget(
                iconName: category['icon'] as String,
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24.sp,
              ),
              title: Text(
                category['name'] as String,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: CustomIconWidget(
                iconName:
                    isSelected ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20.sp,
              ),
              onTap: () {
                setState(() {
                  _selectedCategory =
                      isSelected ? null : category['name'] as String;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return _buildFilterSection(
      title: 'Price Range',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.round()}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Text(
                '\$${_priceRange.end.round()}',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 5000,
            divisions: 50,
            labels: RangeLabels(
              '\$${_priceRange.start.round()}',
              '\$${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConditionFilter() {
    return _buildFilterSection(
      title: 'Condition',
      child: Wrap(
        spacing: 8.sp,
        runSpacing: 8.sp,
        children: _conditions.map((condition) {
          final isSelected = _selectedCondition == condition;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCondition = isSelected ? null : condition;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.sp,
                vertical: 8.sp,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primaryContainer
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20.sp),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                condition,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return _buildFilterSection(
      title: 'Location Radius',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Within ${_locationRadius.round()} km',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              CustomIconWidget(
                iconName: 'my_location',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 16.sp),
          Slider(
            value: _locationRadius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_locationRadius.round()} km',
            onChanged: (value) {
              setState(() {
                _locationRadius = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePostedFilter() {
    return _buildFilterSection(
      title: 'Date Posted',
      child: Column(
        children: _datePostedOptions.map((option) {
          final isSelected = _selectedDatePosted == option;
          return Container(
            margin: EdgeInsets.only(bottom: 8.sp),
            child: ListTile(
              title: Text(
                option,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedDatePosted,
                onChanged: (value) {
                  setState(() {
                    _selectedDatePosted = value;
                  });
                },
              ),
              onTap: () {
                setState(() {
                  _selectedDatePosted = option;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSellerTypeFilter() {
    return _buildFilterSection(
      title: 'Seller Type',
      child: ToggleButtons(
        isSelected:
            _sellerTypes.map((type) => _selectedSellerType == type).toList(),
        onPressed: (index) {
          setState(() {
            _selectedSellerType = _selectedSellerType == _sellerTypes[index]
                ? null
                : _sellerTypes[index];
          });
        },
        borderRadius: BorderRadius.circular(12.sp),
        selectedColor: AppTheme.lightTheme.colorScheme.onPrimary,
        fillColor: AppTheme.lightTheme.colorScheme.primary,
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        constraints: BoxConstraints(
          minHeight: 40.sp,
          minWidth: 80.sp,
        ),
        children: _sellerTypes
            .map((type) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp),
                  child: Text(type),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.sp),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.sp),
            child,
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(0, 2000);
      _selectedCondition = null;
      _locationRadius = 5.0;
      _selectedDatePosted = null;
      _selectedSellerType = null;
    });
  }

  void _applyFilters() {
    final List<Map<String, dynamic>> filters = [];

    if (_selectedCategory != null) {
      filters.add({"label": _selectedCategory!, "type": "category"});
    }

    if (_priceRange.start > 0 || _priceRange.end < 2000) {
      filters.add({
        "label":
            "\$${_priceRange.start.round()} - \$${_priceRange.end.round()}",
        "type": "price"
      });
    }

    if (_selectedCondition != null) {
      filters.add({"label": _selectedCondition!, "type": "condition"});
    }

    if (_locationRadius != 5.0) {
      filters.add(
          {"label": "Within ${_locationRadius.round()}km", "type": "location"});
    }

    if (_selectedDatePosted != null) {
      filters.add({"label": _selectedDatePosted!, "type": "date"});
    }

    if (_selectedSellerType != null && _selectedSellerType != "Any") {
      filters.add({"label": _selectedSellerType!, "type": "seller"});
    }

    widget.onApplyFilters(filters);
  }
}
