import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../src/blocs/product_detail_bloc.dart';
import '../../../../src/models/review_model.dart';

class ReviewList extends StatefulWidget {
  final ProductDetailBloc productDetailBloc;

  const ReviewList({Key? key, required this.productDetailBloc}) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ReviewModel>>(
      stream: widget.productDetailBloc.allReviews,
      builder: (context, AsyncSnapshot<List<ReviewModel>> snapshot) {
        if (snapshot.hasData) {
          return buildReviewsList(snapshot.data!, context);
        } else {
          return SliverToBoxAdapter();
        }
      },
    );
  }

  Widget buildReviewsList(List<ReviewModel> reviews, BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return buildListTile(context, reviews[index]);
        },
        childCount: reviews.length,
      ),
    );
  }

  Widget buildListTile(BuildContext context, ReviewModel review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20.0,
            backgroundImage: NetworkImage(review.avatar),
          ),
          title: Text(
            review.author,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeago.format(review.date),
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).hintColor,
                ),
              ),
              RatingBar.builder(
                initialRating: double.parse(review.rating),
                itemSize: 15,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                ignoreGestures: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22.0, 0.0, 16.0, 16.0),
          child: Html(data: review.content),
        ),
        Divider(height: 0.0),
      ],
    );
  }
}
