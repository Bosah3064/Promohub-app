const fs = require('fs');
const filePath = 'lib/presentation/search_filters_screen/widgets/filter_panel_widget.dart';
let content = fs.readFileSync(filePath, 'utf8');

const mockCategoriesStart = '  final List<Map<String, dynamic>> _categories = [';
const mockCategoriesEnd = '  ];\n\n  final List<String> _conditions = [';

const startIndex = content.indexOf(mockCategoriesStart);
const endIndex = content.indexOf(mockCategoriesEnd);

if (startIndex !== -1 && endIndex !== -1) {
    const replacement = `  final MarketplaceService _marketplaceService = MarketplaceService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _marketplaceService.getCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }`;
    
    content = content.substring(0, startIndex) + replacement + content.substring(endIndex + '  ];'.length);
}

fs.writeFileSync(filePath, content);
console.log('Successfully updated filter_panel_widget.dart');
