import 'dart:ui';
import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/category_model.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:app/src/ui/categories/categories4.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

class Categories12 extends StatefulWidget {
  const Categories12({Key? key}) : super(key: key);

  @override
  _Categories12State createState() => _Categories12State();
}

class _Categories12State extends State<Categories12> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              buildBlockTitle(),
              buildCategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBlockTitle() {
    return BlockTitle(
      title: 'all categories',
      subtitle: 'curated with the best range of products',
      onTapViewAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Categories4()),
        );
      },
    );
  }

  Widget buildCategoryGrid() {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
          ),
          itemCount: model.blocks.categories.length,
          itemBuilder: (BuildContext context, int index) {
            return buildCategoryItem(model.blocks.categories[index]);
          },
        );
      },
    );
  }

  Widget buildCategoryItem(Category category) {
    return InkWell(
      onTap: () {
        onCategoryClick(category, context);
      },
      child: Column(
        children: [
          Container(
            height: 80,
            child: Card(
              elevation: 0.5,
              child: CachedNetworkImage(
                imageUrl: category.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black12),
                errorWidget: (context, url, error) => Container(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              parseHtmlString(category.name),
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}

class BlockTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Function? onTapViewAll;
  const BlockTitle({Key? key, required this.title, this.subtitle, this.onTapViewAll})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          onTapViewAll != null ? TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              onPressed: () => onTapViewAll!(), child: Text(AppStateModel().blocks.localeText.viewAll)) : Container(),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle!, maxLines: 1, style: Theme.of(context).textTheme.bodyMedium) : null,
    );
  }
}
