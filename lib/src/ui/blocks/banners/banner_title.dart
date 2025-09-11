import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/blocks/category/all_brnads.dart';

import './../../../ui/products/products/products.dart';
import './../../../ui/vendor/ui/stores/stores.dart';
import './../../../models/blocks_model.dart';
import 'package:flutter/material.dart';
import 'count_down_time.dart';

class BannerTitle extends StatelessWidget {
  final Block block;
  const BannerTitle({Key? key, required this.block}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall!.copyWith(
      color: Theme.of(context).brightness == Brightness.light
          ? block.titleColor
          : null,
    );

    // If the server or admin sets custom text style for the title, override
    if (block.titleStyle != null) {
      titleStyle = getTextStyle(block.titleStyle!, context);
    }

    // Calculate if the countdown should be shown
    final dateTo = DateTime.parse(block.saleEndDate);
    final dateFrom = DateTime.now();
    final difference = dateTo.difference(dateFrom).inSeconds;
    final bool showCounter = !difference.isNegative && block.flashSale == true;

    // If the title is explicitly hidden or empty, return nothing
    if (!block.showTitle || block.title.isEmpty) {
      return const SizedBox.shrink();
    }

    if (showCounter) {
      // Show the title + countdown
      switch (block.headerAlign) {
        case 'top_left':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(block.title, style: titleStyle),
                const SizedBox(width: 8),
                CountDownTime(saleEndDate: block.saleEndDate, block: block),
              ],
            ),
          );

        case 'top_right':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CountDownTime(saleEndDate: block.saleEndDate, block: block),
                const SizedBox(width: 8),
                Text(block.title, style: titleStyle),
              ],
            ),
          );

        case 'top_center':
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(block.title, style: titleStyle),
                const SizedBox(width: 8),
                CountDownTime(saleEndDate: block.saleEndDate, block: block),
              ],
            ),
          );

        default:
          return const SizedBox.shrink();
      }
    } else {
      // The countdown is either not needed or expired, so just show title
      final filter = _getFilter();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: (block.headerAlign != 'top_left' || filter == null)
            ? Align(
          alignment: _getAlignment(block.headerAlign),
          child: Text(block.title, style: titleStyle),
        )
            : ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(block.title, style: titleStyle),
              _buildViewAllButtonIfNeeded(context, filter),
            ],
          ),
          subtitle: block.description != null
              ? Text(
            block.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          )
              : null,
        ),
      );
    }
  }

  /// Returns an alignment based on the string in `block.headerAlign`.
  Alignment _getAlignment(String alignStr) {
    switch (alignStr) {
      case 'top_left':
        return Alignment.centerLeft;
      case 'top_right':
        return Alignment.centerRight;
      case 'top_center':
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  /// Builds a [TextButton] for "View All" if the current block type
  /// supports it, otherwise returns a [SizedBox.shrink].
  Widget _buildViewAllButtonIfNeeded(BuildContext context, Map<String, dynamic> filter) {
    // If the block type is one that supports "view all"
    if (block.blockType == BlockType.storeList ||
        block.blockType == BlockType.storeSlider ||
        block.blockType == BlockType.storeListTile ||
        block.blockType == BlockType.storeScroll ||
        block.blockType == BlockType.productGrid ||
        block.blockType == BlockType.productScroll ||
        block.blockType == BlockType.productSlider ||
        block.blockType == BlockType.productList ||
        block.blockType == BlockType.brandGrid ||
        block.blockType == BlockType.brandList ||
        block.blockType == BlockType.brandListTile ||
        block.blockType == BlockType.brandPresets ||
        block.blockType == BlockType.brandScroll ||
        block.blockType == BlockType.brandSlider) {
      return TextButton(
        onPressed: () => _onClickViewAll(context, filter),
        child: Text(AppStateModel().blocks.localeText.viewAll),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Builds the filter map based on [block.linkType] and [block.blockType].
  Map<String, dynamic>? _getFilter() {
    // If the block deals with products, parse linkType accordingly
    if (block.blockType == BlockType.productGrid ||
        block.blockType == BlockType.productScroll ||
        block.blockType == BlockType.productSlider ||
        block.blockType == BlockType.productList) {
      final filter = <String, dynamic>{};
      switch (block.linkType) {
        case 'product_cat':
          filter['id'] = block.linkId.toString();
          break;
        case 'featured':
          filter['featured'] = '1';
          break;
        case 'onSale':
          filter['on_sale'] = '1';
          break;
        case 'newArrivals':
          filter['new_arrivals'] = '1';
          break;
        case 'bestSelling':
          filter['best_selling'] = '1';
          break;
        default:
          return null;
      }
      return filter;
    }

    // If the block deals with stores, we add store-specific filters
    else if (block.blockType == BlockType.storeList ||
        block.blockType == BlockType.storeSlider ||
        block.blockType == BlockType.storeListTile ||
        block.blockType == BlockType.storeScroll) {
      final filter = <String, dynamic>{};
      filter['stores'] = '1';
      filter['id'] = block.linkId.toString();
      return filter;
    }

    // If the block deals with brands
    else if (block.blockType == BlockType.brandGrid ||
        block.blockType == BlockType.brandList ||
        block.blockType == BlockType.brandListTile ||
        block.blockType == BlockType.brandPresets ||
        block.blockType == BlockType.brandScroll ||
        block.blockType == BlockType.brandSlider) {
      // You can add custom brand filters here if needed
      final filter = <String, dynamic>{};
      return filter;
    }

    // Otherwise, no filter
    return null;
  }

  /// Handles the action when "View All" is clicked, pushing the appropriate page
  /// based on the blockType.
  void _onClickViewAll(BuildContext context, Map<String, dynamic> filter) {
    if (block.blockType == BlockType.productGrid ||
        block.blockType == BlockType.productScroll ||
        block.blockType == BlockType.productSlider ||
        block.blockType == BlockType.productList) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductsWidget(
            filter: filter,
            name: block.title,
          ),
        ),
      );
    } else if (block.blockType == BlockType.storeList ||
        block.blockType == BlockType.storeSlider ||
        block.blockType == BlockType.storeListTile ||
        block.blockType == BlockType.storeScroll) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoreListPage(
            filter: filter,
            block: block,
          ),
        ),
      );
    } else if (block.blockType == BlockType.brandGrid ||
        block.blockType == BlockType.brandList ||
        block.blockType == BlockType.brandListTile ||
        block.blockType == BlockType.brandPresets ||
        block.blockType == BlockType.brandScroll ||
        block.blockType == BlockType.brandSlider) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllBrands(
            title: block.title,
          ),
        ),
      );
    }
  }
}
