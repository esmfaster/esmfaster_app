import 'package:app/src/models/theme/hex_color.dart';
import 'package:app/src/ui/accounts/firebase_chat/chat.dart';
import 'package:app/src/ui/blocks/blocks.dart';
import 'package:app/src/ui/checkout/cart/shopping_cart.dart';
import 'package:app/src/models/vendor/store_model.dart';
import 'package:app/src/ui/accounts/login/login.dart';
import 'package:app/src/ui/blocks/products/product_ratting.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:app/src/ui/pages/webview.dart';
import 'package:app/src/ui/products/product_detail/gallery_view.dart';
import 'package:app/src/ui/products/product_cards/product_card.dart';
import 'package:app/src/ui/vendor/ui/vendor_app/vendor_home.dart';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:provider/src/provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../../../config.dart';
import '../reviews/review_detail.dart';
import '../reviews/write_review.dart';
import '../../../ui/checkout/cart/cart4.dart';
import '../../../functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/app_state_model.dart';
import '../../../models/releated_products.dart';
import '../../../models/review_model.dart';
import '../../../blocs/product_detail_bloc.dart';
import '../../../models/product_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cart_icon.dart';
import 'custom_card.dart';
import 'package:html/dom.dart' as dom;
import 'package:timeago/timeago.dart' as timeago;

const double listTileTopPadding = 8;

class ProductDetail4 extends StatefulWidget {
  final ProductDetailBloc productDetailBloc = ProductDetailBloc();
  final Product product;
  final appStateModel = AppStateModel();
  ProductDetail4({Key? key, required this.product}) : super(key: key);
  @override
  _ProductDetail4State createState() => _ProductDetail4State();
}

class _ProductDetail4State extends State<ProductDetail4> {

