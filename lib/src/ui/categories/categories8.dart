import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../functions.dart';
import '../../models/category_model.dart';
import '../products/products/products.dart';

class Categories8 extends StatefulWidget {
  @override
  _Categories8State createState() => _Categories8State();
}

class _Categories8State extends State<Categories8> {
  late List<Category> mainCategories;
  late Category selectedCategory;
  late AppStateModel appStateModel;

  @override
  void initState() {
    super.initState();
    appStateModel = AppStateModel.instance;
    mainCategories = appStateModel.blocks.categories.where((cat) => cat.parent == 0).toList();
    selectedCategory = mainCategories.isNotEmpty ? mainCategories.first : Category(id: 0, name: 'All');
  }

  void onCategoryTap(Category category) {
    onCategoryClick(category, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStateModel.blocks.localeText.categories),
      ),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            return buildList();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildList() {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width ~/ 120,
        childAspectRatio: 9 / 10,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: mainCategories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return CategoryItem(category: mainCategories[index], onCategoryTap: onCategoryTap);
      },
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final void Function(Category category) onCategoryTap;

  CategoryItem({required this.category, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
      child: InkWell(
        onTap: () => onCategoryTap(category),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: CachedNetworkImage(
                imageUrl: category.image ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black12),
                errorWidget: (context, url, error) => Container(color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                parseHtmlString(category.name),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

