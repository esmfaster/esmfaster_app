import 'package:app/src/ui/blocks/products/percent_off.dart';
import 'package:app/src/ui/blocks/products/product_image.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../blocks/products/product_ratting.dart';
import '../../product_detail/product_detail.dart';
import '../../../../models/app_state_model.dart';
import '../../../../models/product_model.dart';
import '../../products_widgets/price_widget.dart';
import '../../../../functions.dart';
import '../../products/add_to_cart.dart';
import '../../products/product_label.dart';

class ProductInGrid extends StatefulWidget {
  final Product product;
  const ProductInGrid({Key? key, required this.product}) : super(key: key);

  @override
  _ProductInGridState createState() => _ProductInGridState();
}

class _ProductInGridState extends State<ProductInGrid> {
  AvailableVariation? _selectedVariation;
  int percentOff = 0;

  @override
  void initState() {
    super.initState();

    if (widget.product.availableVariations.isNotEmpty) {
      _selectedVariation = widget.product.availableVariations.first;
    }

    if (widget.product.salePrice != 0) {
      percentOff = (((widget.product.regularPrice - widget.product.salePrice) /
          widget.product.regularPrice) *
          100)
          .round();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppStateModel>(context, rebuildOnChange: true);
    final theme = Theme.of(context);

    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: onProductClick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildProductInfo(context, model),
                ),
              ],
            ),
          ),
        ),
        // Position the product label at top-left (if needed)
        Positioned(
          top: 18,
          left: 0,
          child: ProductLabel(widget.product.tags),
        ),
        // Add the WishListIcon in the top-right corner
        WishListIconPositioned(id: widget.product.id),
        // If you want to show the percent off badge, uncomment below
        // PercentOff(percentOff: percentOff),
      ],
    );
  }

  /// Builds the product image area with a fixed aspect ratio
  Widget _buildImage() {
    return Container(
      constraints: BoxConstraints(
        minHeight: (MediaQuery.of(context).size.width / (MediaQuery.of(context).size.width ~/ 180).toInt()) - (2 * 4),
      ),
      child: ProductCachedImage(imageUrl: widget.product.images[0].src),
    );
  }

  /// Builds the main product information: tags (fresh/express), title, rating, pricing, etc.
  Widget _buildProductInfo(BuildContext context, AppStateModel model) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTagsRow(),
        const SizedBox(height: 8),
        Text(
          parseHtmlString(widget.product.name),
          maxLines: 2,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        ProductRating(
          ratingCount: widget.product.ratingCount,
          averageRating: widget.product.averageRating,
        ),
        const SizedBox(height: 8),
        if (model.blocks.settings.listingAddToCart)
          _buildPriceAndAddToCart(context)
        else
        // If add-to-cart is hidden, just display Price
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PriceWidget(product: widget.product),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds a row of badges if the product tags include "fresh" or "express".
  Widget _buildTagsRow() {
    List<Widget> badges = [];

    if (widget.product.tags.contains('fresh')) {
      badges.add(_buildBadge(
        label: 'Fresh',
        icon: Icon(Icons.fiber_manual_record_sharp, size: 9, color: Colors.green),
      ));
    }

    if (widget.product.tags.contains('express')) {
      badges.add(_buildBadge(
        label: 'Express',
        icon: Icon(Icons.pedal_bike_rounded, size: 10, color: Colors.black45),
      ));
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink(); // No tags, no badges
    }

    return Row(
      children: [
        ...badges,
        const Spacer(), // Push the second badge to the left if first exists
      ],
    );
  }

  /// Helper widget for building a small pill/badge.
  Widget _buildBadge({required String label, required Widget icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xffeeeeee),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds pricing (including variation selection) and Add-to-Cart button.
  Widget _buildPriceAndAddToCart(BuildContext context) {
    if (widget.product.availableVariations.isNotEmpty && _selectedVariation != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VariationPriceWidget(selectedVariation: _selectedVariation!),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: () => _selectVariant(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      _getVariationTitle(_selectedVariation!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AddToCart(product: widget.product, variation: _selectedVariation),
        ],
      );
    } else {
      // No variations or variation is null
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PriceWidget(product: widget.product),
          const SizedBox(height: 16),
          AddToCart(product: widget.product, variation: null),
        ],
      );
    }
  }

  /// Opens a dialog to let the user pick a variation if multiple are available.
  Future<Product?> _selectVariant(BuildContext context) async {
    return showDialog<Product>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(16),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          title: Text(
            widget.product.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: _buildVariationList(),
        );
      },
    );
  }

  List<Widget> _buildVariationList() {
    return widget.product.availableVariations
        .map((variation) => variation.isInStock
        ? _buildVariationOption(variation)
        : const SizedBox.shrink())
        .toList();
  }

  Widget _buildVariationOption(AvailableVariation variation) {
    final isSelected = (_selectedVariation == variation);
    return Container(
      color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.2) : Colors.transparent,
      child: SimpleDialogOption(
        onPressed: () {
          setState(() {
            _selectedVariation = variation;
          });
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getVariationTitle(variation),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondary
                        : null,
                  ),
                ),
              ),
              _buildVariationPrice(variation, isSelected),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the title string of a variation (concatenates option values).
  String _getVariationTitle(AvailableVariation variation) {
    if (variation.option.isEmpty) return '';
    return variation.option
        .where((option) => option.value.isNotEmpty)
        .map((option) => option.value)
        .join(' ');
  }

  /// Displays the price or sale price for a variation.
  Widget _buildVariationPrice(AvailableVariation variation, bool isSelected) {
    final theme = Theme.of(context);
    if (variation.formattedPrice != null && variation.formattedSalesPrice == null) {
      return Text(
        parseHtmlString(variation.formattedPrice!),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected
              ? theme.colorScheme.onSecondary
              : Colors.black38,
        ),
      );
    } else if (variation.formattedPrice != null &&
        variation.formattedSalesPrice != null) {
      return Row(
        children: [
          Text(
            parseHtmlString(variation.formattedSalesPrice!),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? theme.colorScheme.onSecondary
                  : Colors.black,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            parseHtmlString(variation.formattedPrice!),
            style: TextStyle(
              fontSize: 10,
              decoration: TextDecoration.lineThrough,
              color: isSelected
                  ? theme.colorScheme.onSecondary.withOpacity(0.7)
                  : Colors.black38,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Opens the product detail screen on tap.
  void onProductClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetail(product: widget.product),
      ),
    );
  }
}