  bool addingToCart = false;
  bool buyingNow = false;
  int _quantity = 1;
  Map<String, dynamic> addOnsFormData = Map<String, dynamic>();
  final addonFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.productDetailBloc.getProduct(widget.product);
    widget.productDetailBloc.getProductsDetails(widget.product.id);
    widget.productDetailBloc.getReviews(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Product>(
        stream: widget.productDetailBloc.product,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              //extendBodyBehindAppBar: true,
              floatingActionButton: ScopedModelDescendant<AppStateModel>(
                  builder: (context, child, model) {
                    if (model.blocks.settings.productPageChat) {
                      return FloatingActionButton(
                        onPressed: () async {
                          final url = snapshot.data!.vendor.phone != null && snapshot.data!.vendor.phone!.isNotEmpty
                              ? 'https://wa.me/' +
                              snapshot.data!.vendor.phone.toString()
                              : 'https://wa.me/' +
                              model.blocks.settings.phoneNumber.toString();
                          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        },
                        tooltip: 'Chat',
                        child: Icon(Icons.chat_bubble),
                      );
                    } else {
                      return Container();
                    }
                  }),
              body: CustomScrollView(
                slivers: _buildSlivers(context, snapshot.data!),
              ),
              bottomNavigationBar: widget.appStateModel.blocks.settings.productFooterAddToCart ? SafeArea(
                child: StreamBuilder<Product>(
                    stream: widget.productDetailBloc.product,
                    builder: (context, snapshot) {
                      return snapshot.hasData ? Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(width: 0.5, color: Theme.of(context).dividerColor),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StoreHomePage(store: StoreModel.fromJson({'id': int.parse(widget.product.vendor.id), 'icon': widget.product.vendor.icon, 'name': widget.product.vendor.name}))));
                                  },
                                  icon: Icon(FlutterRemix.store_2_line),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 8, height: 40, child: VerticalDivider(width: 1, thickness: 1, color: Colors.grey[400],),),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      onPressed: () {
                                        _chatWithVendorOrAdmin();
                                      },
                                      icon: Icon(CupertinoIcons.chat_bubble),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              snapshot.data!.stockStatus == 'outofstock' ? Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.secondary,
                                    foregroundColor:  Theme.of(context).colorScheme.onSecondary,
                                    minimumSize: Size(100.0, 42.0),
                                  ),
                                  child: Text(widget.appStateModel.blocks.localeText.outOfStock),
                                  onPressed: null,
                                ),
                              ) : Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                          ),
                                          backgroundColor: Theme.of(context).colorScheme.secondary,
                                          foregroundColor:  Theme.of(context).colorScheme.onSecondary,
                                          minimumSize: Size(100.0, 42.0),
                                        ),
                                        child: addingToCart ? Container(
                                            width: 17,
                                            height: 17,
                                            child: CircularProgressIndicator(
                                                valueColor: new AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).buttonTheme.colorScheme!.onPrimary),
                                                strokeWidth: 2.0)) : Text(widget.appStateModel.blocks.localeText.
                                        addToCart),
                                        onPressed: () {
                                          addToCart(context, widget.product);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                          ),
                                          minimumSize: Size(100.0, 42.0),
                                        ),
                                        child: buyingNow ? Container(
                                            width: 17,
                                            height: 17,
                                            child: CircularProgressIndicator(
                                                valueColor: new AlwaysStoppedAnimation<Color>(
                                                    Theme.of(context).colorScheme.onSecondary),
                                                strokeWidth: 2.0)) : Text(widget.appStateModel.blocks.localeText.
                                        buyNow),
                                        onPressed: () {
                                          buyNow(context, widget.product);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ) : Container(height: 0);
                    }
                ),
              ) : null,
            );
          } else {
            return Scaffold(appBar: AppBar(),
                body: Center(child: LoadingIndicator()));
          }
        });
  }

  _buildSlivers(BuildContext context, Product product) {

    List<Widget> list = [];

    list.add(_buildAppBar(product));

    list.add(_buildNamePrice(product));

    if (product.availableVariations.isNotEmpty &&
        product.availableVariations.length > 0) {
      for (var i = 0; i < product.variationOptions.length; i++) {
        if (product.variationOptions[i].optionList.length != 0) {
          //list.add(buildOptionHeader(product.variationOptions[i].name));
          list.add(buildProductVariations(product.variationOptions[i], product));
        }
      }
    }

    //list.add(_buildQuantityInput());

    if(widget.appStateModel.blocks.settings.catalogueMode != true) {
      if(widget.appStateModel.blocks.settings.productFooterAddToCart == false)
        if(widget.appStateModel.blocks.settings.buyNowButton) {
          list.add(_buildAddToCartAndBuyNow(context, product));
        } else list.add(_buildAddToCart(context, product));
    }

    if(removeAllHtmlTags(product.shortDescription).length > 1)
      list.add(_productShortDescription(product));

    if(widget.appStateModel.blocks.productPageLayout.length > 0) {
      for (var i = 0; i < widget.appStateModel.blocks.productPageLayout.length; i++)
        list.add(SliverBlock(block: widget.appStateModel.blocks.productPageLayout[i]));
    }

    if(removeAllHtmlTags(product.description).length > 1)
      list.add(_productDescription(product));

    list.add(buildWriteYourReview(product));

    //list.add(relatedProductsTitle(widget.appStateModel.blocks.localeText.relatedProducts));
    list.add(buildLisOfReleatedProducts());


    //list.add(crossProductsTitle(widget.appStateModel.blocks.localeText.justForYou));
    list.add(buildLisOfCrossSellProducts());

    //list.add(upsellProductsTitle(widget.appStateModel.blocks.localeText.youMayAlsoLike));
    list.add(buildLisOfUpSellProducts());

    list.add(ReviewsDetailFancy(product: product, productDetailBloc: widget.productDetailBloc));

    list.add(WhyShoppersLoveWidget(product: product, productDetailBloc: widget.productDetailBloc));

    return list;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }

  Widget _buildQuantityInput() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          initialValue: _quantity.toString(),
          decoration: InputDecoration(labelText: 'Quantity'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _quantity = int.parse(value);
            });
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(Product product) {

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
        floating: false,
        pinned: true,
        snap: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
              boxShadow: [
                BoxShadow(color: Colors.transparent),
              ],
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(
                    CupertinoIcons.back,
                    semanticLabel: 'Back',
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  }),
            ),
          ),
        ),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: isDark ? Colors.black : Colors.white,
        expandedHeight: MediaQuery.of(context).size.width - 50,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black
        ),
        actionsIconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black
        ),
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          background: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                splashColor: Theme.of(context).hintColor,
                onTap: () => null,
                child: CachedNetworkImage(
                  imageUrl: product.images[index].src,
                  imageBuilder: (context, imageProvider) => Ink.image(
                    child: InkWell(
                      splashColor: Theme.of(context).hintColor,
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return GalleryView(
                                  images: product.images);
                            }));
                      },
                    ),
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                  placeholder: (context, url) => Container(color: Colors.white),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.white),
                ),
              );
            },
            itemCount: product.images.length,
            pagination: SwiperPagination(builder: FractionPaginationBuilder(), alignment: Alignment.bottomLeft),
            //control: new SwiperControl(),
          )/*CarouselSlider(
            //options: CarouselOptions(height: MediaQuery.of(context).size.width),
              options: CarouselOptions(
                height: 400,
                aspectRatio: 16/9,
                viewportFraction: 1,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                //onPageChanged: callbackFunction,
                scrollDirection: Axis.horizontal,
              ),
            items: product.images.map((image) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                        imageUrl: image.src,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.white),
                        errorWidget: (context, url, error) => Container(color: Colors.white),
                      )
                  );
                },
              );
            }).toList(),
          )*/,
          //background:
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(35),
                color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(color: Colors.transparent),
                ],
              ),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      FluentIcons.share_16_regular,
                      semanticLabel: 'Share',
                    ),
                    onPressed: () async {
                      if(widget.appStateModel.blocks.settings.dynamicLink.isNotEmpty) {
                        String wwref = '?wwref=' + widget.appStateModel.user.id.toString();
                        final url = Uri.parse(product.permalink + '?product_id=' + product.id.toString() + '&title=' + product.name + wwref);
                        final DynamicLinkParameters parameters = DynamicLinkParameters(
                          uriPrefix: widget.appStateModel.blocks.settings.dynamicLink,
                          link: url,
                          socialMetaTagParameters:  SocialMetaTagParameters(
                            title: product.name,
                          ),
                          androidParameters: AndroidParameters(
                            packageName: Config().androidPackageName,
                            minimumVersion: 0,
                          ),
                          iosParameters: IOSParameters(
                            bundleId: Config().iosPackageName,
                          ),
                        );

                        final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
                        Share.share(dynamicLink.shortUrl.toString());

                      } else Share.share(product.permalink);
                    }),
              ),
            ),
          ),
          if(!widget.appStateModel.blocks.settings.catalogueMode)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0,0,8,0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                    boxShadow: [
                      BoxShadow(color: Colors.transparent),
                    ],
                  ),child: SizedBox(
                  width: 40,
                  height: 40,child: CartIcon())),
            ),
        ]
    );
  }

  Widget _buildNamePrice(Product product) {
    return SliverToBoxAdapter(
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, listTileTopPadding, listTileTopPadding, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProductPrice(product: product),
                  WishListIcon(id: product.id)
                ],
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parseHtmlString(product.name)),
                  SizedBox(height: 4),
                  ProductRating(averageRating: product.averageRating, ratingCount: product.ratingCount),
                  if(product.sku != null && product.sku!.isNotEmpty)
                    Column(
                      children: [
                        Text('SKU: '+ product.sku!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _productDescription(Product product) {
    return SliverToBoxAdapter(
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(8, listTileTopPadding, 8, listTileTopPadding),
          title: Html(
            data: product.description.replaceAll('\r\n', '<br>'),
            style: _buildStyle(),
            onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) {
              if(url != null)
                _launchUrl(url, context);
            },
          ),
        ),
      ),
    );
  }

  Widget _productShortDescription(Product product) {
    return SliverToBoxAdapter(
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(8, listTileTopPadding, 8, listTileTopPadding),
          title: Html(
            data: product.shortDescription.replaceAll('\r\n', '<br>'),
            style: _buildStyle(),
            onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) {
              if(url != null)
                _launchUrl(url, context);
            },
          ),
        ),
      ),
    );
  }

  _buildStyle() {
    return {
      "*": Style(textAlign: TextAlign.justify),
      "p": Style(color: Theme.of(context).hintColor),
    };
  }

  buildProductVariations(VariationOption variationOption, Product product) {
    return SliverToBoxAdapter(
      child: CustomCard(
        child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, listTileTopPadding, 16, listTileTopPadding),
          title: Text(variationOption.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold
          )),
          subtitle: Padding(
            padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: variationOption.attributeType == 'image' && variationOption.optionList.any((element) => element.image != null) ? List<Widget>.generate(variationOption.optionList.length, (int index) {
                return GestureDetector(
                  onTap: () => _onSelectVariation(variationOption, index, product),
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: variationOption.selected == variationOption.optionList[index].slug ? Colors.black : Colors.black.withOpacity(0.3),
                      ),
                    ),
                    height: 50,
                    width: 50,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          child: CachedNetworkImage(
                            imageUrl: variationOption.optionList[index].image!,
                            imageBuilder: (context, imageProvider) => Ink.image(
                              child: InkWell(
                                splashColor: Theme.of(context).hintColor,
                              ),
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                            placeholder: (context, url) => Container(color: Colors.white),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(2),
                          child: variationOption.selected == variationOption.optionList[index].slug ? Center(child: Icon(Icons.check, color: Colors.white),) : null,
                        ),
                      ],
                    ),
                  ),
                );
              }) : variationOption.attributeType == 'color' && variationOption.optionList.any((element) => element.color != null) ? List<Widget>.generate(variationOption.optionList.length, (int index) {

                Color borderColor;
                String checkColor = Theme.of(context).brightness == Brightness.light ? '#ffffff' : '#000000';
                if (variationOption.optionList[index].color == checkColor) {
                  borderColor = Colors.black;
                } else {
                  borderColor = HexColor(variationOption.optionList[index].color);
                }

                return GestureDetector(
                  onTap: () => _onSelectVariation(variationOption, index, product),
                  child: Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: variationOption.selected == variationOption.optionList[index].slug ? borderColor : borderColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    height: 50,
                    width: 50,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: HexColor(variationOption.optionList[index].color),
                      ),
                      child: variationOption.selected == variationOption.optionList[index].slug ? Center(child: Icon(Icons.check, color: Colors.white),) : null,
                    ),
                  ),
                );
              }) : List<Widget>.generate(variationOption.optionList.length, (int index) {
                return GestureDetector(
                  onTap: () => _onSelectVariation(variationOption, index, product),
                  child: Chip(
                    shape: StadiumBorder(),
                    backgroundColor: variationOption.selected ==
                        variationOption.optionList[index].slug ? Theme.of(context).colorScheme.secondary : Colors.white10,
                    label: Text(
                      variationOption.optionList[index].name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.0,
                        color: variationOption.selected == variationOption.optionList[index].slug
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddToCartAndBuyNow(BuildContext context, Product product) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8.0),
        child: product.stockStatus == 'outofstock' ? ElevatedButton(
          onPressed: null,
          child: Text(widget.appStateModel.blocks.localeText.outOfStock),
        ) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  addToCart(context, product);
                },
                child: addingToCart ? Container(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).buttonTheme.colorScheme!.onPrimary),
                        strokeWidth: 2.0)) : Text(widget.appStateModel.blocks.localeText.
                addToCart),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor:  Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  buyNow(context, product);
                },
                child: buyingNow ? Container(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onSecondary),
                        strokeWidth: 2.0)) : Text(widget.appStateModel.blocks.localeText.
                buyNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCart(BuildContext context, Product product) {
    return SliverList(
        delegate: SliverChildListDelegate([
          CustomCard(
            child: Container(
                padding: EdgeInsets.fromLTRB(16, listTileTopPadding, 16, listTileTopPadding),
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: product.stockStatus != 'outofstock'
                            ? () {
                          addToCart(context, product);
                        } : null,
                        child: product.stockStatus == 'outofstock' ? Text(widget.appStateModel.blocks.localeText.outOfStock,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme.error)) : addingToCart ? Container(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).buttonTheme.colorScheme!.onPrimary),
                                strokeWidth: 2.0)) : product.type != 'external' ? Text(widget.appStateModel.blocks.localeText.
                        addToCart) : Text(widget.appStateModel.blocks.localeText.
                        buyNow),
                      ),
                    ])),
          ),
        ]));
  }

  Widget buildWriteYourReview(Product product) {
    return SliverToBoxAdapter(
      child: CustomCard(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, listTileTopPadding, 16.0, listTileTopPadding),
          child: Column(
            children:
            [
              StreamBuilder<List<ReviewModel>>(
                  stream: widget.productDetailBloc.allReviews,
                  builder: (context, AsyncSnapshot<List<ReviewModel>> snapshot) {
                    if (snapshot.hasData && snapshot.data!.length > 0) {
                      return InkWell(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewsDetail(product: product, productDetailBloc: widget.productDetailBloc)));
                        },
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              trailing: Icon(CupertinoIcons.forward),
                              title: Text(widget.appStateModel.blocks.localeText.reviews + '(' + snapshot.data!.length.toString() +')'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              child: Row(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: product.averageRating.toString(),
                                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(text: '/5', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey),),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SmoothStarRating(
                                    color: Colors.amber,
                                    borderColor: Colors.amber,
                                    size: 20 ,
                                    rating: double.parse(product.averageRating),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WriteReviewsPage(productId: product.id)));
                },
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  trailing: Icon(CupertinoIcons.forward),
                  title: Text(widget.appStateModel.blocks.localeText.writeYourReview),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget relatedProductsTitle(String title) {
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData && snapshot.data!.relatedProducts.length > 0) {
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
              sliver: SliverToBoxAdapter(
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            );
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget crossProductsTitle(String title) {
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData && snapshot.data!.crossProducts.length > 0) {
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
              sliver: SliverToBoxAdapter(
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            );
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget upsellProductsTitle(String title) {
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData && snapshot.data!.upsellProducts.length > 0) {
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
              sliver: SliverToBoxAdapter(
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            );
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildLisOfReleatedProducts() {
    String title = widget.appStateModel.blocks.localeText.relatedProducts;
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return buildProductList(
                snapshot.data!.relatedProducts, context, title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildLisOfCrossSellProducts() {
    String title =
        widget.appStateModel.blocks.localeText.justForYou;
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return buildProductList(
                snapshot.data!.crossProducts, context, title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildLisOfUpSellProducts() {
    String title =
        widget.appStateModel.blocks.localeText.youMayAlsoLike;
    return StreamBuilder<RelatedProductsModel>(
        stream: widget.productDetailBloc.relatedProducts,
        builder: (context, AsyncSnapshot<RelatedProductsModel> snapshot) {
          if (snapshot.hasData) {
            return buildProductList(
                snapshot.data!.upsellProducts, context, title);
          } else {
            return SliverToBoxAdapter();
          }
        });
  }

  Widget buildProductList(
      List<Product> products, BuildContext context, String title) {
    if (products.length > 0) {
      return widget.appStateModel.blocks.settings.relatedProductScroll ? SliverPadding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 4.0, 4.0),
        sliver: SliverToBoxAdapter(
          child: Container(
            height: widget.appStateModel.blocks.settings.relatedProductHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    width: 200,
                    child: ProductCard(product: products[index])
                );
              },
            ),
          ),
        ),
      ) : SliverPadding(
        padding: const EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 4.0),
        sliver: SliverStaggeredGrid.countBuilder(
          crossAxisCount: (MediaQuery.of(context).size.width ~/ 180).toInt(),
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
          staggeredTileBuilder: (index) {
            return StaggeredTile.fit(1);
          },
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          itemCount: products.length,
        ),
      );
    } else {
      return Container(
        child: SliverToBoxAdapter(),
      );
    }
  }

  Future<void> addToCart(BuildContext context, Product product) async {
    if(product.type != 'external') {
      setState(() {
        addingToCart = true;
      });
      var data = new Map<String, dynamic>();
      data['product_id'] = product.id.toString();
      //data['add-to-cart'] = product.id.toString();
      data['quantity'] = _quantity.toString();
      var doAdd = true;
      if (product.type == 'variable' &&
          product.variationOptions != null) {
        for (var i = 0; i < product.variationOptions.length; i++) {
          if (product.variationOptions[i].selected != null) {
            String key = product.variationOptions[i].attribute.toLowerCase().replaceAll(' ', '-').replaceAll("'", "");
            data['variation[attribute_' + key + ']'] = product.variationOptions[i].selected;
            data['attribute_' + key] = product.variationOptions[i].selected;
            if(!key.startsWith('pa_')) {
              key = 'pa_' + key;
              data['variation[attribute_' + key + ']'] = product.variationOptions[i].selected;
              data['attribute_' + key] = product.variationOptions[i].selected;
            }
          } else if (product.variationOptions[i].selected == null &&
              product.variationOptions[i].optionList.length != 0) {
            showSnackBarError(context, widget.appStateModel.blocks.localeText.select + ' ' + product.variationOptions[i].name);
            doAdd = false;
            break;
          } else if (product.variationOptions[i].selected == null &&
              product.variationOptions[i].optionList.length == 0) {
            showSnackBarError(context, widget.appStateModel.blocks.localeText.select + ' ' + product.variationOptions[i].name);
            doAdd = false;
            /*setState(() {
              product.stockStatus = 'outofstock';
            });*/
            doAdd = false;
            break;
          }
        }
        if (product.variationId != null) {
          data['variation_id'] = product.variationId;
        }
      }
      if (doAdd) {
        if (addonFormKey.currentState != null && addonFormKey.currentState!.validate()) {
          addonFormKey.currentState!.save();
          data.addAll(addOnsFormData);
        }
        bool status = await context.read<ShoppingCart>().addToCartWithData(data, context);
      }
      setState(() {
        addingToCart = false;
      });
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WebViewPage(url: product.addToCartUrl, title: product.name),
          ));
    }
  }

  Future<void> buyNow(BuildContext context, Product product) async {
    setState(() {
      buyingNow = true;
    });
    var data = new Map<String, dynamic>();
    data['product_id'] = product.id.toString();
    //data['add-to-cart'] = product.id.toString();
    data['quantity'] = _quantity.toString();
    var doAdd = true;
    if (product.type == 'variable' &&
        product.variationOptions != null) {
      for (var i = 0; i < product.variationOptions.length; i++) {
        if (product.variationOptions[i].selected != null) {
          String key = product.variationOptions[i].attribute.toLowerCase().replaceAll(' ', '-').replaceAll("'", "");
          data['variation[attribute_' + key + ']'] = product.variationOptions[i].selected;
          data['attribute_' + key] = product.variationOptions[i].selected;
          if(!key.startsWith('pa_')) {
            key = 'pa_' + key;
            data['variation[attribute_' + key + ']'] = product.variationOptions[i].selected;
            data['attribute_' + key] = product.variationOptions[i].selected;
          }
        } else if (product.variationOptions[i].selected == null &&
            product.variationOptions[i].optionList.length != 0) {
          showSnackBarError(context, widget.appStateModel.blocks.localeText.select + ' ' + product.variationOptions[i].name);
          doAdd = false;
          break;
        } else if (product.variationOptions[i].selected == null &&
            product.variationOptions[i].optionList.length == 0) {
          showSnackBarError(context, widget.appStateModel.blocks.localeText.select + ' ' + product.variationOptions[i].name);
          doAdd = false;
          /*setState(() {
              product.stockStatus = 'outofstock';
            });*/
          doAdd = false;
          break;
        }
      }
      if (product.variationId != null) {
        data['variation_id'] = product.variationId;
      }
    }
    if (doAdd) {
      if (addonFormKey.currentState != null && addonFormKey.currentState!.validate()) {
        addonFormKey.currentState!.save();
        data.addAll(addOnsFormData);
      }
      bool status = await context.read<ShoppingCart>().addToCartWithData(data, context);
      if(status) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => CartPage(),
            ));
      }
    }
    setState(() {
      buyingNow = false;
    });
  }

  void _launchUrl(String url, BuildContext context) {
    if(url.contains('https://wa.me/') || url.contains('mailto:') || url.contains('sms:') || url.contains('tel:') || url.contains('https://m.me/')) {
      launchUrl(Uri.parse(url));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(url: url)));
    }
  }

  Widget buildProductVariationsImages(AvailableVariation variation, Product product) {
    return InkWell(
      onTap: () {
        product.variationOptions[0].selected = variation.option.first.value;
        product.variationId = variation.variationId
            .toString();
        if(variation.displayPrice != null)
          product.regularPrice = variation.displayPrice!
              .toDouble();
        product.formattedPrice = variation.formattedPrice;
        if(variation.formattedSalesPrice != null)
          product.formattedSalesPrice = variation.formattedSalesPrice;

        if(variation.image.fullSrc.isNotEmpty && variation.image.fullSrc.isNotEmpty)
          product.images[0].src = variation.image.fullSrc;

        if (variation.displayRegularPrice !=
            variation.displayPrice) {
          product.salePrice = variation.displayRegularPrice!
              .toDouble();
        }
        else {
          product.formattedSalesPrice = null;
        }
        setState(() {});
      },
      child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              border: Border.all(color: product.variationId == variation.variationId.toString() ? Theme.of(context).primaryColor : Theme.of(context).focusColor)
          ),
          child: Image.network(variation.image.src)),
    );
  }

  Widget buildOptionHeader(String name) {
    return SliverToBoxAdapter(
      child: Container(
          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
          child: Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
          )),
    );
  }

  _chatWithVendorOrAdmin() {
    if(widget.appStateModel.user.id > 0) {
      if(widget.product.vendor.UID != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FireBaseChat(otherUserId: widget.product.vendor.UID!);
        }));
      } else {
        List ids = AppStateModel().blocks.siteSettings.adminUIDs;
        if(ids.length > 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FireBaseChat(otherUserId: AppStateModel().blocks.siteSettings.adminUIDs.first)));
        }
      }
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    }
  }

  _onSelectVariation(VariationOption variationOption, int index, Product product) {
    setState(() {
      variationOption.selected = variationOption.optionList[index].slug;
      product.stockStatus = 'instock';
    });
    if (product.variationOptions
        .every((option) => option.selected != null)) {
      var selectedOptions = [];
      var matchedOptions = [];
      for (var i = 0;
      i < product.variationOptions.length;
      i++) {
        selectedOptions
            .add(product.variationOptions[i].selected);
      }
      for (var i = 0;
      i < product.availableVariations.length;
      i++) {
        matchedOptions = [];
        for (var j = 0;
        j < product.availableVariations[i].option.length;
        j++) {
          if (selectedOptions.contains(product
              .availableVariations[i].option[j].slug) ||
              product.availableVariations[i].option[j].slug
                  .isEmpty) {
            matchedOptions.add(product.availableVariations[i].option[j].slug);
          }
        }
        if (matchedOptions.length == selectedOptions.length) {
          setState(() {
            product.variationId = product.availableVariations[i].variationId.toString();
            if(product.availableVariations[i].displayPrice != null)
              product.regularPrice = product.availableVariations[i].displayPrice!
                  .toDouble();
            product.formattedPrice = product.availableVariations[i].formattedPrice;
            if(product.availableVariations[i].formattedSalesPrice != null)
              product.formattedSalesPrice = product.availableVariations[i].formattedSalesPrice;

            if(product.availableVariations[i].image.fullSrc.isNotEmpty && product
                .availableVariations[i].image.fullSrc.isNotEmpty)
              product.images[0].src = product
                  .availableVariations[i].image.fullSrc;

            if (product.availableVariations[i]
                .displayRegularPrice !=
                product.availableVariations[i].displayPrice) {
              product.salePrice = product
                  .availableVariations[i].displayRegularPrice!
                  .toDouble();
            }
            else
              product.formattedSalesPrice = null;
          });
          if (!product.availableVariations[i].isInStock) {
            setState(() {
              product.stockStatus = 'outofstock';
            });
          }
          break;
        }
      }
      /*if (matchedOptions.length != selectedOptions.length) {
                        setState(() {
                          product.stockStatus = 'outofstock';
                        });
                      }*/
    }
  }
}

