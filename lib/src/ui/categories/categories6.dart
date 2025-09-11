import 'dart:ui';

import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../functions.dart';
import '../../models/category_model.dart';
import '../products/products/products.dart';

class Categories6 extends StatefulWidget {
  @override
  _Categories6State createState() => _Categories6State();
}

class _Categories6State extends State<Categories6> {
  late List<Category> mainCategories;
  late List<Category> subCategories;
  late Category selectedCategory;
  int selectedCategoryIndex = 0;
  final appStateModel = AppStateModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStateModel.blocks.localeText.categories),
      ),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            mainCategories = model.blocks.categories.where((cat) => cat.parent == 0).toList();
            if (mainCategories.isNotEmpty) {
              selectedCategory = mainCategories[selectedCategoryIndex];
              subCategories = model.blocks.categories.where((cat) => cat.parent == selectedCategory.id).toList();
            }
            return buildList();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildList() {
    return ListView.builder(
      itemCount: mainCategories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return Column(
          children: <Widget>[
            CategoryRow(category: mainCategories[index], onCategoryTap: onCategoryTap),
            Divider(height: 0),
          ],
        );
      },
    );
  }

  void onCategoryTap(Category category, BuildContext context) {
    onCategoryClick(selectedCategory, context);
    /*var filter = new Map<String, dynamic>();
    filter['id'] = category.id.toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductsWidget(filter: filter, name: category.name),
      ),
    );*/
  }
}

class CategoryRow extends StatelessWidget {
  final Category category;
  final void Function(Category category, BuildContext context) onCategoryTap;

  CategoryRow({required this.category, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () => onCategoryTap(category, context),
        child: Stack(
          children: [
            Container(
              height: 170,
              child: buildFeaturedImage(),
            ),
            Container(
              height: 170,
              child: buildGradientBackdrop(),
            ),
            buildCategoryName(),
          ],
        ),
      ),
    );
  }

  Widget buildFeaturedImage() {
    return CachedNetworkImage(
      imageUrl: category.banner ?? category.image,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(color: Colors.black12),
      errorWidget: (context, url, error) => Container(color: Colors.white),
    );
  }

  Widget buildGradientBackdrop() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black54, Colors.black38],
          begin: Alignment.bottomCenter,
          end: Alignment(0.0, 0.0),
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }

  Widget buildCategoryName() {
    return Container(
      height: 170,
      child: Center(
        child: Text(
          parseHtmlString(category.name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, color: Colors.white),
        ),
      ),
    );
  }
}
