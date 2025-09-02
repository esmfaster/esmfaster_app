import 'dart:ui';

import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../src/models/app_state_model.dart';
import '../../functions.dart';
import '../../models/category_model.dart';
import '../products/products/products.dart';


import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../functions.dart';
import '../../models/category_model.dart';
import '../products/products/products.dart';

class Categories4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStateModel().blocks.localeText.categories)),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            return CategoryList(
              categories: model.blocks.categories,
              onTapCategory: _onTap,
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _onTap(Category category, BuildContext context) {
    onCategoryClick(category, context);
  }
}

class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Function onTapCategory;

  const CategoryList({
    Key? key,
    required this.categories,
    required this.onTapCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainCategories = categories.where((cat) => cat.parent == 0).toList();
    return ListView.builder(
      itemCount: mainCategories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return CategoryItem(
          category: mainCategories[index],
          onTap: onTapCategory,
          categories: categories,
        );
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final Function onTap;
  final List<Category> categories;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.onTap,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subCategories =
    categories.where((item) => item.parent == category.id).toList();
    return subCategories.isEmpty
        ? _buildTile(context)
        : _buildExpansionTile(context, subCategories);
  }

  Widget _buildTile(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          trailing: Icon(CupertinoIcons.forward),
          dense: true,
          onTap: () => onTap(category, context),
          title: Text(
            parseHtmlString(category.name),
            style: menuItemStyle(context),
          ),
        ),
        Divider(height: 0, thickness: 0),
      ],
    );
  }

  Widget _buildExpansionTile(
      BuildContext context, List<Category> subCategories) {
    return ExpansionTile2(
      key: PageStorageKey<Category>(category),
      title: Text(
        parseHtmlString(category.name),
        style: menuItemStyle(context),
      ),
      children: subCategories
          .map((subCategory) => CategoryItem(
        category: subCategory,
        onTap: onTap,
        categories: categories,
      ))
          .toList(),
    );
  }

  TextStyle menuItemStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      fontSize: 12,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black.withOpacity(0.8)
          : Colors.grey,
    );
  }
}


const Duration _kExpand = Duration(milliseconds: 200);

/// A single-line [ListTile] with a trailing button that expands or collapses
/// the tile to reveal or hide the [children].
///
/// This widget is typically used with [ListView] to create an
/// "expand / collapse" list entry. When used with scrolling widgets like
/// [ListView], a unique [PageStorageKey] must be specified to enable the
/// [ExpansionTile2] to save and restore its expanded state when it is scrolled
/// in and out of view.
///
/// See also:
///
///  * [ListTile], useful for creating expansion tile [children] when the
///    expansion tile represents a sublist.
///  * The "Expand/collapse" section of
///    <https://material.io/guidelines/components/lists-controls.html>.
class ExpansionTile2 extends StatefulWidget {
  /// Creates a single-line [ListTile] with a trailing button that expands or collapses
  /// the tile to reveal or hide the [children]. The [initiallyExpanded] property must
  /// be non-null.
  const ExpansionTile2({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.backgroundColor,
    this.onExpansionChanged,
    this.children = const <Widget>[],
    this.trailing,
    this.initiallyExpanded = false,
  })  : assert(initiallyExpanded != null),
        super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list item.
  ///
  /// Typically a [Text] widget.
  final Widget title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool>? onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  /// The color to display behind the sublist when expanded.
  final Color? backgroundColor;

  /// A widget to display instead of a rotating arrow icon.
  final Widget? trailing;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  @override
  _ExpansionTile2State createState() => _ExpansionTile2State();
}

class _ExpansionTile2State extends State<ExpansionTile2>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();
  final ColorTween _iconColorTween = ColorTween();
  final ColorTween _backgroundColorTween = ColorTween();

  late AnimationController _controller;
  late Animation<double> _iconTurns;
  late Animation<double> _heightFactor;
  late Animation<Color?> _borderColor;
  late Animation<Color?> _headerColor;
  late Animation<Color?> _iconColor;
  late Animation<Color?> _backgroundColor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _borderColor = _controller.drive(_borderColorTween.chain(_easeOutTween));
    _headerColor = _controller.drive(_headerColorTween.chain(_easeInTween));
    _iconColor = _controller.drive(_iconColorTween.chain(_easeInTween));
    _backgroundColor =
        _controller.drive(_backgroundColorTween.chain(_easeOutTween));

    _isExpanded =
        PageStorage.of(context).readState(context) ?? widget.initiallyExpanded;
    if (_isExpanded) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {
            // Rebuild without widget.children.
          });
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
    if (widget.onExpansionChanged != null)
      widget.onExpansionChanged!(_isExpanded);
  }


  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.children),
    );
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    final Color borderSideColor = _borderColor.value ?? Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: _isExpanded
            ? _backgroundColor.value ?? Colors.brown.withOpacity(0.1)
            : Colors.transparent,
        border: Border(
          // top: BorderSide(color: borderSideColor),
          // bottom: BorderSide(color: borderSideColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme.merge(
            iconColor: _iconColor.value,
            textColor: _headerColor.value,
            child: ListTile(
              dense: true,
              onTap: _handleTap,
              leading: widget.leading,
              title: widget.title,
              subtitle: widget.subtitle,
              trailing: _isExpanded
                  ? RotationTransition(
                turns: _iconTurns,
                child: const Icon(Icons.remove),
              )
                  : RotationTransition(
                turns: _iconTurns,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Divider(height: 0, thickness: 0),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}