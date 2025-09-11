import 'dart:ui';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../functions.dart';
import '../../models/category_model.dart';

class Categories7 extends StatefulWidget {
  final AppStateModel appStateModel = AppStateModel();
  @override
  _Categories7State createState() => _Categories7State();
}

class _Categories7State extends State<Categories7> {
  late List<Category> mainCategories;
  late List<Category> filteredCategories;
  late Category selectedCategory;
  int selectedCategoryIndex = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    mainCategories = widget.appStateModel.blocks.categories.where((cat) => cat.parent == 0).toList();
    filteredCategories = mainCategories;
    if (mainCategories.isNotEmpty) {
      selectedCategory = mainCategories[selectedCategoryIndex];
    }
  }

  void onCategoryTap(Category category) {
    onCategoryClick(selectedCategory, context);
  }

  void _filterCategories() {
    setState(() {
      filteredCategories = mainCategories
          .where((cat) => cat.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appStateModel.blocks.localeText.categories),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoTextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _filterCategories();
                });
              },
              placeholder: widget.appStateModel.blocks.localeText.search + '...',
              placeholderStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black45,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.search,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black45,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            return buildList();
          }
          return Center(child: Container());
        },
      ),
    );
  }

  Widget buildList() {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width ~/ 180,
          childAspectRatio: 9 / 9,
        ),
        itemCount: filteredCategories.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              CategoryRow(
                category: filteredCategories[index],
                onCategoryTap: onCategoryTap,
              ),
              Divider(height: 0),
            ],
          );
        },
      ),
    );
  }
}

class CategoryRow extends StatelessWidget {
  final Category category;
  final void Function(Category category) onCategoryTap;

  CategoryRow({required this.category, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width ~/ 180;
    double height = (MediaQuery.of(context).size.width - (crossAxisCount * 16)) / crossAxisCount;

    Widget featuredImage = category.image.isNotEmpty
        ? CachedNetworkImage(
      imageUrl: category.image,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(color: Colors.black12),
      errorWidget: (context, url, error) => Container(color: Colors.white),
    )
        : Container();

    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => onCategoryTap(category),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Container(height: height, child: featuredImage),
                Container(
                  height: height,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.black38],
                          begin: Alignment.bottomCenter,
                          end: Alignment(0.0, 0.0),
                          tileMode: TileMode.clamp,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: height,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        parseHtmlString(category.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