class ProductPrice extends StatelessWidget {
  ProductPrice({
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


    //bool onSale = (this.product.onSale && product.formattedSalesPrice != null && product.formattedSalesPrice!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4.0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //alignment: WrapAlignment.start,
        //crossAxisAlignment: WrapCrossAlignment.center,
        //spacing: 4,
        children: <Widget>[
          if(product.onSale && product.formattedSalesPrice != null)
            Text(parseHtmlString(product.formattedSalesPrice!),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              )),
          //onSale ? SizedBox(width: 6.0) : SizedBox(width: 0.0),
          Row(
            children: [
              Text(
                  (product.formattedPrice != null &&
                      product.formattedPrice!.isNotEmpty)
                      ? parseHtmlString(product.formattedPrice!)
                      : '',
                  style: product.onSale && (product.formattedSalesPrice != null &&
                      product.formattedSalesPrice!.isNotEmpty) ? Theme.of(context).textTheme.bodySmall!.copyWith(
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      decorationColor: Theme.of(context).hintColor.withOpacity(0.5)
                  ) : Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  )
              ),
              product.onSale && product.formattedSalesPrice != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
          ),
        ],
      ),
    );
  }
}

class FractionPaginationBuilder extends SwiperPlugin {
  ///color ,if set null , will be Theme.of(context).scaffoldBackgroundColor
  final Color? color;

