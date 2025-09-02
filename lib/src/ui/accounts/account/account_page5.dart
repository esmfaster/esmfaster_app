import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/models/blocks_model.dart';
import 'package:app/src/models/menu_group_model.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:app/src/ui/accounts/account/account_floating_button.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:app/src/ui/widgets/colored_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/accounts/account/account_floating_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AccountPage5 extends StatefulWidget {
  @override
  _AccountPage5State createState() => _AccountPage5State();
}

class _AccountPage5State extends State<AccountPage5> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStateModel>(
      builder: (context, child, model) {
        return Scaffold(
          floatingActionButton: AccountFloatingButton(page: 'account'),
          body: CustomScrollView(
            slivers: _buildList(model),
          ),
        );
      },
    );
  }

  List<Widget> _buildList(AppStateModel model) {
    List<Widget> list = [];

    list.add(_buildSliverAppBar(model));

    model.blocks.settings.accountGroup.forEach((accountGroup) {
      list.addAll(_buildAccountGroup(accountGroup, model));
    });

    list.addAll(_buildSocialLinks(model));

    list.add(SliverToBoxAdapter(
      child: SizedBox(height: 16),
    ));

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
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    } else {
      groupWidgets.add(SliverToBoxAdapter(child: SizedBox(height: 16)));
    }

    groupWidgets.add(
      SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            MenuItem menuItem = accountGroup.menuItems[index];

            if (_shouldSkipMenuItem(menuItem, model)) {
              return Container();
            }

            return Column(
              children: [
                ListTile(
                  onTap: () => onItemClick(menuItem, context),
                  leading: menuItem.leading.isNotEmpty ? DunesIcon(iconString: menuItem.leading) : null,
                  trailing: menuItem.trailing.isNotEmpty ? DunesIcon(iconString: menuItem.trailing) : null,
                  title: Text(menuItem.title, style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: menuItem.description.isNotEmpty ? Text(menuItem.description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Color(0xff8a8a8d))) : null,
                ),
                Divider(thickness: 0),
              ],
            );
          },
          childCount: accountGroup.menuItems.length,
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

  List<Widget> _buildSocialLinks(AppStateModel model) {
    List<Widget> socialLinks = [];

    if (model.blocks.settings.accountSocialLink) {
      socialLinks.add(
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 32, 8, 0),
            height: 60,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (model.blocks.settings.socialLink.facebook.isNotEmpty)
                    _buildSocialIconButton(
                      model.blocks.settings.socialLink.facebook,
                      FontAwesomeIcons.facebookF,
                      Color(0xff4267B2),
                    ),
                  if (model.blocks.settings.socialLink.twitter.isNotEmpty)
                    _buildSocialIconButton(
                      model.blocks.settings.socialLink.twitter,
                      FontAwesomeIcons.twitter,
                      Color(0xff1DA1F2),
                    ),
                  if (model.blocks.settings.socialLink.linkedIn.isNotEmpty)
                    _buildSocialIconButton(
                      model.blocks.settings.socialLink.linkedIn,
                      FontAwesomeIcons.linkedinIn,
                      Color(0xff0e76a8),
                    ),
                  if (model.blocks.settings.socialLink.instagram.isNotEmpty)
                    _buildSocialIconButton(
                      model.blocks.settings.socialLink.instagram,
                      FontAwesomeIcons.instagram,
                      Color(0xfffb3958),
                    ),
                  if (model.blocks.settings.socialLink.whatsapp.isNotEmpty)
                    _buildSocialIconButton(
                      model.blocks.settings.socialLink.whatsapp,
                      FontAwesomeIcons.whatsapp,
                      Color(0xff128C7E),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      socialLinks.add(SliverToBoxAdapter(child: SizedBox(height: 16)));
    }

    if (model.blocks.settings.socialLink.bottomText.isNotEmpty) {
      socialLinks.add(
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: TextButton(
                child: Text(model.blocks.settings.socialLink.bottomText),
                onPressed: () async {
                  final url = model.blocks.settings.socialLink.bottomText;
                  if (url.contains('@') && url.contains('.')) {
                    launchUrl(Uri.parse('mailto:$url'));
                  } else {
                    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
                  }
                },
              ),
            ),
          ),
        ),
      );
    }

    return socialLinks;
  }

  Widget _buildSocialIconButton(String url, IconData icon, Color color) {
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(icon),
      iconSize: 15,
      color: color,
      onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }
}

