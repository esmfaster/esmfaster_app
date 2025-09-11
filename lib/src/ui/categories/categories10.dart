import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/category_model.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/category_model.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';

class Categories10 extends StatefulWidget {
  @override
  _Categories10State createState() => _Categories10State();
}

class _Categories10State extends State<Categories10> {
  final appStateModel = AppStateModel();
  late List<Category> mainCategories;
  late ScrollController scrollController;
  late List<bool> isCardOpen;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    mainCategories = appStateModel.blocks.categories.where((cat) => cat.parent == 0).toList();
    isCardOpen = List<bool>.generate(
      mainCategories.length,
          (index) => false,
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void toggleCard(int index) {
    setState(() {
      isCardOpen[index] = !isCardOpen[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    mainCategories =
        appStateModel.blocks.categories.where((cat) => cat.parent == 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text(appStateModel.blocks.localeText.categories)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth ~/ 810 + 1;
          return StaggeredGridView.countBuilder(
            key: ValueKey<int>(columns),
            controller: scrollController,
            crossAxisCount: columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.all(8),
            staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
            itemBuilder: (BuildContext context, int index) => CategoryCard(
              mainCategory: mainCategories[index],
              isCardOpen: isCardOpen[index],
              toggleCard: toggleCard,
              index: index,
              appStateModel: appStateModel,
            ),
            itemCount: mainCategories.length,
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category mainCategory;
  final bool isCardOpen;
  final Function(int) toggleCard;
  final int index;
  final AppStateModel appStateModel;

  const CategoryCard({
    Key? key,
    required this.mainCategory,
    required this.isCardOpen,
    required this.toggleCard,
    required this.index, required this.appStateModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subCategories = appStateModel.blocks.categories
        .where((cat) => cat.parent == mainCategory.id)
        .toList();

    return MainCategoryCard(
      title: Text(parseHtmlString(mainCategory.name)),
      isOpen: isCardOpen,
      onTap: () => toggleCard(index),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BuildCategoryGrid(categories: subCategories),
      ),
    );
  }
}

class BuildCategoryGrid extends StatelessWidget {
  final List<Category> categories;

  const BuildCategoryGrid({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.7,
      ),
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) =>
          SubCategoryCard(category: categories[index]),
    );
  }
}

class SubCategoryCard extends StatelessWidget {
  final Category category;

  const SubCategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onCategoryClick(category, context),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: CachedNetworkImage(
                imageUrl: category.image.isNotEmpty ? category.image : '',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  parseHtmlString(category.name),
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainCategoryCard extends StatelessWidget {
  final Widget? title;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget? child;

  const MainCategoryCard({
    Key? key,
    this.title,
    required this.isOpen,
    required this.onTap,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            title: title,
            trailing: ExpandIcon(
              size: 32,
              isExpanded: isOpen,
              padding: EdgeInsets.zero,
              onPressed: (_) => onTap(),
            ),
            onTap: onTap,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: isOpen ? child ?? SizedBox.shrink() : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
