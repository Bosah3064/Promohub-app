import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../theme/app_theme.dart';

class ProductDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailsWidget({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsWidget> createState() => _ProductDetailsWidgetState();
}

class _ProductDetailsWidgetState extends State<ProductDetailsWidget> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primary = theme.colorScheme.primary;

    final String title = widget.product["title"] as String? ?? 'Product';
    final String price = widget.product["price"] as String? ?? 'KSh 0';
    final String? originalPrice = widget.product["originalPrice"] as String?;
    final String? discount = widget.product["discount"] as String?;
    final String brand = widget.product["brand"] as String? ?? 'Official Brand';
    final bool isOfficialStore = widget.product["isOfficialStore"] == true;
    final String? stockUrgency = widget.product["stockUrgency"] as String?;
    final double rating = (widget.product["rating"] as num?)?.toDouble() ?? 4.6;
    final int ratingCount = (widget.product["ratingCount"] as num?)?.toInt() ?? 588;
    final String description = widget.product["description"] as String? ?? '';
    final List<dynamic>? keyFeatures = widget.product["keyFeatures"] as List<dynamic>?;
    final List<dynamic>? whatsInTheBox = widget.product["whatsInTheBox"] as List<dynamic>?;
    final Map<String, dynamic>? specs = widget.product["specifications"] as Map<String, dynamic>?;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand & Store Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Brand: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    brand,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                  if (isOfficialStore) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, size: 11, color: Colors.blue.shade700),
                          const SizedBox(width: 3),
                          Text(
                            'Official Store',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (stockUrgency != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 13, color: Colors.red.shade700),
                      const SizedBox(width: 2),
                      Text(
                        stockUrgency,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: 1.h),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              height: 1.35,
            ),
          ),

          SizedBox(height: 1.h),

          // Rating & Reviews row
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star_rounded
                        : (index < rating
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded),
                    color: Colors.amber.shade700,
                    size: 17,
                  );
                }),
              ),
              SizedBox(width: 1.5.w),
              Text(
                '($ratingCount verified ratings)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Price & Discount Box
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: -0.5,
                  ),
                ),
                if (originalPrice != null) ...[
                  SizedBox(width: 3.w),
                  Text(
                    originalPrice,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (discount != null) ...[
                  SizedBox(width: 2.w),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Key Features Section
          if (keyFeatures != null && keyFeatures.isNotEmpty) ...[
            _buildSectionHeader('Key Features', Icons.check_circle_outline),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: keyFeatures.map((f) => _buildBulletPoint(f.toString())).toList(),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // What's In The Box
          if (whatsInTheBox != null && whatsInTheBox.isNotEmpty) ...[
            _buildSectionHeader("What's In The Box", Icons.inventory_2_outlined),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: whatsInTheBox.map((item) => _buildBoxItem(item.toString())).toList(),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Product Description
          _buildSectionHeader('Product Description', Icons.description_outlined),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: _isDescriptionExpanded ? null : 3,
                  overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (description.length > 120)
                  InkWell(
                    onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _isDescriptionExpanded ? 'Read Less ▲' : 'Read More ▼',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Specifications Table
          if (specs != null && specs.isNotEmpty) ...[
            _buildSectionHeader('Specifications', Icons.tune_rounded),
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: specs.entries.toList().asMap().entries.map((entry) {
                  final int index = entry.key;
                  final MapEntry<String, dynamic> item = entry.value;
                  return _buildSpecRow(item.key, item.value.toString(), isEven: index % 2 == 0);
                }).toList(),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.lightTheme.colorScheme.primary),
        SizedBox(width: 2.w),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.all_inbox_rounded, size: 16, color: AppTheme.lightTheme.colorScheme.primary),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, {required bool isEven}) {
    return Container(
      color: isEven ? Colors.grey.shade50 : Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
