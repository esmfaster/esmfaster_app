import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/accounts/login/login.dart';
import 'package:app/src/ui/blocks/products/product_image.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../blocks/products/product_ratting.dart';
import '../../../../models/product_model.dart';
import '../../product_detail/product_detail.dart';
import '../../products/product_label.dart';
import '../../products_widgets/price_widget.dart';
import '../../../../functions.dart';
import '../../products/add_to_cart.dart';

class ProductCard02 extends StatefulWidget {
  final Product product;

  const ProductCard02({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductCard02> createState() => _ProductCard02State();
}

class _ProductCard02State extends State<ProductCard02> {
  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppStateModel>(context);

    return Column(
      children: [
        Card(
          margin: EdgeInsets.all(4),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          child: InkWell(
            onTap: () => onProductClick(context),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                _buildProductImage(context),
                Positioned(
                    top: 18,
                    left: 0,
                    child: ProductLabel(widget.product.tags)
                ),
                IconButton(
                    onPressed: () {
                      if (AppStateModel().user.id == 0) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Login()));
                      } else {
                        context.read<Favourites>().updateWishList(widget.product.id);
                        setState(() {});
                      }
                    },
                  icon: context.watch<Favourites>().wishListIds.contains(widget.product.id) ? Icon(FluentIcons.heart_16_filled, color: Colors.black) :
                  Icon(FluentIcons.heart_16_regular, color: Colors.black),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parseHtmlString(widget.product.name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              PriceWidget(product: widget.product),
              SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        image: DecorationImage(
          image: NetworkImage(widget.product.images[0].src),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void onProductClick(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: widget.product);
    }));
  }
}

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
                fontSize: 12,
                fontWeight: FontWeight.w600,
              )),
        //product.onSale && product.formattedSalesPrice != null ? SizedBox(width: 4.0) : SizedBox(width: 0.0),
        Row(
          children: [
            Text(parseHtmlString(widget.product.formattedPrice!),
                style: widget.product.onSale && widget.product.formattedSalesPrice != null ? Theme.of(context).textTheme.bodySmall!.copyWith(
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
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
                  fontSize: 10,
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

class ProductLabel extends StatelessWidget {
  ProductLabel(this.tags);
  final List<String> tags;
  @override
  Widget build(BuildContext context) {

    List<String> output = tags.where((element) => AppStateModel().blocks.settings.labels.contains(element.toString())).toList();
    //List<String> output = ['Think tak'];

    return output.length > 0 ? Row(
      children: [
        Container(
          height: 18,
          padding: const EdgeInsets.all(2.0),
          color: Theme.of(context).colorScheme.primary.withOpacity(.8),
          child: Text(output[0],
            style: TextStyle(
              fontSize: 9,
              color: Colors.white,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          child: Stack(
            children: [
              ClipPath(
                clipper: RectangleClipper(),
                child: Container(
                  height: 18,
                  width: 10,
                  color: Theme.of(context).colorScheme.primary.withOpacity(.6),
                ),
              ),
              ClipPath(
                clipper: TriangleClipper(),
                child: Container(
                  height: 18,
                  width: 10,
                  color: Theme.of(context).colorScheme.primary.withOpacity(.4),
                ),
              )
            ],
          ),
        ),
      ],
    ) : Container();
  }
}


class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width/2, size.height/2);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
class RectangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width / 2, size.height/2);
    path.lineTo(size.width , size.height);
    path.lineTo(0 , size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(RectangleClipper oldClipper) => false;
}
