import 'package:flutter/foundation.dart';
import '../models/vod_item.dart';
import '../models/series_item.dart';
import '../services/xtream_api_client.dart';

/// Provider for managing VOD (Movies) and Series content
class ContentProvider with ChangeNotifier {
  XtreamApiClient? _apiClient;
  
  // VOD
  List<VodItem> _vodItems = [];
  List<Map<String, dynamic>> _vodCategories = [];
  String? _selectedVodCategoryId;
  bool _isLoadingVod = false;
  
  // Series
  List<SeriesItem> _seriesItems = [];
  List<Map<String, dynamic>> _seriesCategories = [];
  String? _selectedSeriesCategoryId;
  bool _isLoadingSeries = false;
  
  // Favorites
  final Set<String> _favoriteVodIds = {};
  final Set<String> _favoriteSeriesIds = {};
  
  ContentProvider(this._apiClient);

  /// Update the API client
  void updateApiClient(XtreamApiClient? apiClient) {
    if (_apiClient != apiClient) {
      _apiClient = apiClient;
      debugPrint('🎬 ContentProvider: API client updated');
      notifyListeners();
    }
  }

  /// Check if API client is available
  bool get hasApiClient => _apiClient != null;

  // VOD Getters
  List<VodItem> get vodItems => _vodItems;
  List<Map<String, dynamic>> get vodCategories => _vodCategories;
  String? get selectedVodCategoryId => _selectedVodCategoryId;
  bool get isLoadingVod => _isLoadingVod;
  
  List<VodItem> get filteredVodItems {
    if (_selectedVodCategoryId == null || _selectedVodCategoryId == 'all') {
      return _vodItems;
    }
    return _vodItems.where((item) => item.categoryId == _selectedVodCategoryId).toList();
  }
  
  List<VodItem> get favoriteVodItems {
    return _vodItems.where((item) => _favoriteVodIds.contains(item.id)).toList();
  }
  
  // Series Getters
  List<SeriesItem> get seriesItems => _seriesItems;
  List<Map<String, dynamic>> get seriesCategories => _seriesCategories;
  String? get selectedSeriesCategoryId => _selectedSeriesCategoryId;
  bool get isLoadingSeries => _isLoadingSeries;
  
  List<SeriesItem> get filteredSeriesItems {
    if (_selectedSeriesCategoryId == null || _selectedSeriesCategoryId == 'all') {
      return _seriesItems;
    }
    return _seriesItems.where((item) => item.categoryId == _selectedSeriesCategoryId).toList();
  }
  
  List<SeriesItem> get favoriteSeriesItems {
    return _seriesItems.where((item) => _favoriteSeriesIds.contains(item.id)).toList();
  }

  /// Load VOD categories
  Future<void> loadVodCategories() async {
    if (_apiClient == null) {
      debugPrint('⚠️ ContentProvider.loadVodCategories: API client is null');
      return;
    }
    
    debugPrint('📥 ContentProvider.loadVodCategories: Starting load');
    try {
      final categories = await _apiClient!.getVodCategories();
      debugPrint('✅ ContentProvider.loadVodCategories: Received ${categories.length} categories');
      
      _vodCategories = categories;
      // Add "All" category at the beginning
      _vodCategories.insert(0, {
        'category_id': 'all',
        'category_name': 'All Movies',
        'parent_id': 0,
      });
      debugPrint('✅ ContentProvider.loadVodCategories: Set _vodCategories to ${_vodCategories.length} categories');
      
      notifyListeners();
      debugPrint('✅ ContentProvider.loadVodCategories: Complete');
    } catch (e) {
      debugPrint('❌ ContentProvider.loadVodCategories: Error: $e');
      _vodCategories = [];
    }
  }

  /// Load VOD items
  Future<void> loadVodItems({String? categoryId}) async {
    if (_apiClient == null) {
      debugPrint('⚠️ ContentProvider.loadVodItems: API client is null');
      return;
    }
    
    debugPrint('📥 ContentProvider.loadVodItems: Starting load (category: ${categoryId ?? "all"})');
    _isLoadingVod = true;
    notifyListeners();
    
    try {
      final items = await _apiClient!.getVodItems(categoryId: categoryId);
      debugPrint('✅ ContentProvider.loadVodItems: Received ${items.length} items from API');
      
      _vodItems = items;
      debugPrint('✅ ContentProvider.loadVodItems: Set _vodItems to ${_vodItems.length} items');
      
      notifyListeners();
      debugPrint('✅ ContentProvider.loadVodItems: Notified listeners');
    } catch (e) {
      debugPrint('❌ ContentProvider.loadVodItems: Error loading VOD items: $e');
      _vodItems = [];
    } finally {
      _isLoadingVod = false;
      notifyListeners();
      debugPrint('✅ ContentProvider.loadVodItems: Complete (total items: ${_vodItems.length})');
    }
  }

  /// Set selected VOD category and reload items
  Future<void> setVodCategory(String? categoryId) async {
    if (_selectedVodCategoryId != categoryId) {
      _selectedVodCategoryId = categoryId;
      notifyListeners();
      
      // Reload items for the selected category
      if (_apiClient != null) {
        await loadVodItems(categoryId: categoryId == 'all' ? null : categoryId);
      }
    }
  }

