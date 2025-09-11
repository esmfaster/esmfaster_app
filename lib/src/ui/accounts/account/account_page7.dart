import 'package:app/src/models/blocks_model.dart';
import 'package:app/src/models/menu_group_model.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:app/src/ui/checkout/cart/shopping_cart.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/app_state_model.dart';
import '../login/login.dart';
import 'account_floating_button.dart';


class AccountPage7 extends StatefulWidget {
  @override
  _AccountPage7State createState() => _AccountPage7State();
}

class _AccountPage7State extends State<AccountPage7> {
  final appStateModel = AppStateModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButton: AccountFloatingButton(),
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Account content
          Container(
            //padding: EdgeInsets.only(top: 120),
            child: ScopedModelDescendant<AppStateModel>(
              builder: (context, child, model) {
                return CustomScrollView(
                  slivers: _buildList(model),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildList(AppStateModel model) {
    List<Widget> list = [];

    list.add(SliverToBoxAdapter(child: SizedBox(height: 180)));

    model.blocks.settings.accountGroup.forEach((accountGroup) {
      list.addAll(_buildAccountGroup(accountGroup, model));
    });

    if (model.blocks.settings.accountSocialLink) {
      list.add(_buildSocialLinkSection(model));
    } else {
      list.add(SliverToBoxAdapter(child: SizedBox(height: 16)));
    }

    if (model.blocks.settings.socialLink.bottomText.isNotEmpty) {
      list.add(_buildBottomTextSection(model));
    }

    list.add(SliverToBoxAdapter(child: SizedBox(height: 16)));

    return list;
  }

  Widget _buildSliverAppBar(AppStateModel model) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: model.blocks.settings.accountBackgroundImage.isNotEmpty ? 150.0 : 0,
      stretch: true,
      elevation: 0,
      title: model.blocks.settings.accountBackgroundImage.isEmpty ? Text(model.blocks.localeText.account) : null,
      flexibleSpace: model.blocks.settings.accountBackgroundImage.isNotEmpty
          ? FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: CachedNetworkImage(
          imageUrl: model.blocks.settings.accountBackgroundImage,
          placeholder: (context, url) => Container(color: Colors.grey.withOpacity(0.2)),
          errorWidget: (context, url, error) => Container(color: Colors.grey.withOpacity(0.2)),
          fit: BoxFit.cover,
        ),
      )
          : null,
    );
  }

  // Build the background based on accountBackgroundImage
  Widget _buildBackground() {
    final model = ScopedModel.of<AppStateModel>(context, rebuildOnChange: true);
    final backgroundImage = model.blocks.settings.accountBackgroundImage;
    return backgroundImage.isNotEmpty
        ? Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
    )
        : Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 80,
          child: _buildCircleContainer(context, 60),
        ),
        Positioned(
          top: 0,
          left: -5,
          child: _buildCircleContainer(context, 35),
        ),
        Positioned(
          bottom: 62,
          right: -40,
          child: _buildCircleContainer(context, 100),
        ),
        Positioned(
          bottom: -40,
          right: 60,
          child: _buildCircleContainer(context, 80),
        ),
      ],
    );
  }

  Widget _buildCircleContainer(BuildContext context, double size) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.2),
      ),
      height: size,
      width: size,
    );
  }

  List<Widget> _buildAccountGroup(MenuGroup accountGroup, AppStateModel model) {
    List<Widget> groupWidgets = [];

    if (accountGroup.showTitle) {
      groupWidgets.add(
        SliverToBoxAdapter(
          child: ListTile(
            subtitle: Text(
              accountGroup.title.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                //color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    } else {
      groupWidgets.add(SliverToBoxAdapter(child: SizedBox(height: 16)));
    }

    groupWidgets.add(
      SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Column(
            children: accountGroup.menuItems.map((item) {
              if (_shouldSkipMenuItem(item, model)) {
                return Container();
              } else {
                return ListTile(
                  onTap: () => onItemClick(item, context),
                  leading: item.leading.isNotEmpty ? DunesIcon(iconString: item.leading) : null,
                  trailing: item.trailing.isNotEmpty ? DunesIcon(iconString: item.trailing) : null,
                  title: Text(item.title, style: _titleStyle),
                  subtitle: item.description.isNotEmpty ? Text(item.description, style: _subtitleTextStyle, maxLines: 2) : null,
                );
              }
            }).toList(),
          ),
        ),
      ),
    );

    return groupWidgets;
  }

  bool _shouldSkipMenuItem(MenuItem menuItem, AppStateModel model) {
    return ['vendorProducts', 'vendorOrders', 'vendorWebView'].contains(menuItem.linkType) &&
        !model.isVendor.contains(model.user.role) ||
        menuItem.linkType == 'login' && model.user.id != 0 ||
        menuItem.linkType == 'logout' && model.user.id == 0;
  }

  Widget _buildSocialLinkSection(AppStateModel model) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 32, 8, 0),
        height: 60,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (model.blocks.settings.socialLink.facebook.isNotEmpty)
                _buildSocialIconButton(
                  icon: FontAwesomeIcons.facebookF,
                  color: Color(0xff4267B2),
                  onPressed: () => launchUrl(Uri.parse(model.blocks.settings.socialLink.facebook), mode: LaunchMode.externalApplication),
                ),
              if (model.blocks.settings.socialLink.twitter.isNotEmpty)
                _buildSocialIconButton(
                  icon: FontAwesomeIcons.twitter,
                  color: Color(0xff1DA1F2),
                  onPressed: () => launchUrl(Uri.parse(model.blocks.settings.socialLink.twitter), mode: LaunchMode.externalApplication),
                ),
              if (model.blocks.settings.socialLink.linkedIn.isNotEmpty)
                _buildSocialIconButton(
                  icon: FontAwesomeIcons.linkedinIn,
                  color: Color(0xff0e76a8),
                  onPressed: () => launchUrl(Uri.parse(model.blocks.settings.socialLink.linkedIn), mode: LaunchMode.externalApplication),
                ),
              if (model.blocks.settings.socialLink.instagram.isNotEmpty)
                _buildSocialIconButton(
                  icon: FontAwesomeIcons.instagram,
                  color: Color(0xfffb3958),
                  onPressed: () => launchUrl(Uri.parse(model.blocks.settings.socialLink.instagram), mode: LaunchMode.externalApplication),
                ),
              if (model.blocks.settings.socialLink.whatsapp.isNotEmpty)
                _buildSocialIconButton(
                  icon: FontAwesomeIcons.whatsapp,
                  color: Color(0xff128C7E),
                  onPressed: () => launchUrl(Uri.parse(model.blocks.settings.socialLink.whatsapp), mode: LaunchMode.externalApplication),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(icon),
      iconSize: 15,
      color: color,
      onPressed: onPressed,
    );
  }

  Widget _buildBottomTextSection(AppStateModel model) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: TextButton(
            child: Text(model.blocks.settings.socialLink.bottomText),
            onPressed: () async {
              if (model.blocks.settings.socialLink.bottomText.contains('@') && model.blocks.settings.socialLink.bottomText.contains('.')) {
                launchUrl(Uri.parse('mailto:' + model.blocks.settings.socialLink.bottomText));
              } else {
                await canLaunch(model.blocks.settings.socialLink.bottomText)
                    ? await launch(model.blocks.settings.socialLink.bottomText)
                    : throw 'Could not launch ${model.blocks.settings.socialLink.bottomText}';
              }
            },
          ),
        ),
      ),
    );
  }

  // Method to handle user login
  _userLogin() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    context.read<Favourites>().getWishList();
    context.read<ShoppingCart>().getCart();
  }

  // Constants for text styles
  final TextStyle _titleStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  final TextStyle _subtitleTextStyle = TextStyle(color: Color(0xff8a8a8d), letterSpacing: 0);
}


class CustomCard extends StatelessWidget {
  CustomCard({Key? key, required this.child}) : super(key: key);

  final Widget child;
  final double margin = 1;
  final double elevation = 0.0;
  final double borderRadius = 0;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.black;//Theme.of(context).accentColor;
    return Column(
      children: [
        Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          margin: EdgeInsets.fromLTRB(margin, margin/2, margin, margin/2),
          child: child,
        ),
        Divider(height: 0, thickness: 0)
      ],
    );
  }
}
