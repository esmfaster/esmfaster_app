import 'package:app/src/models/app_state_model.dart';
import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../functions.dart';

class PriceWidget extends StatefulWidget {
  PriceWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  State<PriceWidget> createState() => _PriceWidgetState();
}

class _PriceWidgetState extends State<PriceWidget> {
  int percentOff = 0;

  @override
  Widget build(BuildContext context) {

    if ((widget.product.salePrice != 0)) {
      percentOff = (((widget.product.regularPrice - widget.product.salePrice) / widget.product.regularPrice) * 100).round();
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: <Widget>[
        if(widget.product.onSale && widget.product.formattedSalesPrice != null && widget.product.formattedSalesPrice!.isNotEmpty)
        Text(parseHtmlString(widget.product.formattedSalesPrice!),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
        //product.onSale && product.formattedSalesPrice != null ? SizedBox(width: 4.0) : SizedBox(width: 0.0),
        Row(
          children: [
            Text(parseHtmlString(widget.product.formattedPrice!),
                style: widget.product.onSale && widget.product.formattedSalesPrice != null ? Theme.of(context).textTheme.bodySmall!.copyWith(
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
            widget.product.onSale && widget.product.formattedSalesPrice != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                percentOff.toString() + '% ' + AppStateModel().blocks.localeText.off,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ) : Container()
          ],
        ),
      ],
    );
  }
}

class VariationPriceWidget extends StatelessWidget {
  const VariationPriceWidget({
    Key? key,
    required this.selectedVariation,
  }) : super(key: key);

  final AvailableVariation selectedVariation;

  @override
  Widget build(BuildContext context) {
    bool onSale = (selectedVariation.formattedSalesPrice != null &&
        selectedVariation.formattedSalesPrice!.isNotEmpty);
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        Text(onSale ? parseHtmlString(selectedVariation.formattedSalesPrice!) : '',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
        onSale ? SizedBox(width: 6.0) : SizedBox(width: 0.0),
        Text(
            (selectedVariation.formattedPrice != null &&
                selectedVariation.formattedPrice!.isNotEmpty)
                ? parseHtmlString(selectedVariation.formattedPrice!)
                : '',
            style: onSale && (selectedVariation.formattedSalesPrice != null &&
                selectedVariation.formattedSalesPrice!.isNotEmpty) ? Theme.of(context).textTheme.bodySmall!.copyWith(
                decoration: TextDecoration.lineThrough,
                decorationColor: Theme.of(context).hintColor.withOpacity(0.3)
            ) : Theme.of(context).textTheme.bodySmall!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )
        ),
        SizedBox(width: 4.0),
        onSale ? Text((((selectedVariation.displayRegularPrice! - selectedVariation.displayPrice!) / selectedVariation.displayRegularPrice! ) * 100 ).round().toStringAsFixed(0) + '% OFF', style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.green
        )) : Container()
      ],
    );
  }
}
