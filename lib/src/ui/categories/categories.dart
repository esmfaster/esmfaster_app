import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/categories/categories14.dart';
import 'package:app/src/ui/categories/categories15.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'categories1.dart';
import 'categories10.dart';
import 'categories11.dart';
import 'categories12.dart';
import 'categories13.dart';
import 'categories2.dart';
import 'categories3.dart';
import 'categories4.dart';
import 'categories5.dart';
import 'categories6.dart';
import 'categories7.dart';
import 'categories8.dart';
import 'categories9.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final Map<String, Widget Function()> _layoutMap = {
    'layout1': () => Categories1(),
    'layout2': () => Categories2(),
    'layout3': () => Categories3(),
    'layout4': () => Categories4(),
    'layout5': () => Categories5(),
    'layout6': () => Categories6(),
    'layout7': () => Categories7(),
    'layout8': () => Categories8(),
    'layout9': () => Categories9(),
    'layout10': () => Categories10(),
    'layout11': () => Categories11(),
    'layout12': () => Categories12(),
    'layout13': () => Categories13(),
    'layout14': () => Categories14(),
    'layout15': () => Categories15(),
  };

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        final layout = model.blocks.settings.pageLayout.category;
        //return Categories15();
        return _layoutMap[layout]?.call() ?? Categories7();
      },
    );
  }
}
