import 'package:app/src/ui/products/product_cards/grid/product_in_grid.dart';
import 'package:app/src/ui/products/product_detail/cart_icon.dart';
import 'package:app/src/ui/products/products/product_list_page.dart';
import 'package:app/src/ui/widgets/progress_indicator.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '../../../../src/ui/home/search.dart';
import '../../../blocs/products_bloc.dart';
import '../../../functions.dart';
import '../../../models/app_state_model.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../product_detail/product_detail.dart';
import '../product_filter/filter.dart';

class ProductsWidget extends StatefulWidget {
  final ProductsBloc productsBloc = ProductsBloc();
  final Map<String, dynamic> filter;
  final String? name;
  final AppStateModel model = AppStateModel();

  ProductsWidget({Key? key, required this.filter, this.name}) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> with SingleTickerProviderStateMixin {
  ScrollController _scrollController = new ScrollController();
  late TabController _tabController;
  Category? selectedCategory;
  late List<Category> subCategories;
  bool listView = false;
  Color? fillColor;
  late final border;

  @override
  void initState() {
    super.initState();

    border = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(widget.model.blocks.settings.appBarStyle.borderRadius),
      ),
      borderSide: BorderSide(color: Colors.transparent),
    );

    widget.model.selectedRange = RangeValues(0, widget.model.blocks.maxPrice.toDouble());
    widget.filter['id'] ??= '0';

    widget.productsBloc.productsFilter = widget.filter;
    subCategories = widget.model.blocks.categories.where(
          (cat) => cat.parent.toString() == widget.productsBloc.productsFilter['id'],
    ).toList();

    if (subCategories.isNotEmpty) {
      subCategories.insert(
        0,
        Category(
          name: widget.model.blocks.localeText.all,
          id: int.parse(widget.filter['id']!),
        ),
      );
    }

    _tabController = TabController(vsync: this, length: subCategories.length)
      ..index = 0;

