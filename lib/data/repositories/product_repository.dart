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
    var query = _client.from('products').select().eq('is_active', true);

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
        .neq('id', excludeProductId)
        .limit(4);
    
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }
}