  ///color when active,if set null , will be Theme.of(context).primaryColor
  final Color? activeColor;

  ////font size
  final double fontSize;

  ///font size when active
  final double activeFontSize;

  final Key? key;

  const FractionPaginationBuilder(
      {this.color,
        this.fontSize= 10.0,
        this.key,
        this.activeColor,
        this.activeFontSize= 14.0});

  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    ThemeData themeData = Theme.of(context);
    Color activeColor = this.activeColor ?? themeData.primaryColor;
    Color color = this.color ?? Colors.black;

    if (Axis.vertical == config.scrollDirection) {
      return new Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(
            "${config.activeIndex + 1}",
            style: TextStyle(color: activeColor, fontSize: activeFontSize),
          ),
          new Text(
            "/",
            style: TextStyle(color: color, fontSize: fontSize),
          ),
          new Text(
            "${config.itemCount}",
            style: TextStyle(color: color, fontSize: fontSize),
          )
        ],
      );
    } else {
      return SizedBox(
        height: 30,
        width: 50,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
            boxShadow: [
              BoxShadow(color: Colors.transparent),
            ],
          ), child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              key: key,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text(
                  "${config.activeIndex + 1}",
                  style: TextStyle(color: activeColor, fontSize: activeFontSize),
                ),
                new Text(
                  " / ${config.itemCount}",
                  style: TextStyle(color: color, fontSize: fontSize),
                )
              ],
            ),
          ),
        ),
        ),
      );
    }
  }
}