  /// Load series categories
  Future<void> loadSeriesCategories() async {
    if (_apiClient == null) {
      debugPrint('⚠️ ContentProvider.loadSeriesCategories: API client is null');
      return;
    }
    
    debugPrint('📥 ContentProvider.loadSeriesCategories: Starting load');
    try {
      final categories = await _apiClient!.getSeriesCategories();
      debugPrint('✅ ContentProvider.loadSeriesCategories: Received ${categories.length} categories');
      
      _seriesCategories = categories;
      // Add "All" category at the beginning
      _seriesCategories.insert(0, {
        'category_id': 'all',
        'category_name': 'All Series',
        'parent_id': 0,
      });
      debugPrint('✅ ContentProvider.loadSeriesCategories: Set _seriesCategories to ${_seriesCategories.length} categories');
      
      notifyListeners();
      debugPrint('✅ ContentProvider.loadSeriesCategories: Complete');
    } catch (e) {
      debugPrint('❌ ContentProvider.loadSeriesCategories: Error: $e');
      _seriesCategories = [];
    }
  }

  /// Load series items
  Future<void> loadSeriesItems({String? categoryId}) async {
    if (_apiClient == null) {
      debugPrint('⚠️ ContentProvider.loadSeriesItems: API client is null');
      return;
    }
    
    debugPrint('📥 ContentProvider.loadSeriesItems: Starting load (category: ${categoryId ?? "all"})');
    _isLoadingSeries = true;
    notifyListeners();
    
    try {
      final items = await _apiClient!.getSeriesItems(categoryId: categoryId);
      debugPrint('✅ ContentProvider.loadSeriesItems: Received ${items.length} items from API');
      
      _seriesItems = items;
      debugPrint('✅ ContentProvider.loadSeriesItems: Set _seriesItems to ${_seriesItems.length} items');
      
      notifyListeners();
      debugPrint('✅ ContentProvider.loadSeriesItems: Notified listeners');
    } catch (e) {
      debugPrint('❌ ContentProvider.loadSeriesItems: Error loading series items: $e');
      _seriesItems = [];
    } finally {
      _isLoadingSeries = false;
      notifyListeners();
      debugPrint('✅ ContentProvider.loadSeriesItems: Complete (total items: ${_seriesItems.length})');
    }
  }

  /// Set selected series category and reload items
  Future<void> setSeriesCategory(String? categoryId) async {
    if (_selectedSeriesCategoryId != categoryId) {
      _selectedSeriesCategoryId = categoryId;
      notifyListeners();
      
      // Reload items for the selected category
      if (_apiClient != null) {
        await loadSeriesItems(categoryId: categoryId == 'all' ? null : categoryId);
      }
    }
  }

  /// Get detailed series info with seasons and episodes
  Future<SeriesItem?> getSeriesDetails(String seriesId) async {
    if (_apiClient == null) return null;
    
    try {
      return await _apiClient!.getSeriesInfo(seriesId);
    } catch (e) {
      debugPrint('Error loading series details: $e');
      return null;
    }
  }

  /// Get detailed VOD info
  Future<VodItem?> getVodDetails(String vodId) async {
    if (_apiClient == null) return null;
    
    try {
      return await _apiClient!.getVodInfo(vodId);
    } catch (e) {
      debugPrint('Error loading VOD details: $e');
      return null;
    }
  }

  /// Toggle VOD favorite
  void toggleVodFavorite(String vodId) {
    if (_favoriteVodIds.contains(vodId)) {
      _favoriteVodIds.remove(vodId);
    } else {
      _favoriteVodIds.add(vodId);
    }
    
    // Update the item in the list
    final index = _vodItems.indexWhere((item) => item.id == vodId);
    if (index != -1) {
      _vodItems[index] = _vodItems[index].copyWith(
        isFavorite: _favoriteVodIds.contains(vodId),
      );
    }
    
    notifyListeners();
  }

  /// Toggle series favorite
  void toggleSeriesFavorite(String seriesId) {
    if (_favoriteSeriesIds.contains(seriesId)) {
      _favoriteSeriesIds.remove(seriesId);
    } else {
      _favoriteSeriesIds.add(seriesId);
    }
    
    // Update the item in the list
    final index = _seriesItems.indexWhere((item) => item.id == seriesId);
    if (index != -1) {
      _seriesItems[index] = _seriesItems[index].copyWith(
        isFavorite: _favoriteSeriesIds.contains(seriesId),
      );
    }
    
    notifyListeners();
  }

  /// Load all content
  Future<void> loadAllContent() async {
    await Future.wait([
      loadVodCategories(),
      loadSeriesCategories(),
    ]);
    
    await Future.wait([
      loadVodItems(),
      loadSeriesItems(),
    ]);
  }

  /// Clear all content
  void clear() {
    _vodItems = [];
    _vodCategories = [];
    _selectedVodCategoryId = null;
    _seriesItems = [];
    _seriesCategories = [];
    _selectedSeriesCategoryId = null;
    _favoriteVodIds.clear();
    _favoriteSeriesIds.clear();
    notifyListeners();
  }
}
