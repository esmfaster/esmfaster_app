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

class Categories15 extends StatefulWidget {
  const Categories15({super.key});


  @override
  State<Categories15> createState() => _Categories15State();
}

class _Categories15State extends State<Categories15> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500), // Duration of animation
      vsync: this,
    );
    _animationController.forward(); // Start the animation after loading the data
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          final mainCategories = model.blocks.categories.where((cat) => cat.parent == 0).toList();
        return Scaffold(
          appBar: AppBar(title: Text(model.blocks.localeText.categories)),
          body: ListView.builder(
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final item = mainCategories[index];
              final animation = Tween<Offset>(
                begin: Offset(1.0, 0.0), // Start from off-screen to the right
                end: Offset(0.0, 0.0), // End at its final position
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval((index / mainCategories.length), 1.0, curve: Curves.easeOut),
              ));

              return SlideTransition(
                position: animation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Remove horizontal padding
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: item.image,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.black12),
                      errorWidget: (context, url, error) => Container(color: Colors.white),
                    ),
                    title: Text(
                      parseHtmlString(item.name),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: item.description.isNotEmpty
                        ? Text(
                      parseHtmlString(item.description),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),
                    )
                        : null,
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    onTap: () {
                      final subcategories = model.blocks.categories.where((cat) => cat.parent == item.id).toList();//categoriesProvider.getSubcategories(item.id);
                      // Navigate to SubcategoryPage if the category has subcategories
                      if (subcategories.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubcategoryPage(
                              mainCategory: item,
                              subcategories: subcategories,
                            ),
                          ),
                        );
                      } else {
                        //
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}

class SubcategoryPage extends StatefulWidget {
  final Category mainCategory;
  final List<Category> subcategories;

  SubcategoryPage({super.key, required this.mainCategory, required this.subcategories});

  @override
  State<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500), // Duration of animation
      vsync: this,
    );
    _animationController.forward(); // Start the animation after loading the data
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.mainCategory.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
          return ListView.builder(
            itemCount: widget.subcategories.length,
            itemBuilder: (context, index) {
              final subcategory = widget.subcategories[index];
              final animation = Tween<Offset>(
                begin: Offset(1.0, 0.0), // Start from off-screen to the right
                end: Offset(0.0, 0.0), // End at its final position
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval((index / widget.subcategories.length), 1.0, curve: Curves.easeOut),
              ));

              return SlideTransition(
                position: animation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    onTap: () {
                      final subcategories = model.blocks.categories.where((cat) => cat.parent == subcategory.id).toList();//context.read<CategoryProvider>().getSubcategories(subcategory.id);
                      // Navigate to SubcategoryPage if the category has subcategories
                      if (subcategories.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubcategoryPage(
                              mainCategory: subcategory,
                              subcategories: subcategories,
                            ),
                          ),
                        );
                      } else {
                        //
                      }
                    },
                    leading: CachedNetworkImage(
                      imageUrl: subcategory.image,
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.black12),
                      errorWidget: (context, url, error) => Container(color: Colors.white),
                    ),
                    title: Text(
                      parseHtmlString(subcategory.name),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: subcategory.description.isNotEmpty
                        ? Text(
                      parseHtmlString(subcategory.description),
                      maxLines: 2,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),
                    )
                        : null,
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}

