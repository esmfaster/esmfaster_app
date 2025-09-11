import '../../src/models/product_model.dart';
import 'dart:convert';
import './../models/releated_products.dart';
import './../models/review_model.dart';
import './../resources/api_provider.dart';
import 'package:rxdart/rxdart.dart';

class ProductDetailBloc {
  final apiProvider = ApiProvider();
  final _relatedProductFetcher = BehaviorSubject<RelatedProductsModel>();
  final _reviewsFetcher = BehaviorSubject<List<ReviewModel>>();
  final _productFetcher = BehaviorSubject<Product>();

  ValueStream<RelatedProductsModel> get relatedProducts => _relatedProductFetcher.stream;
  ValueStream<List<ReviewModel>> get allReviews => _reviewsFetcher.stream;
  ValueStream<Product> get product => _productFetcher.stream;

  Future<void> getProductsDetails(int id) async {
    try {
      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-product_details',
        {'product_id': id.toString()},
      );
      if (response.statusCode == 200) {
        final productsList = releatedProductsFromJson(response.body);
        _relatedProductFetcher.sink.add(productsList);
      } else {
        throw Exception('Failed to load related products');
      }
    } catch (e) {
      _relatedProductFetcher.sink.addError('Error loading related products');
    }
  }

  Future<void> getReviews(int id) async {
    try {
      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-product_reviews',
        {'product_id': id.toString()},
      );
      if (response.statusCode == 200) {
        final reviews = reviewModelFromJson(response.body);
        _reviewsFetcher.sink.add(reviews);
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      _reviewsFetcher.sink.addError('Error loading reviews');
    }
  }

  Future<void> getProduct(Product product) async {
    if (product.name.isNotEmpty) {
      _productFetcher.sink.add(product);
    } else {
      try {
        final response = await apiProvider.post(
          '/wp-admin/admin-ajax.php?action=build-app-online-product',
          {'product_id': product.id.toString()},
        );
        if (response.statusCode == 200) {
          final fetchedProduct = Product.fromJson(json.decode(response.body));
          _productFetcher.sink.add(fetchedProduct);
        } else {
          throw Exception('Failed to load product');
        }
      } catch (e) {
        _productFetcher.sink.addError('Error loading product');
      }
    }
  }

  Future<Product> getProductBySKU(String sku) async {
    try {
      final response = await apiProvider.post(
        '/wp-admin/admin-ajax.php?action=build-app-online-product',
        {'sku': sku},
      );
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error loading product by SKU');
    }
  }

  void dispose() {
    _relatedProductFetcher.close();
    _reviewsFetcher.close();
    _productFetcher.close();
  }
}
