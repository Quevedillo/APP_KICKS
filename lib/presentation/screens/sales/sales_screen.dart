import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/providers.dart';
import '../../widgets/product_card.dart';

/// Pantalla polivalente para colecciones y ofertas.
/// - Sin [collection] → muestra todos los productos en oferta
/// - collection = 'limited' → Ediciones Limitadas
/// - collection = 'new'     → Nuevos Lanzamientos
/// - collection = 'restock' → Restocks
class SalesScreen extends ConsumerWidget {
  final String? collection;

  const SalesScreen({super.key, this.collection});

  String get _title {
    switch (collection) {
      case 'limited':
        return '⚡ EDICIONES LIMITADAS';
      case 'new':
        return '✨ NUEVOS LANZAMIENTOS';
      case 'restock':
        return '🔄 RESTOCKS';
      default:
        return '🏷️ OFERTAS';
    }
  }

  String get _subtitle {
    switch (collection) {
      case 'limited':
        return 'Piezas ultra raras y exclusivas';
      case 'new':
        return 'Últimos drops y novedades';
      case 'restock':
        return 'De vuelta en stock';
      default:
        return 'Descuentos exclusivos';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the correct provider based on collection param
    final productsAsync = collection == null
        ? ref.watch(saleProductsProvider)
        : ref.watch(collectionProductsProvider(collection!));

    // We'll also need categories to show the chip on each product card
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              _subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (collection == null) {
                    ref.invalidate(saleProductsProvider);
                  } else {
                    ref.invalidate(collectionProductsProvider(collection!));
                  }
                },
                child: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    collection == null ? Icons.local_offer_outlined : Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    collection == null
                        ? 'No hay productos en oferta ahora mismo'
                        : 'No hay productos en esta colección',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('VER TODO EL CATÁLOGO'),
                  ),
                ],
              ),
            );
          }

          // Build a category id->name map for chips
          final catMap = categoriesAsync.when(
            data: (cats) => {for (final c in cats) c.id: c.name},
            loading: () => <String, String>{},
            error: (_, __) => <String, String>{},
          );

          return CustomScrollView(
            slivers: [
              // Header row with count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '${products.length} PRODUCTOS',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Products grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      final catName = product.categoryId != null
                          ? catMap[product.categoryId]
                          : null;
                      return ProductCard(
                        product: product,
                        categoryName: catName,
                        onTap: () => context.push('/product/${product.slug}'),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
