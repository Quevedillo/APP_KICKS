import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/providers.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/category.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  ProductFilter _filter = const ProductFilter();
  final _searchController = TextEditingController();

  // Local UI state for the filter sheet
  String? _pendingBrand;
  String? _pendingCategoryId;
  String? _pendingColor;
  double _pendingMinPrice = 0;
  double _pendingMaxPrice = 2000;
  static const double _maxAllowedPrice = 2000;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String q) {
    setState(() {
      _filter = _filter.copyWith(searchQuery: q.isEmpty ? null : q);
    });
  }

  void _applySort(String sortBy) {
    setState(() {
      _filter = _filter.copyWith(sortBy: sortBy);
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filter = const ProductFilter();
      _searchController.clear();
      _pendingBrand = null;
      _pendingCategoryId = null;
      _pendingColor = null;
      _pendingMinPrice = 0;
      _pendingMaxPrice = _maxAllowedPrice;
    });
  }

  bool get _hasActiveFilters =>
      _filter.brand != null ||
      _filter.categoryId != null ||
      _filter.color != null ||
      _filter.minPriceCents != null ||
      _filter.maxPriceCents != null ||
      (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty);

  void _showFilterSheet(
    BuildContext context,
    List<String> brands,
    List<Category> categories,
    List<String> colors,
  ) {
    _pendingBrand = _filter.brand;
    _pendingCategoryId = _filter.categoryId;
    _pendingColor = _filter.color;
    _pendingMinPrice =
        _filter.minPriceCents != null ? _filter.minPriceCents! / 100 : 0;
    _pendingMaxPrice =
        _filter.maxPriceCents != null ? _filter.maxPriceCents! / 100 : _maxAllowedPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'FILTROS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _pendingBrand = null;
                          _pendingCategoryId = null;
                          _pendingColor = null;
                          _pendingMinPrice = 0;
                          _pendingMaxPrice = _maxAllowedPrice;
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Brands ────────────────────────────────────
                    if (brands.isNotEmpty) ...[
                      const _FilterSectionTitle('MARCA'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: brands
                            .map((b) => _FilterChip(
                                  label: b,
                                  selected: _pendingBrand == b,
                                  onTap: () => setSheetState(() {
                                    _pendingBrand =
                                        _pendingBrand == b ? null : b;
                                  }),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Categories ────────────────────────────────
                    if (categories.isNotEmpty) ...[
                      const _FilterSectionTitle('CATEGORÍA'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories
                            .map((c) => _FilterChip(
                                  label: c.name,
                                  selected: _pendingCategoryId == c.id,
                                  onTap: () => setSheetState(() {
                                    _pendingCategoryId =
                                        _pendingCategoryId == c.id
                                            ? null
                                            : c.id;
                                  }),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Colors ────────────────────────────────────
                    if (colors.isNotEmpty) ...[
                      const _FilterSectionTitle('COLOR'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: colors
                            .map((c) => _FilterChip(
                                  label: c,
                                  selected: _pendingColor == c,
                                  onTap: () => setSheetState(() {
                                    _pendingColor =
                                        _pendingColor == c ? null : c;
                                  }),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Price Range ───────────────────────────────
                    _FilterSectionTitle(
                      'PRECIO  ${_pendingMinPrice.toInt()}€ – '
                      '${_pendingMaxPrice >= _maxAllowedPrice ? '${_maxAllowedPrice.toInt()}€+' : '${_pendingMaxPrice.toInt()}€'}',
                    ),
                    RangeSlider(
                      values:
                          RangeValues(_pendingMinPrice, _pendingMaxPrice),
                      min: 0,
                      max: _maxAllowedPrice,
                      divisions: 40,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey[800],
                      onChanged: (v) => setSheetState(() {
                        _pendingMinPrice = v.start;
                        _pendingMaxPrice = v.end;
                      }),
                    ),
                  ],
                ),
              ),

              // Apply button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 8, 20, 20 + MediaQuery.of(context).padding.bottom),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filter = _filter.copyWith(
                          brand: _pendingBrand,
                          categoryId: _pendingCategoryId,
                          color: _pendingColor,
                          minPriceCents: _pendingMinPrice > 0
                              ? (_pendingMinPrice * 100).round()
                              : null,
                          maxPriceCents: _pendingMaxPrice < _maxAllowedPrice
                              ? (_pendingMaxPrice * 100).round()
                              : null,
                        );
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'APLICAR FILTROS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider(_filter));
    final categoriesAsync = ref.watch(categoriesProvider);
    // Extract filter options from loaded categories
    final categories = categoriesAsync.value ?? [];

    // Extract brands & colors from the loaded products (dynamically)
    final allProducts = productsAsync.value ?? [];
    final brands = allProducts
        .map((p) => p.brand)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    final colors = allProducts
        .map((p) => p.colorway)
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'CATÁLOGO',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune),
                if (_hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () =>
                _showFilterSheet(context, brands, categories, colors),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: _applySearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar marca, modelo...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey,
                            size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Sort bar + active filter chips
          _SortAndFilterBar(
            currentSort: _filter.sortBy,
            onSortChanged: _applySort,
            activeFilter: _filter,
            onClearAll: _hasActiveFilters ? _clearAllFilters : null,
          ),
          // Product grid
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $err',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(filteredProductsProvider(_filter)),
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
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay productos\ncon estos filtros',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        if (_hasActiveFilters)
                          ElevatedButton(
                            onPressed: _clearAllFilters,
                            child: const Text('LIMPIAR FILTROS'),
                          ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // Product count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: Text(
                          '${products.length} PRODUCTOS',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    // Grid
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () =>
                                  context.push('/product/${product.slug}'),
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
          ),
        ],
      ),
    );
  }
}

// ─── Sort & Active Filter Bar ──────────────────────────────────────────────

class _SortAndFilterBar extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;
  final ProductFilter activeFilter;
  final VoidCallback? onClearAll;

  const _SortAndFilterBar({
    required this.currentSort,
    required this.onSortChanged,
    required this.activeFilter,
    this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      ('newest', 'Recientes'),
      ('price_asc', 'Precio ↑'),
      ('price_desc', 'Precio ↓'),
      ('alpha_asc', 'A→Z'),
      ('alpha_desc', 'Z→A'),
    ];

    return Container(
      color: const Color(0xFF0A0A0A),
      child: Column(
        children: [
          // Sort chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: sortOptions.length,
              itemBuilder: (context, i) {
                final (value, label) = sortOptions[i];
                final selected = currentSort == value;
                return GestureDetector(
                  onTap: () => onSortChanged(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).primaryColor
                          : const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Active filter tags
          if (onClearAll != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  if (activeFilter.brand != null)
                    _ActiveTag(activeFilter.brand!),
                  if (activeFilter.categoryId != null)
                    const _ActiveTag('Cat.'),
                  if (activeFilter.color != null)
                    _ActiveTag(activeFilter.color!),
                  if (activeFilter.minPriceCents != null ||
                      activeFilter.maxPriceCents != null)
                    const _ActiveTag('Precio'),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClearAll,
                    child: const Text(
                      'Limpiar todo',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveTag extends StatelessWidget {
  final String label;
  const _ActiveTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────

class _FilterSectionTitle extends StatelessWidget {
  final String title;
  const _FilterSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Colors.grey[800]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.black : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
