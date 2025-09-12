import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/strings.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Wireless Headphones',
      price: 99.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Headphones',
      category: 'Electronics',
      rating: 4.5,
      inStock: true,
    ),
    Product(
      id: '2',
      name: 'Smart Watch',
      price: 199.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Watch',
      category: 'Electronics',
      rating: 4.8,
      inStock: true,
    ),
    Product(
      id: '3',
      name: 'Cotton T-Shirt',
      price: 19.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=T-Shirt',
      category: 'Clothing',
      rating: 4.2,
      inStock: false,
    ),
    Product(
      id: '4',
      name: 'Running Shoes',
      price: 79.99,
      imageUrl: 'https://via.placeholder.com/200x200?text=Shoes',
      category: 'Sports',
      rating: 4.6,
      inStock: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Handle filter
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          _buildCategories(),
          
          // Products Grid
          Expanded(
            child: _buildProductsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', 'Electronics', 'Clothing', 'Sports', 'Home'];
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (selected) {
                // Handle category selection
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.primaryGreen.withOpacity(0.1),
              checkmarkColor: AppColors.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppDimensions.paddingMedium,
        crossAxisSpacing: AppDimensions.paddingMedium,
        childAspectRatio: 0.75,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(_products[index]);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: InkWell(
        onTap: () => _viewProductDetail(product),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.borderRadiusMedium),
                    topRight: Radius.circular(AppDimensions.borderRadiusMedium),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),
            
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: AppDimensions.iconSmall,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toString(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: product.inStock ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewProductDetail(Product product) {
    // Navigate to product detail page
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: \$${product.price.toStringAsFixed(2)}'),
            Text('Category: ${product.category}'),
            Text('Rating: ${product.rating}'),
            Text('Status: ${product.inStock ? 'In Stock' : 'Out of Stock'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (product.inStock)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} added to cart'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Add to Cart'),
            ),
        ],
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.inStock,
  });
}