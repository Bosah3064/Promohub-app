const fs = require('fs');
const filePath = 'lib/presentation/search_and_filters/search_and_filters.dart';
let content = fs.readFileSync(filePath, 'utf8');

// The string to find
const mockCategoriesStart = '  // Mock data\n  final List<Map<String, dynamic>> _categories = [';
const mockCategoriesEnd = '    },\n  ];\n\n  final List<String> _popularSearches = [';

const startIndex = content.indexOf(mockCategoriesStart);
const endIndex = content.indexOf(mockCategoriesEnd);

if (startIndex !== -1 && endIndex !== -1) {
    const replacement = `  final MarketplaceService _marketplaceService = MarketplaceService();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

  final List<String> _popularSearches = [`;
    
    content = content.substring(0, startIndex) + replacement + content.substring(endIndex + '    },\n  ];\n\n  final List<String> _popularSearches = ['.length);
}

// Add _loadCategories in initState
const initStateStart = '  void initState() {\n    super.initState();\n    _updateResultCount();\n    _searchController.addListener(_onSearchChanged);\n  }';
const initStateReplacement = `  void initState() {
    super.initState();
    _loadCategories();
    _updateResultCount();
    _searchController.addListener(_onSearchChanged);
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
content = content.replace(initStateStart, initStateReplacement);

fs.writeFileSync(filePath, content);
