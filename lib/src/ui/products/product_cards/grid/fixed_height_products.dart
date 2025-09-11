import 'package:app/src/ui/blocks/products/percent_off.dart';
import 'package:app/src/ui/blocks/products/product_image.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../blocks/products/product_ratting.dart';
import '../../product_detail/product_detail.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../../models/app_state_model.dart';
import '../../../../models/product_model.dart';
import '../../products_widgets/price_widget.dart';
import '../../../../functions.dart';
import '../../products/add_to_cart.dart';
import '../../products/product_label.dart';

class FixedHeightProductInGrid extends StatefulWidget {
  final Product product;

  const FixedHeightProductInGrid({Key? key, required this.product}) : super(key: key);

  @override
  _FixedHeightProductInGridState createState() => _FixedHeightProductInGridState();
}

class _FixedHeightProductInGridState extends State<FixedHeightProductInGrid> {
  AvailableVariation? _selectedVariation;
  int percentOff = 0;

  @override
  void initState() {
    if (widget.product.availableVariations.isNotEmpty) {
      _selectedVariation = widget.product.availableVariations.first;
    }
    if (widget.product.salePrice != 0) {
      percentOff = (((widget.product.regularPrice - widget.product.salePrice) / widget.product.regularPrice) * 100).round();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: onProductClick,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 180, // Fixed height for the image
                  child: ProductCachedImage(imageUrl: widget.product.images.isNotEmpty ? widget.product.images[0].src : ''),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //_buildTags(),
                        SizedBox(height: 4),
                        _buildProductName(),
                        SizedBox(height: 4),
                        ProductRating(ratingCount: widget.product.ratingCount, averageRating: widget.product.averageRating),
                        SizedBox(height: 2),
                        _buildPriceWidget(model: model),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildTags() {
    return Row(
      children: [
        if (widget.product.tags.contains('fresh')) _buildTag(label: 'Fresh', icon: Icons.fiber_manual_record_sharp),
        Spacer(),
        if (widget.product.tags.contains('express')) _buildTag(label: 'Express', icon: Icons.pedal_bike_rounded),
      ],
    );
  }

  Widget _buildTag({required String label, required IconData icon}) {
    return Container(
      height: 18,
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: Color(0xffeeeeee),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 9, color: Colors.green),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductName() {
    return Container(
      height: 34,
      child: Text(
        parseHtmlString(widget.product.name),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Widget _buildPriceWidget({required AppStateModel model}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.blocks.settings.listingAddToCart && widget.product.availableVariations.isNotEmpty && _selectedVariation != null) ...[
          //VariationPriceWidget(selectedVariation: _selectedVariation!),
          //SizedBox(height: 8),
          //_buildVariantSelector(),
        ] else ...[
          PriceWidget(product: widget.product),
        ],
      ],
    );
  }

  Widget _buildVariantSelector() {
    return Container(
      height: 25,
      child: OutlinedButton(
        onPressed: () => _selectVariant(context),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: Text(getTitle(_selectedVariation!), style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 12), maxLines: 2)),
              Icon(Icons.keyboard_arrow_down, size: 16, color: Theme.of(context).hintColor),
            ],
          ),
        ),
      ),
    );
  }

  String getTitle(AvailableVariation? variation) {
    var name = '';
    if (variation != null) {
      for (var value in variation.option) {
        if (value.value.isNotEmpty) {
          name = name + value.value + ' ';
        }
      }
    }
    return name;
  }

  Future<void> _selectVariant(BuildContext context) async {
    var selectedVariant = await showDialog<AvailableVariation>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(16),
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          elevation: 4,
          title: Text(
            widget.product.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: _buildVariationList(),
        );
      },
    );
    if (selectedVariant != null) {
      setState(() {
        _selectedVariation = selectedVariant;
      });
    }
  }

  List<Widget> _buildVariationList() {
    List<Widget> list = [];
    widget.product.availableVariations.forEach((element) {
      if (element.isInStock) {
        list.add(buildSimpleDialog(context, element));
      }
    });
    return list;
  }

  Widget buildSimpleDialog(BuildContext context, AvailableVariation? variation) {
    return Container(
      color: _selectedVariation == variation ? Theme.of(context).colorScheme.secondary : Colors.transparent,
      child: Center(
        child: SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop(variation);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    getTitle(variation),
                    style: TextStyle(
                      fontSize: 12,
                      color: _selectedVariation == variation ? Theme.of(context).colorScheme.onSecondary : null,
                    ),
                  ),
                ),
                _variationPrice(variation!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _variationPrice(AvailableVariation variation) {
    if (variation.formattedPrice != null && variation.formattedSalesPrice == null) {
      return Text(
        parseHtmlString(variation.formattedPrice!),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _selectedVariation == variation ? Theme.of(context).colorScheme.onSecondary : Colors.black38,
        ),
      );
    } else if (variation.formattedPrice != null && variation.formattedSalesPrice != null) {
      return Row(
        children: [
          Text(
            parseHtmlString(variation.formattedSalesPrice!),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _selectedVariation == variation ? Theme.of(context).colorScheme.onSecondary : Colors.black,
            ),
          ),
          SizedBox(width: 4),
          Text(
            parseHtmlString(variation.formattedPrice!),
            style: TextStyle(
              fontSize: 10,
              decoration: TextDecoration.lineThrough,
              color: _selectedVariation == variation ? Theme.of(context).colorScheme.onSecondary.withOpacity(0.7) : Colors.black38,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void onProductClick() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: widget.product);
    }));
  }
}

class PriceWidget extends StatelessWidget {
  PriceWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  int percentOff = 0;

  @override
  Widget build(BuildContext context) {

    if ((product.salePrice != 0)) {
      percentOff = (((product.regularPrice - product.salePrice) / product.regularPrice) * 100).round();
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: <Widget>[
        if(product.onSale && product.formattedSalesPrice != null && product.formattedSalesPrice!.isNotEmpty)
          Text(parseHtmlString(product.formattedSalesPrice!),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        Text(parseHtmlString(product.formattedPrice!),
            style: product.onSale && product.formattedSalesPrice != null ? Theme.of(context).textTheme.bodySmall!.copyWith(
                decoration: TextDecoration.lineThrough,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Theme.of(context).hintColor,
                decorationColor: Theme.of(context).hintColor
            ) : Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )
        ),
        //product.onSale && product.formattedSalesPrice != null ? SizedBox(width: 4.0) : SizedBox(width: 0.0),
        /*Row(
          children: [
            Text(parseHtmlString(product.formattedPrice!),
                style: product.onSale && product.formattedSalesPrice != null ? Theme.of(context).textTheme.bodySmall!.copyWith(
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w400,
                    fontSize: 8,
                    color: Theme.of(context).hintColor,
                    decorationColor: Theme.of(context).hintColor
                ) : Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )
            ),
            product.onSale && product.formattedSalesPrice != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                percentOff.toString() + '% ' + AppStateModel().blocks.localeText.off,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
            ) : Container()
          ],
        ),*/
      ],
    );
  }
}

