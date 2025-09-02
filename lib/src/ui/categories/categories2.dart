import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../src/models/app_state_model.dart';
import '../../models/category_model.dart';
import '../../functions.dart';

class Categories2 extends StatefulWidget {
  @override
  _Categories2State createState() => _Categories2State();
}

class _Categories2State extends State<Categories2> {
  late List<Category> mainCategories;
  late Category selectedCategory;
  late List<Category> subCategories;
  late List<Category> filteredCategories;
  int selectedCategoryIndex = 0;
  final AppStateModel appStateModel = AppStateModel();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStateModel.blocks.localeText.categories),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CupertinoTextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  _filterCategories();
                });
              },
              placeholder: appStateModel.blocks.localeText.search + '...',
              placeholderStyle: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black45,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              prefix: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  CupertinoIcons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black45,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.white,
                borderRadius: BorderRadius.circular(30.0),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ),
      ),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            mainCategories = model.blocks.categories
                .where((cat) => cat.parent == 0)
                .toList();
            if (mainCategories.isNotEmpty) {
              selectedCategory = mainCategories[selectedCategoryIndex];
              subCategories = model.blocks.categories
                  .where((cat) => cat.parent == selectedCategory.id)
                  .toList();
              _filterCategories();
            }

            return buildList();
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _filterCategories() {
    if (searchQuery.isNotEmpty) {
      filteredCategories = mainCategories
          .where((category) =>
          category.name.toLowerCase().contains(searchQuery))
          .toList();
    } else {
      filteredCategories = mainCategories;
    }
  }

  Widget buildList() {
    return ListView.builder(
      itemCount: filteredCategories.length,
      padding: EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index) {
        return CategoryRow(
          category: filteredCategories[index],
          onCategoryClick: onCategoryTap,
        );
      },
    );
  }

  void onCategoryTap(Category category, BuildContext context) {
    onCategoryClick(category, context);
  }
}

class CategoryRow extends StatelessWidget {
  final Category category;
  final void Function(Category category, BuildContext context) onCategoryClick;

  const CategoryRow({
    required this.category,
    required this.onCategoryClick,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: StadiumBorder(),
      elevation: 0.5,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () {
          onCategoryClick(category, context);
        },
        child: Container(
          height: 122,
          margin: EdgeInsets.only(left: 1, right: 35),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 122,
                  height: 122,
                  child: CachedNetworkImage(
                    imageUrl: category.image,
                    imageBuilder: (context, imageProvider) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      margin: EdgeInsets.all(10.0),
                      shape: StadiumBorder(),
                      child: Ink.image(
                        child: InkWell(
                          onTap: () {
                            onCategoryClick(category, context);
                          },
                        ),
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    placeholder: (context, url) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      shape: StadiumBorder(),
                    ),
                    errorWidget: (context, url, error) => Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      margin: EdgeInsets.all(10.0),
                      shape: StadiumBorder(),
                      child: Container(color: Colors.black12),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 13, top: 0, right: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          parseHtmlString(category.name),
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              category.description,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.07,
                                color: Theme.of(context).hintColor,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${category.count} Items',
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 15,
                              letterSpacing: -0.24,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