    widget.productsBloc.fetchAllProducts(
      widget.productsBloc.productsFilter['id']!,
    );
    widget.productsBloc.fetchProductsAttributes();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          widget.productsBloc.hasMoreItems.value == true) {
        widget.productsBloc.loadMore(
          widget.productsBloc.productsFilter['id']!,
        );
      }
    });

    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    final int index = _tabController.index;
    final String categoryId = subCategories[index].id.toString();

    if (widget.productsBloc.productsFilter['id'] != categoryId) {
      widget.productsBloc.productsFilter['id'] = categoryId;
      widget.model.selectedRange = RangeValues(
        0,
        widget.model.blocks.maxPrice.toDouble(),
      );

      widget.productsBloc.fetchAllProducts(categoryId);

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }

      setState(() {
        selectedCategory = subCategories[index];
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    widget.productsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: _buildAppBarBottom(),
        title: Text(widget.name ?? ''),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget? _buildAppBarBottom() {
    if (subCategories.isNotEmpty) {
      return PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              buildSearchField(context),
              TabBar(
                isScrollable: true,
                controller: _tabController,
                indicatorWeight: widget.model.blocks.settings.bottomTabBarStyle.indicatorWeight,
                indicatorSize: widget.model.blocks.settings.bottomTabBarStyle.tabBarIndicatorSize,
                tabs: subCategories
                    .map<Widget>((category) => Tab(text: parseHtmlString(category.name)))
                    .toList(),
              ),
            ],
          ),
        ),
      );
    } else {
      return PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: Align(
          alignment: Alignment.centerLeft,
          child: buildSearchField(context),
        ),
      );
    }
  }

  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[
      IconButton(
        icon: Icon(listView ? CupertinoIcons.rectangle_grid_2x2 : CupertinoIcons.rectangle_grid_1x2),
        onPressed: () {
          setState(() {
            listView = !listView;
          });
        },
      ),
      IconButton(
        icon: Icon(FlutterRemix.arrow_up_down_line),
        onPressed: _showPopupMenu,
      ),
      IconButton(
        icon: Icon(Icons.tune),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FilterProduct(productsBloc: widget.productsBloc)),
          );
        },
      ),
    ];

    if (!widget.model.blocks.settings.catalogueMode) {
      actions.add(CartIcon());
    }

    return actions;
  }

  Widget _buildBody() {
    return StreamBuilder<List<Product>>(
      stream: widget.productsBloc.allProducts,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          if (snapshot.data!.isEmpty) {
            return StreamBuilder<bool>(
              stream: widget.productsBloc.isLoadingProducts,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Center(child: LoadingIndicator());
                } else {
                  return Center(child: Container(child: Text(widget.model.blocks.localeText.noProducts)));
                }
              },
            );
          } else {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                listView ? ProductListPage(products: snapshot.data!) : ProductGridPage(products: snapshot.data!),
                SliverToBoxAdapter(
                  child: Container(
                    height: 60,
                    child: StreamBuilder<bool>(
                      stream: widget.productsBloc.hasMoreItems,
                      builder: (context, snapshot) {
                        return (snapshot.hasData && snapshot.data == false)
                            ? Center(child: Text(widget.model.blocks.localeText.noMoreProducts))
                            : Center(child: LoadingIndicator());
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else {
          return Center(child: LoadingIndicator());
        }
      },
    );
  }

  Container buildSearchField(BuildContext context) {
    final double borderRadius =
        widget.model.blocks.settings.appBarStyle.borderRadius;

    final ThemeData theme = Theme.of(context);
    final Brightness brightness = theme.brightness;
    final Color? backgroundColor =
    theme.appBarTheme.backgroundColor?.value == 0xFFFFFFFF
        ? null
        : brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        enableFeedback: false,
        splashColor: Colors.transparent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return Search(
                filter: widget.productsBloc.productsFilter,
                hintText: selectedCategory != null
                    ? '${widget.model.blocks.localeText.searchIn} ${parseHtmlString(selectedCategory!.name)}'
                    : widget.model.blocks.localeText.search,
              );
            }),
          );
        },
        child: TextField(
          showCursor: false,
          enabled: false,
          decoration: InputDecoration(
            hintText: selectedCategory != null
                ? '${widget.model.blocks.localeText.searchIn} ${parseHtmlString(selectedCategory!.name)}'
                : widget.model.blocks.localeText.search,
            fillColor: backgroundColor,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            contentPadding: EdgeInsets.all(4),
            prefixIcon: DunesIcon(
              iconString: widget.model.blocks.settings.searchIcon,
              color: brightness == Brightness.dark
                  ? Colors.grey[700]
                  : CupertinoColors.placeholderText,
            ),
          ),
        ),
      ),
    );
  }

  void _showPopupMenu() async {
    final result = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(150, 60, 50, 100),
      items: [
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.date,
          value: ['date', 'ASC'],
        ),
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.priceHighToLow,
          value: ['price', 'DESC'],
        ),
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.priceLowToHigh,
          value: ['price', 'ASC'],
        ),
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.newArrivals,
          value: ['date', 'DESC'],
        ),
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.popular,
          value: ['popularity', 'ASC'],
        ),
        _buildPopupMenuItem(
          text: widget.model.blocks.localeText.rating,
          value: ['rating', 'ASC'],
        ),
      ],
      elevation: 4.0,
    );

    if (result != null) _sort(result[0], result[1]);
  }

  PopupMenuItem<List<String>> _buildPopupMenuItem({
    required String text,
    required List<String> value,
  }) {
    return PopupMenuItem<List<String>>(
      child: Text(text),
      value: value,
    );
  }

  _sort(String orderBy, String order) {
    widget.productsBloc.productsFilter['order'] = order;
    widget.productsBloc.productsFilter['orderby'] = orderBy;
    widget.productsBloc.reset();
    widget.productsBloc.fetchAllProducts(widget.productsBloc.productsFilter['id']);
  }

  onProductClick(data) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProductDetail(product: data);
    }));
  }
}

