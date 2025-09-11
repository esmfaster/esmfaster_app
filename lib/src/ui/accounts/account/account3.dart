import 'package:app/src/ui/accounts/firebase_chat/chat.dart';
import 'package:app/src/ui/checkout/cart/shopping_cart.dart';
import 'package:app/src/config.dart';
import 'package:app/src/ui/accounts/reward_points.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:provider/src/provider.dart';
import '../../../ui/accounts/orders/download_list.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'apply_for_vendor.dart';
import '../../../ui/pages/webview.dart';
import '../../../models/app_state_model.dart';
import '../../../models/blocks_model.dart';
import '../../../ui/accounts/settings/settings.dart';
import '../../vendor/ui/orders/order_list.dart';
import '../../vendor/ui/products/vendor_products/product_list.dart';
import '../address/customer_address.dart';
import '../currency.dart';
import '../language/language.dart';
import '../login/login.dart';
import '../orders/order_list.dart';
import '../../pages/post_detail.dart';
import '../wallet.dart';
import '../wishlist.dart';
import 'account_floating_button.dart';

class UserAccount3 extends StatefulWidget {
  @override
  _UserAccount3State createState() => _UserAccount3State();
}

class _UserAccount3State extends State<UserAccount3> {
  final appStateModel = AppStateModel();
  @override
  Widget build(BuildContext context) {
    TextStyle? menuTextStyle = Theme.of(context).textTheme.bodySmall;
    Color? onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    Color headerBackgroundColor = Theme.of(context).colorScheme.secondaryContainer;
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButton: AccountFloatingButton(),
      body: ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
            return CustomScrollView(
              slivers: <Widget>[
                buildSliverAppBar(onPrimaryColor, context, headerBackgroundColor),
                SliverPadding(padding: EdgeInsets.all(0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                        _buildList(model)
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  _buildList(AppStateModel model) {
    List<Widget> list = [];
    bool isLoggedIn = model.user.id > 0;

    // Helper function to create ListTile widgets
    ListTile buildListTile({
      required IconData leadingIcon,
      required String title,
      required VoidCallback onTap,
    }) {
      return ListTile(
        onTap: onTap,
        leading: Icon(leadingIcon),
        title: Text(title, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 18)),
        trailing: Icon(CupertinoIcons.forward, color: Colors.grey),
      );
    }

    // Helper function to handle login
    void handleLogin(VoidCallback action) {
      isLoggedIn ? action() : _userLogin();
    }

    list.add(SizedBox(height: 4));

    if (!isLoggedIn) {
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: FluentIcons.person_16_regular,
            title: model.blocks.localeText.signIn,
            onTap: () => _userLogin(),
          ),
        ),
      );
    }

    // Add other menu items using the buildListTile function and conditional rendering

      if (model.blocks.settings.wallet) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: Icons.account_balance_wallet,
              title: model.blocks.localeText.wallet,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Wallet())),
            ),
          ),
        );
      }

      // Wishlist
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: CupertinoIcons.heart,
            title: model.blocks.localeText.wishlist,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WishList())),
          ),
        ),
      );

      // Reward Points
      if (model.blocks.settings.rewardPoints) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: FluentIcons.reward_20_regular,
              title: model.blocks.localeText.rewardPoints,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RewardPoints())),
            ),
          ),
        );
      }

      // Orders
      if (!model.blocks.settings.catalogueMode) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: FluentIcons.shopping_bag_24_regular,
              title: model.blocks.localeText.orders,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderList())),
            ),
          ),
        );
      }

      // Download Products
      if (model.blocks.settings.downloadProducts) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: Icons.cloud_download_rounded,
              title: model.blocks.localeText.downloads,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DownloadsPage())),
            ),
          ),
        );
      }

      // Chat
      if ((model.blocks.settings.chatType == 'firebaseChat' || model.blocks.settings.chatType == 'circular') && model.blocks.siteSettings.adminUIDs.length > 0) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: FluentIcons.chat_16_regular,
              title: model.blocks.localeText.chat,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FireBaseChat(otherUserId: model.blocks.siteSettings.adminUIDs.first))),
            ),
          ),
        );
      }

      // Address
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: FluentIcons.location_16_regular,
            title: model.blocks.localeText.address,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerAddress())),
          ),
        ),
      );

      // Settings
      if (appStateModel.blocks.settings.darkThemeSwitch) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: CupertinoIcons.settings,
              title: model.blocks.localeText.settings,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage())),
            ),
          ),
        );
      }

      // Language
      if (model.blocks.languages.isNotEmpty) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: Icons.language,
              title: model.blocks.localeText.language,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage())),
            ),
          ),
        );
      }

      // Currency
      if (model.blocks.currencies.isNotEmpty) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: Icons.attach_money,
              title: model.blocks.localeText.currency,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CurrencyPage())),
            ),
          ),
        );
      }

      // Share App
      if (appStateModel.blocks.settings.dynamicLink.isNotEmpty) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: FluentIcons.share_16_regular,
              title: model.blocks.localeText.shareApp,
              onTap: () => _shareApp(),
            ),
          ),
        );
      }

      // Logout
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: CupertinoIcons.power,
            title: model.blocks.localeText.logout,
            onTap: () async {
              await model.logout();
              context.read<Favourites>().clear();
              context.read<ShoppingCart>().getCart();
            },
          ),
        ),
      );


    // Additional pages
    if (model.blocks.pages.isNotEmpty && model.blocks.pages[0].url.isNotEmpty) {
      list.add(SizedBox(height: 24));
      model.blocks.pages.forEach((element) {
        list.add(
          CustomCard(
            child: buildListTile(
              leadingIcon: Icons.info,
              title: element.title,
              onTap: () => _onPressItem(element, context),
            ),
          ),
        );
      });
    }

    // Vendor specific menu items
    if (isLoggedIn && ((model.isVendor.contains(model.user.role) && model.blocks.settings.multiVendor) || model.user.role.contains('administrator'))) {
      list.add(SizedBox(height: 24));
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: FlutterRemix.grid_fill,
            title: model.blocks.localeText.products,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VendorProductList(vendorId: model.user.id.toString()))),
          ),
        ),
      );
      list.add(
        CustomCard(
          child: buildListTile(
            leadingIcon: FluentIcons.shopping_bag_24_regular,
            title: model.blocks.localeText.orders,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VendorOrderList(vendorId: model.user.id.toString()))),
          ),
        ),
      );
    }

    return list;
  }

  _buildVendorList() {
    List<Widget> list = [];

    return list;
  }

  _userLogin() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    context.read<Favourites>().getWishList();
    context.read<ShoppingCart>().getCart();
  }

  Future openLink(String url) async {
    launchUrl(Uri.parse(url));
    //canLaunch not working for some android device
    /*if (await canLaunch(url)) {
      await launchUri(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }*/
  }

  _shareApp() async {
    String id = appStateModel.user.id > 0
        ? appStateModel.user.id.toString()
        : '0';
    final url = Config().url + '?wwref=' + id;
    if (appStateModel.blocks.settings.dynamicLink.isNotEmpty) {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: appStateModel.blocks.settings.dynamicLink,
        link: Uri.parse(url),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Check this app',
        ),
        androidParameters: AndroidParameters(
          packageName: Config().androidPackageName,
          minimumVersion: 0,
        ),
        iosParameters: IOSParameters(
          bundleId: Config().iosPackageName,
        ),
      );

      final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      Share.share(dynamicLink.shortUrl.toString());
    }
  }

  _onPressItem(OldChild page, BuildContext context) {
    if (page.description == 'page') {
      var child = MenuItem(linkId: page.url.toString(), linkType: 'page');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WPPostPage(child: child)));
    } else if (page.description == 'post') {
      var child = MenuItem(linkId: page.url.toString(), linkType: 'post');
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WPPostPage(child: child)));
    } else if (page.description == 'link') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(url: page.url, title: page.title)));
    }
  }

  SliverAppBar buildSliverAppBar(Color? onPrimaryColor, BuildContext context, Color headerBackgroundColor) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      snap: false,
      expandedHeight: 150.0,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 0, bottom: 16),
        title: buildUserTitleWidget(context, onPrimaryColor),
        background: buildAccountBackgroundWidget(context),
      ),
      backgroundColor: headerBackgroundColor,
    );
  }

  Widget buildUserTitleWidget(BuildContext context, Color? onPrimaryColor) {
    return Row(
      children: [
        SizedBox(width: 10),
        CircleAvatar(
          radius: 18.0,
          backgroundColor: onPrimaryColor != null ? onPrimaryColor.withOpacity(0.6) : null,
          child: Icon(
            Icons.person,
            color: Theme.of(context).primaryColor,
            size: 18,
          ),
        ),
        SizedBox(width: 10),
        ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
            return Container(
              child: model.user.id > 0
                  ? (model.user.billing.firstName.isNotEmpty || model.user.billing.lastName.isNotEmpty)
                  ? Text(
                '${model.user.billing.firstName} ${model.user.billing.lastName}',
                style: TextStyle(color: onPrimaryColor),
              )
                  : Container(
                child: Text(
                  model.blocks.localeText.welcome,
                  style: TextStyle(color: onPrimaryColor),
                ),
              )
                  : Container(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Login())),
                  child: Text(
                    model.blocks.localeText.signIn,
                    style: TextStyle(color: onPrimaryColor),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildAccountBackgroundWidget(BuildContext context) {
    return Stack(
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
        Container(
          /*elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),*/
          margin: EdgeInsets.fromLTRB(margin, margin/2, margin, margin/2),
          child: child,
        ),
        Divider(height: 0, thickness: 0)
      ],
    );
  }
}
