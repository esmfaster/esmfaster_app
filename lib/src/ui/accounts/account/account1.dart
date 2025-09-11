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
import '../orders/download_list.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../refer_and_earn.dart';
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

class UserAccount1 extends StatefulWidget {
  @override
  _UserAccount1State createState() => _UserAccount1State();
}

class _UserAccount1State extends State<UserAccount1> {
  final appStateModel = AppStateModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appStateModel.blocks.localeText.account),
      ),
      body: ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          return ListView(
            children: _buildList(model),
          );
        },
      ),
      floatingActionButton: AccountFloatingButton(),
    );
  }

  List<Widget> _buildList(AppStateModel model) {
    List<Widget> list = [];
    bool isLoggedIn = model.user.id != null && model.user.id > 0;
    TextStyle titleStyle = Theme.of(context).textTheme.bodySmall!;

    list.add(SizedBox(height: 12.0));

    if (!isLoggedIn) {
      list.add(_buildListTile(
        title: model.blocks.localeText.signIn,
        icon: CupertinoIcons.person,
        onTap: _userLogin,
      ));
    }

    if (model.blocks.settings.wallet) {
      list.add(_buildListTile(
        title: model.blocks.localeText.wallet,
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => _navigateToPage(context, Wallet()),
      ));
    }

    if (model.blocks.settings.referAndEarn) {
      list.add(_buildListTile(
        title: model.blocks.localeText.referAndEarn,
        icon: CupertinoIcons.money_pound_circle,
        onTap: () => _navigateToPage(context, ReferAndEarn()),
      ));
    }

    list.add(_buildListTile(
      title: model.blocks.localeText.wishlist,
      icon: CupertinoIcons.heart,
      onTap: () => _navigateToPage(context, WishList()),
    ));

    if (model.blocks.settings.rewardPoints) {
      list.add(_buildListTile(
        title: model.blocks.localeText.rewardPoints,
        icon: CupertinoIcons.money_dollar_circle,
        onTap: () => _navigateToPage(context, RewardPoints()),
      ));
    }

    list.add(_buildListTile(
      title: model.blocks.localeText.orders,
      icon: FluentIcons.shopping_bag_24_regular,
      onTap: () => _navigateToPage(context, OrderList()),
    ));

    if (model.blocks.settings.downloadProducts) {
      list.add(_buildListTile(
        title: model.blocks.localeText.downloads,
        icon: CupertinoIcons.cloud_download,
        onTap: () => _navigateToPage(context, DownloadsPage()),
      ));
    }

    if (model.blocks.settings.chatType == 'firebaseChat' || model.blocks.settings.chatType == 'circular') {
      if (model.blocks.siteSettings.adminUIDs.isNotEmpty) {
        list.add(_buildListTile(
          title: model.blocks.localeText.chat,
          icon: CupertinoIcons.chat_bubble,
          onTap: () => _navigateToPage(context, FireBaseChat(otherUserId: model.blocks.siteSettings.adminUIDs.first)),
        ));
      }
    }

    list.add(_buildListTile(
      title: model.blocks.localeText.address,
      icon: CupertinoIcons.location,
      onTap: () => _navigateToPage(context, CustomerAddress()),
    ));

    if (appStateModel.blocks.settings.darkThemeSwitch) {
      list.add(_buildListTile(
        title: model.blocks.localeText.settings,
        icon: CupertinoIcons.settings,
        onTap: () => _navigateToPage(context, SettingsPage()),
      ));
    }

    if (model.blocks.languages.isNotEmpty) {
      list.add(_buildListTile(
        title: model.blocks.localeText.language,
        icon: CupertinoIcons.globe,
        onTap: () => _navigateToPage(context, LanguagePage()),
      ));
    }

    if (model.blocks.currencies.isNotEmpty) {
      list.add(_buildListTile(
        title: model.blocks.localeText.currency,
        icon: CupertinoIcons.money_dollar_circle,
        onTap: () => _navigateToPage(context, CurrencyPage()),
      ));
    }

    if (appStateModel.blocks.settings.dynamicLink.isNotEmpty) {
      list.add(_buildListTile(
        title: model.blocks.localeText.shareApp,
        icon: FluentIcons.share_16_regular,
        onTap: _shareApp,
      ));
    }

    if (isLoggedIn) {
      list.add(_buildListTile(
        title: model.blocks.localeText.logout,
        icon: CupertinoIcons.power,
        onTap: _logout,
      ));
    }

    if (model.blocks.pages.isNotEmpty && model.blocks.pages[0].url.isNotEmpty) {
      list.add(SizedBox(height: 24));
      model.blocks.pages.forEach((element) {
        list.add(_buildListTile(
          title: element.title,
          icon: Icons.info,
          onTap: () => _onPressItem(element, context),
        ));
      });
    }

    if (isLoggedIn &&
        ((model.isVendor.contains(model.user.role) &&
            model.blocks.settings.multiVendor) ||
            model.user.role.contains('administrator'))) {
      list.add(SizedBox(height: 24));
      list.add(_buildListTile(
        title: model.blocks.localeText.products,
        icon: CupertinoIcons.rectangle_grid_2x2,
        onTap: () => _navigateToPage(context, VendorProductList(vendorId: model.user.id.toString())),
      ));
      list.add(_buildListTile(
        title: model.blocks.localeText.orders,
        icon: Icons.shopping_basket_outlined,
        onTap: () => _navigateToPage(context, VendorOrderList(vendorId: model.user.id.toString())),
      ));
    }

    return list;
  }

  Column _buildListTile({required String title, required IconData icon, required Function onTap}) {
    return Column(
      children: [
        ListTile(
          onTap: () => onTap(),
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        ),
        Divider(height: 0, thickness: 0)
      ],
    );
  }

  _userLogin() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    context.read<Favourites>().getWishList();
    context.read<ShoppingCart>().getCart();
  }

  _navigateToPage(BuildContext context, Widget page) {
    final isLoggedIn = appStateModel.user.id != null && appStateModel.user.id! > 0;
    if (isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      _userLogin();
    }
  }

  _shareApp() async {
    final id = appStateModel.user.id > 0 ? appStateModel.user.id.toString() : '0';
    final url = Config().url + '?wwref=' + id;
    if (appStateModel.blocks.settings.dynamicLink.isNotEmpty) {
      final parameters = DynamicLinkParameters(
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

  _logout() async {
    await appStateModel.logout();
    context.read<Favourites>().clear();
    context.read<ShoppingCart>().getCart();
  }

  _onPressItem(OldChild page, BuildContext context) {
    if (page.description == 'page' || page.description == 'post') {
      final child = MenuItem(linkId: page.url.toString(), linkType: 'page');
      Navigator.push(context, MaterialPageRoute(builder: (context) => WPPostPage(child: child)));
    } else if (page.description == 'link') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage(url: page.url, title: page.title)));
    }
  }
}

class CustomCard extends StatelessWidget {
  CustomCard({Key? key, required this.child}) : super(key: key);

  final Widget child;
  final double margin = 0.1;
  final double elevation = 0.0;
  final double borderRadius = 0;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.black; //Theme.of(context).accentColor;
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: EdgeInsets.fromLTRB(margin, margin / 2, margin, margin / 2),
      child: Column(
        children: [
          child,
          Divider(height: 0, thickness: 0)
        ],
      ),
    );
  }
}
