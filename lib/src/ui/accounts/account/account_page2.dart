import 'package:app/src/models/blocks_model.dart';
import 'package:app/src/models/menu_group_model.dart';
import 'package:flutter/material.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:app/src/functions.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/accounts/login/login.dart';
import 'package:app/src/ui/accounts/account/account_floating_button.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:flutter/services.dart';

class AccountPage2 extends StatefulWidget {
  @override
  _AccountPage2State createState() => _AccountPage2State();
}

class _AccountPage2State extends State<AccountPage2> {
  Color greyColor = Colors.grey[600]!;

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        return Scaffold(
          floatingActionButton: AccountFloatingButton(page: 'account'),
          body: CustomScrollView(slivers: _buildList(model)),
        );
      },
    );
  }

  List<Widget> _buildList(AppStateModel model) {
    List<Widget> list = [];

    list.add(_buildSliverAppBar(model));

    list.add(SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildUserDetails(model),
      ),
    ));

    model.blocks.settings.accountGroup.forEach((accountGroup) {
      list.add(_buildAccountGroupSliver(accountGroup, model));
    });

    if (model.blocks.settings.accountGroup.length == 3) {
      list.add(_buildSpecialAccountGroup(model));
    } else {
      list.add(_buildRegularAccountGroups(model));
    }

    return list;
  }

  Widget _buildSliverAppBar(AppStateModel model) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: model.blocks.settings.accountBackgroundImage.isNotEmpty ? 150.0 : 0,
      stretch: true,
      elevation: 0,
      title: model.blocks.settings.accountBackgroundImage.isEmpty ? null : null,
      flexibleSpace: model.blocks.settings.accountBackgroundImage.isNotEmpty
          ? FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: CachedNetworkImage(
          imageUrl: model.blocks.settings.accountBackgroundImage,
          placeholder: (context, url) => Container(color: Colors.grey.withOpacity(0.2),),
          errorWidget: (context, url, error) => Container(color: Colors.grey.withOpacity(0.2),),
          fit: BoxFit.cover,
        ),
      )
          : null,
    );
  }

  Widget _buildUserDetails(AppStateModel model) {
    return model.user.id != 0 ? _buildLoggedInUserDetails(model) : _buildLoggedOutUserDetails(model);
  }

  Widget _buildLoggedInUserDetails(AppStateModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Text(
              model.user.firstName.isNotEmpty ? '${model.user.firstName} ${model.user.lastName}' : model.blocks.localeText.welcome,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              model.user.email,
              style: TextStyle(
                fontSize: 16.0,
                color: greyColor,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            radius: 32.0,
            backgroundImage: NetworkImage(model.user.avatarUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOutUserDetails(AppStateModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Text(
                model.blocks.localeText.welcome,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                model.blocks.localeText.signIn,
                style: TextStyle(
                  fontSize: 16.0,
                  color: greyColor,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              radius: 32.0,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountGroupSliver(MenuGroup accountGroup, AppStateModel model) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (_shouldSkipMenuItem(accountGroup.menuItems[index], model)) {
            return Container();
          } else {
            return _buildMenuItem(accountGroup.menuItems[index], context);
          }
        },
        childCount: accountGroup.menuItems.length,
      ),
    );
  }

  bool _shouldSkipMenuItem(MenuItem menuItem, AppStateModel model) {
    return ['vendorProducts', 'vendorOrders', 'vendorWebView'].contains(menuItem.linkType) && !model.isVendor.contains(model.user.role) ||
        menuItem.linkType == 'login' && model.user.id != 0 ||
        menuItem.linkType == 'logout' && model.user.id == 0;
  }

  Widget _buildMenuItem(MenuItem menuItem, BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onItemClick(menuItem, context);
          },
          child: AccountListTile(
            title: parseHtmlString(menuItem.title),
            subtitle: menuItem.description.isNotEmpty ? menuItem.description : null,
            icon: menuItem.leading.isNotEmpty ? menuItem.leading : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialAccountGroup(AppStateModel model) {
    return SliverToBoxAdapter(
      child: Container(
        height: 460,
        color: Colors.black,
        child: Column(
          children: [
            // Widget for special account group
          ],
        ),
      ),
    );
  }

  Widget _buildRegularAccountGroups(AppStateModel model) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Widget for regular account groups
        ],
      ),
    );
  }
}

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
      child: Column(
        children: [
          SizedBox(height: 16.0),
          ListTile(
            splashColor: null,
            contentPadding: EdgeInsets.all(0),
            trailing: this.icon != null ? DunesIcon(iconString: this.icon!, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black) : null,
            title: Text(
              this.title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: this.subtitle != null
                ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                this.subtitle!,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black,
                ),
              ),
            )
                : null,
          ),
          SizedBox(height: 16.0),
          Divider(height: 0, thickness: 0),
        ],
      ),
    );
  }
}