class ReviewsDetailFancy extends StatefulWidget {
  final ProductDetailBloc productDetailBloc;
  final Product product;

  const ReviewsDetailFancy({
    Key? key,
    required this.productDetailBloc,
    required this.product,
  }) : super(key: key);

  @override
  State<ReviewsDetailFancy> createState() => _ReviewsDetailFancyState();
}

class _ReviewsDetailFancyState extends State<ReviewsDetailFancy> {
  // Replace the old textual filters with star-based labels:
  final List<String> filterLabels = [
    '5 Stars',
    '4 Stars',
    '3 Stars',
    '2 Stars',
    '1 Star',
  ];

  // Track which star filters are selected (we allow multiple).
  final Set<String> _selectedFilters = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Example color choices:
    final verifiedPurchaseBg = isDark
        ? Colors.green.withOpacity(0.15)
        : Colors.green.shade50;
    final verifiedPurchaseText = isDark
        ? Colors.green.shade200
        : Colors.green.shade800;

    return SliverToBoxAdapter(
      child: StreamBuilder<List<ReviewModel>>(
        stream: widget.productDetailBloc.allReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Container();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // No reviews found
            return Container();
          }

          // Grab all reviews
          final allReviews = snapshot.data!;
          final totalCount = allReviews.length;

          // Sort descending by rating
          final sortedReviews = List<ReviewModel>.from(allReviews)
            ..sort((a, b) =>
                double.parse(b.rating).compareTo(double.parse(a.rating)));

          // Filter reviews based on selected star rating(s)
          final filtered = _filterReviewsByStars(sortedReviews);

          // Take the top 2 from the filtered list
          final topSix = filtered.take(2).toList();

          // Build the fancy UI
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row: "Reviews" text and arrow
                Container(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewsDetail(
                            product: widget.product,
                            productDetailBloc: widget.productDetailBloc,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      splashColor: Colors.transparent,
                      contentPadding: EdgeInsets.all(0),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      title: Text('Reviews', style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                ),

                // "All from verified purchases"
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: verifiedPurchaseBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'All from verified purchases',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: verifiedPurchaseText,
                    ),
                  ),
                ),

