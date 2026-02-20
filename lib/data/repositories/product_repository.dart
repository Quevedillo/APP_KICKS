import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  Future<List<Product>> getProducts({
    String? categorySlug,
    String? sortBy,
    bool ascending = false,
  }) async {
    var query = _client
        .from('products')
        .select()
        .eq('is_active', true)
        .gt('stock', 0); // ← hide 0-stock products from regular users

    if (categorySlug != null) {
      final categoryData = await _client
          .from('categories')
          .select('id')
          .eq('slug', categorySlug)
          .single();
      
      query = query.eq('category_id', categoryData['id']);
    }

    // Ordenar
    if (sortBy == 'price') {
      final data = await query.order('price', ascending: ascending);
      return (data as List).map((e) => Product.fromJson(e)).toList();
    }
    
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Catálogo completo con filtros y ordenación (siempre stock > 0)
  Future<List<Product>> getFilteredProducts({
    String? brand,
    String? categoryId,
    String? color,
    int? minPriceCents,
    int? maxPriceCents,
    String sortBy = 'newest', // 'newest' | 'price_asc' | 'price_desc' | 'alpha_asc' | 'alpha_desc'
    String? searchQuery,
  }) async {
    var query = _client
        .from('products')
        .select()
        .eq('is_active', true)
        .gt('stock', 0);

    if (brand != null && brand.isNotEmpty) {
      query = query.eq('brand', brand);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }
    if (color != null && color.isNotEmpty) {
      query = query.ilike('colorway', '%$color%');
    }
    if (minPriceCents != null) {
      query = query.gte('price', minPriceCents);
    }
    if (maxPriceCents != null) {
      query = query.lte('price', maxPriceCents);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or(
          'name.ilike.%$searchQuery%,brand.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
    }

    List<dynamic> data;
    switch (sortBy) {
      case 'price_asc':
        data = await query.order('price', ascending: true);
        break;
      case 'price_desc':
        data = await query.order('price', ascending: false);
        break;
      case 'alpha_asc':
        data = await query.order('name', ascending: true);
        break;
      case 'alpha_desc':
        data = await query.order('name', ascending: false);
        break;
      default: // newest
        data = await query.order('created_at', ascending: false);
    }

    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Obtiene todos los productos con descuento activo (para la sección Ofertas)
  Future<List<Product>> getProductsOnSale() async {
    final data = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .gt('stock', 0)
        .not('discount_value', 'is', null)
        .gt('discount_value', 0)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  /// Obtiene productos por colección:
  /// - 'limited'  → is_limited_edition = true
  /// - 'new'      → release_type = 'new'
  /// - 'restock'  → release_type = 'restock'
  /// - 'offers'   → discount_value > 0
  Future<List<Product>> getProductsByCollection(String collection) async {
    switch (collection) {
      case 'limited':
        final data = await _client
            .from('products')
            .select()
            .eq('is_active', true)
            .gt('stock', 0)
            .eq('is_limited_edition', true)
            .order('created_at', ascending: false);
        return (data as List).map((e) => Product.fromJson(e)).toList();

      case 'new':
        final data = await _client
            .from('products')
            .select()
            .eq('is_active', true)
            .gt('stock', 0)
            .eq('release_type', 'new')
            .order('created_at', ascending: false);
        return (data as List).map((e) => Product.fromJson(e)).toList();

      case 'restock':
        final data = await _client
            .from('products')
            .select()
            .eq('is_active', true)
            .gt('stock', 0)
            .eq('release_type', 'restock')
            .order('created_at', ascending: false);
        return (data as List).map((e) => Product.fromJson(e)).toList();

      case 'offers':
      default:
        return getProductsOnSale();
    }
  }

  Future<Product?> getProductBySlug(String slug) async {
    final data = await _client
        .from('products')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    
    if (data == null) return null;
    return Product.fromJson(data);
  }

  Future<List<Category>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('display_order');
    return (data as List).map((e) => Category.fromJson(e)).toList();
  }

  Future<Category?> getCategoryBySlug(String slug) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    
    if (data == null) return null;
    return Category.fromJson(data);
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select()
        .eq('is_active', true)
        .gt('stock', 0)
        .or('name.ilike.%$query%,brand.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(20);
    
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getRelatedProducts(String categoryId, String excludeProductId) async {
    final data = await _client
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .gt('stock', 0)
        .neq('id', excludeProductId)
        .limit(4);
    
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }
}
