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


class Categories14 extends StatefulWidget {
  const Categories14({super.key});

  @override
  State<Categories14> createState() => _Categories14State();
}

class _Categories14State extends State<Categories14> {
  final List<Color?> backgroundColors = [
    Colors.pink[50],
    Colors.green[50],
    Colors.yellow[50],
    Colors.blue[50],
    Colors.cyan[50],
    Colors.purple[50],
    Colors.orange[50],
  ];

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
                final category = mainCategories[index];
                final colorIndex = index % backgroundColors.length; // Repeat colors
                return GestureDetector(
                  onTap: () {
                    //
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundColors[colorIndex],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (Theme.of(context).brightness == Brightness.dark)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.1), // Light shadow for contrast in dark theme
                              spreadRadius: -1,
                              blurRadius: 10,
                              offset: Offset(-1, -1), // Soft top-left lift effect for dark theme
                            )
                          else
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1), // Light shadow
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // Changes position of shadow
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  parseHtmlString(category.name),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  parseHtmlString(category.description),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2, // Limit to 2 lines
                                  overflow: TextOverflow.ellipsis, // Show ellipsis if text overflows
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16), // Space between text and image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: category.image,
                              height: 60, // Fixed height for the image
                              width: 60,  // Fixed width for the image
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.black12),
                              errorWidget: (context, url, error) => Container(color: Colors.white),
                              // Use the progress indicator while the image is loading
                              progressIndicatorBuilder: (context, url, downloadProgress) {
                                return Container(
                                  height: 60,
                                  width: 60,
                                );
                              }, // Optional: handle loading errors
                            ),
                          ),
                        ],
                      ),
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

