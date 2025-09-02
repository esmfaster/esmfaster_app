import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../../src/models/app_state_model.dart';
import '../../models/category_model.dart';
import '../../functions.dart';
import 'package:app/src/ui/accounts/account/account1.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';

class Categories3 extends StatefulWidget {
  @override
  _Categories3State createState() => _Categories3State();
}

class _Categories3State extends State<Categories3> {
  late List<Category> mainCategories;
  late List<Category> subCategories;
  late Category selectedCategory;
  int selectedCategoryIndex = 0;
  final AppStateModel appStateModel = AppStateModel();

  void onCategoryTap(Category category, BuildContext context) {
    onCategoryClick(category, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appStateModel.blocks.localeText.categories)),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          if (model.blocks.categories.isNotEmpty) {
            mainCategories =
                model.blocks.categories.where((cat) => cat.parent == 0).toList();
            if (mainCategories.isNotEmpty) {
              selectedCategory = mainCategories[selectedCategoryIndex];
              subCategories = model.blocks.categories
                  .where((cat) => cat.parent == selectedCategory.id)
                  .toList();
            }

            return buildList();
          }
          return Center(child: Container());
        },
      ),
    );
  }

  Widget buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: mainCategories.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return CategoryRow(
          category: mainCategories[index],
          onCategoryClick: onCategoryTap,
        );
      },
    );
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
      elevation: 0.005,
      child: ListTile(
        contentPadding: EdgeInsets.all(10.0),
        trailing: Icon(CupertinoIcons.forward, color: Colors.grey),
        isThreeLine: category.description.isNotEmpty,
        onTap: () {
          onCategoryClick(category, context);
        },
        leading: Container(
          width: 60,
          height: 60,
          child: CachedNetworkImage(
            imageUrl: category.image,
            imageBuilder: (context, imageProvider) => Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.black12,
            ),
          ),
        ),
        title: Text(
          parseHtmlString(category.name),
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontSize: 18,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: category.description.isNotEmpty
            ? Text(
          category.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontSize: 12,
          ),
        )
            : null,
      ),
    );
  }
}
