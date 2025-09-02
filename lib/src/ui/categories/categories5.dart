import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../functions.dart';
import '../../models/blocks_model.dart' hide Image, Key;
import '../../models/category_model.dart';
import '../products/products/products.dart';

class Categories5 extends StatefulWidget {
  @override
  _Categories5State createState() => _Categories5State();
}

class _Categories5State extends State<Categories5> {
  late List<Category> mainCategories;
  late List<Category> subCategories;
  late Category selectedCategory;
  int mainCategoryId = 0;
  int selectedCategoryIndex = 0;
  final appStateModel = AppStateModel();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        if (model.blocks.categories.isNotEmpty) {
          mainCategories = model.blocks.categories.where((cat) => cat.parent == 0).toList();
          if (mainCategories.isNotEmpty) {
            selectedCategory = mainCategories[selectedCategoryIndex];
            subCategories = model.blocks.categories.where((cat) => cat.parent == selectedCategory.id).toList();
          }
          return buildList(model.blocks);
        }
        return Scaffold(
          appBar: AppBar(title: Text(appStateModel.blocks.localeText.categories)),
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget buildList(BlocksModel snapshot) {
    return Scaffold(
      appBar: AppBar(title: Text(appStateModel.blocks.localeText.categories)),
      body: Row(
        children: <Widget>[
          buildCategoryList(),
          buildExpandedView(),
        ],
      ),
    );
  }

  Widget buildCategoryList() {
    final backgroundColor = Theme.of(context).focusColor.withOpacity(0.02);

    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        itemCount: mainCategories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = mainCategories[index];
          final isSelected = selectedCategory.id == category.id;

          return InkWell(
            onTap: () {
              setState(() {
                mainCategoryId = category.id;
                selectedCategoryIndex = index;
              });
            },
            child: Container(
              decoration: isSelected
                  ? BoxDecoration(
                color: isSelected ? backgroundColor : null,
                border: Border(left: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 4.0)),
              )
                  : null,
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: category.image,
                    placeholder: (context, url) => Container(color: Colors.transparent),
                    errorWidget: (context, url, error) => Container(color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    parseHtmlString(category.name),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildExpandedView() {
    final backgroundColor = Theme.of(context).focusColor.withOpacity(0.02);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: backgroundColor, width: 8.0)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => onCategoryClick(selectedCategory, context),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.3,
                child: CachedNetworkImage(
                  imageUrl: selectedCategory.banner ?? selectedCategory.image,
                  imageBuilder: (context, imageProvider) => Ink.image(
                    child: InkWell(
                      onTap: () => onCategoryClick(selectedCategory, context),
                    ),
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  placeholder: (context, url) => Container(color: Colors.transparent),
                  errorWidget: (context, url, error) => Container(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                color: Theme.of(context).cardColor,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width ~/ 120,
                    childAspectRatio: 7 / 9,
                  ),
                  itemCount: subCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildCategoryItem(subCategories[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryItem(Category category) {
    return InkWell(
      onTap: () => onCategoryClick(selectedCategory, context),
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 60,
                  height: 60,
                  child: CachedNetworkImage(
                    imageUrl: category.image,
                    imageBuilder: (context, imageProvider) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Ink.image(
                        child: InkWell(
                          onTap: () => onCategoryClick(selectedCategory, context),
                        ),
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    placeholder: (context, url) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    errorWidget: (context, url, error) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 5.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  parseHtmlString(category.name),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
