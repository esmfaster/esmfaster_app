import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/blocks/products/product_image.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../blocks/products/product_ratting.dart';
import '../../../../models/product_model.dart';
import '../../product_detail/product_detail.dart';
import '../../products/product_label.dart';
import '../../products_widgets/price_widget.dart';
import '../../../../functions.dart';
import '../../products/add_to_cart.dart';

class ProductCard01 extends StatelessWidget {
  final Product product;

  const ProductCard01({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppStateModel>(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
      child: InkWell(
        onTap: () => onProductClick(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(context),
            _buildProductDetails(context),
            if (model.blocks.settings.listingAddToCart) _buildAddToCartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: (MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width ~/ 180).toInt()) - (2 * 4),
      ),
      child: Stack(
        children: [
          ProductCachedImage(imageUrl: product.images[0].src),
          Positioned(
            top: 18,
            left: 0,
            child: ProductLabel(product.tags),
          ),
          WishListIconPositioned(id: product.id),
        ],
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTags(context),
          Text(
            parseHtmlString(product.name),
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall!,
          ),
          SizedBox(height: 4),
          ProductRating(ratingCount: product.ratingCount, averageRating: product.averageRating),
          SizedBox(height: 8),
          if (product.availableVariations.isNotEmpty)
            VariationPriceWidget(selectedVariation: product.availableVariations.first)
          else
          PriceWidget(product: product),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Row(
      children: [
        if (product.tags.contains('fresh')) _buildTag(context, 'Fresh', Icons.fiber_manual_record_sharp, Colors.green),
        Spacer(),
        if (product.tags.contains('express')) _buildTag(context, 'Express', Icons.pedal_bike_rounded, Theme.of(context).hintColor),
      ],
    );
  }

  Widget _buildTag(BuildContext context, String text, IconData icon, Color color) {
    return Container(
      height: 18,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 8, color: Colors.black45, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: AddToCart(product: product),
    );
  }

  void onProductClick(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: product);
    }));
  }
}
