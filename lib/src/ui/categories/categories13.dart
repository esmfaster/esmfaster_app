import 'dart:ui';
import 'dart:math' as math;
import 'package:app/src/ui/categories/list_tile.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '../../functions.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../models/category_model.dart';
import 'search_field.dart';

class Categories13 extends StatefulWidget {
  @override
  _Categories13State createState() => _Categories13State();
}

class _Categories13State extends State<Categories13> {
  late List<Category> mainCategories;
  late Category selectedCategory;
  int selectedCategoryIndex = 0;
  AppStateModel appStateModel = AppStateModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            mainCategories = model.blocks.categories.where((cat) => cat.parent == 0).toList();
            return buildCategoryList();
          }
          return Center(child: Container());
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(appStateModel.blocks.localeText.categories),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchCategory()),
            );
          },
          icon: Icon(FlutterRemix.search_2_line),
        )
      ],
    );
  }

  Widget buildCategoryList() {
    return ListView.builder(
      itemCount: mainCategories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return CategoryRow(
          category: mainCategories[index],
          onTap: () {
            onCategoryTap(mainCategories[index], context);
          },
        );
      },
    );
  }

  void onCategoryTap(Category category, BuildContext context) {
    List<Category> categories = appStateModel.blocks.categories.where((cat) => cat.parent == category.id).toList();
    if (categories.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubCategoriesPage(categories: categories, category: category),
        ),
      );
    } else {
      onCategoryClick(category, context);
    }
  }
}

class CategoryRow extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  CategoryRow({required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(16.0),
          trailing: Icon(CupertinoIcons.forward, size: 18),
          isThreeLine: category.description.isNotEmpty,
          onTap: onTap,
          leading: buildCategoryImage(context),
          title: buildCategoryTitle(context),
          subtitle: buildCategoryDescription(context),
        ),
        Divider(height: 0)
      ],
    );
  }

  Widget buildCategoryImage(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      child: CachedNetworkImage(
        imageUrl: category.image,
        imageBuilder: (context, imageProvider) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Ink.image(
            child: InkWell(
              onTap: onTap,
            ),
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
        placeholder: (context, url) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        errorWidget: (context, url, error) => Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget buildCategoryTitle(BuildContext context) {
    return Text(
      parseHtmlString(category.name),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? buildCategoryDescription(BuildContext context) {
    if (category.description.isNotEmpty) {
      return Text(
        category.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontSize: 12,
        ),
      );
    }
    return null;
  }
}

class SubCategoriesPage extends StatelessWidget {
  final List<Category> categories;
  final Category category;

  const SubCategoriesPage({Key? key, required this.categories, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(parseHtmlString(category.name))),
      body: buildCategoryList(context),
    );
  }

  Widget buildCategoryList(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return CategoryRow(
          category: categories[index],
          onTap: () {
            onCategoryClick(categories[index], context);
          },
        );
      },
    );
  }
}

class SearchCategory extends StatefulWidget {
  const SearchCategory({Key? key}) : super(key: key);

  @override
  State<SearchCategory> createState() => _SearchCategoryState();
}

class _SearchCategoryState extends State<SearchCategory> {

  List<Category> categories = AppStateModel().blocks.categories;
  TextEditingController searchTextController = TextEditingController();
  AppStateModel appStateModel = AppStateModel();
  List<Category> searchCategory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: buildSearchField(context),
      ),
      body: searchTextController.text.isEmpty ? ListView.builder(
          itemCount: appStateModel.blocks.categories.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return CategoryRow(
                category: appStateModel.blocks.categories[index]);
          }) : ListView.builder(
          itemCount: searchCategory.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return CategoryRow(
                category: searchCategory[index]);
          }),
    );
  }

  Widget buildSearchField(BuildContext context) {
    return SearchBarField(onChanged: (value) {
      setState(() {
        searchCategory = categories.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
      });
    }, searchTextController: searchTextController, hintText: AppStateModel().blocks.localeText.category, onEditingComplete: () {

    },);
  }
}


