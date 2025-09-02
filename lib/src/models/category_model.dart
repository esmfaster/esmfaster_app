// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

class Category {
  int id;
  String name;
  String slug;
  String description;
  int parent;
  int count;
  String image;
  String? banner;

  Category({
    required this.id,
    required this.name,
    this.slug = '',
    this.description = '',
    this.parent = 0,
    this.count = 0,
    this.image = '',
    this.banner,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"] ?? 0,
    name: json["name"] ?? '',
    slug: json["slug"] ?? '',
    description: json["description"] ?? '',
    parent: json["parent"] ?? 0,
    count: json["count"] ?? 0,
    image: json["image"] == null || json["image"] == false ? '' : json["image"],
    banner: json["banner"] == null || json["banner"] == '' ? null : json["banner"],
  );
}