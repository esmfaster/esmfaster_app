import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import './../../../models/app_state_model.dart';
import '../../../resources/api_provider.dart';

class WriteReviewsPage extends StatefulWidget {
  final int productId;

  WriteReviewsPage({Key? key, required this.productId}) : super(key: key);

  @override
  _WriteReviewsPageState createState() => _WriteReviewsPageState();
}

class _WriteReviewsPageState extends State<WriteReviewsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiProvider = ApiProvider();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _reviewController = TextEditingController();
  final _appStateModel = AppStateModel();
  bool _showRatingError = false;
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(_appStateModel.blocks.localeText.reviews),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: 20),
                  Text(
                    _appStateModel.blocks.localeText.whatIsYourRate + '?',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                  ),
                  SizedBox(height: 5),
                  SmoothStarRating(
                    rating: _rating,
                    size: 30,
                    filledIconData: Icons.star,
                    halfFilledIconData: Icons.star_half,
                    defaultIconData: Icons.star_border,
                    starCount: 5,
                    allowHalfRating: true,
                    color: Colors.orange,
                    borderColor: Colors.orange,
                    spacing: 2.0,
                    onRatingChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                  if (_rating == 0.0 && _showRatingError)
                    Text(
                      _appStateModel.blocks.localeText.whatIsYourRate,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    )
                  else
                    Container(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      maxLength: 1000,
                      maxLines: 8,
                      controller: _reviewController,
                      decoration: InputDecoration(
                        labelText: _appStateModel.blocks.localeText.yourReview,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _appStateModel.blocks.localeText.pleaseEnterMessage;
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_appStateModel.blocks.user.id == 0) ...[
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: _appStateModel.blocks.localeText.name,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _appStateModel.blocks.localeText.pleaseEnter + ' ${_appStateModel.blocks.localeText.name.toLowerCase()}';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: _appStateModel.blocks.localeText.email,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _appStateModel.blocks.localeText.pleaseEnter + ' ${_appStateModel.blocks.localeText.email.toLowerCase()}';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        child: Text(_appStateModel.blocks.localeText.submit),
                        onPressed: () async {
                          setState(() {
                            _showRatingError = true;
                          });
                          if (_formKey.currentState!.validate() &&
                              _rating != 0.0) {
                            _formKey.currentState!.save();
                            Map<String, dynamic> reviewData = {
                              "author": _nameController.text,
                              "email": _emailController.text,
                              "comment": _reviewController.text,
                              'rating': _rating.toString(),
                              '_wp_unfiltered_html_comment':
                              _appStateModel.blocks.nonce.unfilteredHtmlComment.toString(),
                              'comment_post_ID': widget.productId.toString(),
                            };
                            _apiProvider.postWihoutUserLocation(
                                '/wp-comments-post.php', reviewData);
                            _nameController.clear();
                            _emailController.clear();
                            _reviewController.clear();
                            setState(() {
                              _showRatingError = false;
                            });
                            _thankYouMessage();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _thankYouMessage() {
    showDialog(
      builder: (context) => AlertDialog(
        content: Text(_appStateModel.blocks.localeText.thankYouForYourReview),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(_appStateModel.blocks.localeText.ok),
          ),
        ],
      ),
      context: context,
    );
  }
}