                // Average Rating + Stars + totalCount
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.product.averageRating.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    RatingBarIndicator(
                      rating:
                      double.tryParse(widget.product.averageRating) ?? 0.0,
                      itemSize: 20,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalCount ratings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Scrollable star-based filter labels
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterLabels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final label = filterLabels[index];
                      return ChoiceChip(
                        label: Text(label),
                        selected: _selectedFilters.contains(label),
                        selectedColor: isDark
                            ? Colors.amber.withOpacity(0.3)
                            : Colors.amber.shade100,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedFilters.add(label);
                            } else {
                              _selectedFilters.remove(label);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Only 2 top reviews (filtered)
                if (topSix.isEmpty)
                  Text(
                    'No reviews match your filters.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  )
                else
                  ...topSix.map((review) => _buildReviewItem(context, review)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds each review item
  Widget _buildReviewItem(BuildContext context, ReviewModel review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ratingVal = double.tryParse(review.rating) ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Star rating
          RatingBarIndicator(
            rating: ratingVal,
            itemSize: 16,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),

          const SizedBox(height: 8),

          // Review content
          Html(
            data: review.content,
            style: {
              // You can also define custom styling for dark mode here if needed
              'body': Style(
                color: isDark ? Colors.grey[300] : Colors.black,
              ),
            },
          ),

          const SizedBox(height: 8),

          // Author and date
          Text(
            '${review.author}, ${timeago.format(review.date)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const Divider(thickness: 0.5),
        ],
      ),
    );
  }

  /// Filters the sorted reviews based on selected star(s).
  /// Example logic: If user taps "4 Stars", we only keep reviews where floor(rating) == 4.
  List<ReviewModel> _filterReviewsByStars(List<ReviewModel> reviews) {
    // If no filters selected, return all
    if (_selectedFilters.isEmpty) {
      return reviews;
    }

    return reviews.where((review) {
      final starFloor = (double.tryParse(review.rating) ?? 0.0).floor();

      // Check if any label matches this rating
      // e.g. label "4 Stars" => starFloor == 4
      for (var label in _selectedFilters) {
        final starNumber = _labelToStar(label);
        if (starFloor == starNumber) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  /// Helper method to convert label like "4 Stars" to integer 4
  int _labelToStar(String label) {
    switch (label) {
      case '5 Stars':
        return 5;
      case '4 Stars':
        return 4;
      case '3 Stars':
        return 3;
      case '2 Stars':
        return 2;
      case '1 Star':
        return 1;
      default:
        return 0; // fallback if something unexpected
    }
  }
}

class WhyShoppersLoveWidget extends StatefulWidget {
  final ProductDetailBloc productDetailBloc;
  final Product product;

  const WhyShoppersLoveWidget({
    Key? key,
    required this.productDetailBloc,
    required this.product,
  }) : super(key: key);

  @override
  State<WhyShoppersLoveWidget> createState() => _WhyShoppersLoveWidgetState();
}

class _WhyShoppersLoveWidgetState extends State<WhyShoppersLoveWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: StreamBuilder<List<ReviewModel>>(
        stream: widget.productDetailBloc.allReviews,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox();
          }
          // We have reviews
          final allReviews = snapshot.data!;

          // 1) Filter only 4- and 5-star reviews
          final highRated = allReviews.where((r) {
            final ratingVal = double.tryParse(r.rating) ?? 0.0;
            return ratingVal >= 4.0;
          }).toList();

          if (highRated.isEmpty) {
            // No 4/5 star reviews
            return const SizedBox();
          }

          // 2) Randomly select up to 10 from these high-rated reviews
          highRated.shuffle(); // shuffle in-place
          final topTen = highRated.take(10).toList();

          // 3) Build the horizontal list
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'See why shoppers love this item',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Horizontal Scroll of "cards"
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: topTen.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final review = topTen[index];
                      return _buildReviewCard(context, review);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds each "card" with anonymized author and partial review content.
  Widget _buildReviewCard(BuildContext context, ReviewModel review) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authorName = _maskAuthorName(review.author);

    // Choose a suitable background color for the card in dark mode
    final cardColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    // For text, we can rely on theme’s body color or do manual logic
    final textColor = isDark ? Colors.grey[200] : Colors.black87;

    return Container(
      width: 260, // Adjust as desired
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subheader: "Content about a similar item m***r"
          Text(
            'Content about a similar item $authorName',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          // The review content itself
          Expanded(
            child: SingleChildScrollView(
              // or just a Text with some maxLines if you prefer
              child: Text(
                review.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Example logic to partially mask the author's name
  String _maskAuthorName(String author) {
    if (author.length <= 2) {
      return author; // Can't meaningfully mask
    }
    final first = author[0];
    final last = author[author.length - 1];
    return '$first***$last';
  }
}
