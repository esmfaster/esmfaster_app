import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dunes_icons/dunes_icons.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/ui/accounts/account/account_floating_button.dart';
import 'package:app/src/ui/blocks/banners/on_click.dart';
import 'package:app/src/ui/widgets/colored_icon.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
    // Build SliverAppBar
    list.add(_buildAppBar(model));
    // Build account groups
    list.addAll(_buildAccountGroups(model));
    // Build social links
    list.add(_buildSocialLinks(model));
    // Build bottom text button
    list.add(_buildBottomTextButton(model));
    // Add space at the bottom
    list.add(SliverToBoxAdapter(child: SizedBox(height: 40)));
    return list;
  }

  SliverAppBar _buildAppBar(AppStateModel model) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight:
      model.blocks.settings.accountBackgroundImage.isNotEmpty ? 150.0 : 0,
      stretch: true,
      elevation: 0,
      title: model.blocks.settings.accountBackgroundImage.isEmpty
          ? Text(model.blocks.localeText.account)
          : null,
      flexibleSpace: model.blocks.settings.accountBackgroundImage.isNotEmpty
          ? FlexibleSpaceBar(
        stretchModes: [StretchMode.zoomBackground],
        background: CachedNetworkImage(
          imageUrl: model.blocks.settings.accountBackgroundImage,
          placeholder: (context, url) =>
              Container(color: Colors.grey.withOpacity(0.2)),
          errorWidget: (context, url, error) =>
              Container(color: Colors.grey.withOpacity(0.2)),
          fit: BoxFit.cover,
        ),
      )
          : null,
    );
  }

  List<Widget> _buildAccountGroups(AppStateModel model) {
    List<Widget> groups = [];
    model.blocks.settings.accountGroup.forEach((accountGroup) {
      if (accountGroup.showTitle) {
        groups.add(SliverToBoxAdapter(
          child: ListTile(
            subtitle: Text(accountGroup.title,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ));
      } else {
        groups.add(SliverToBoxAdapter(child: SizedBox(height: 16)));
      }

      groups.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (['vendorProducts', 'vendorOrders', 'vendorWebView']
                  .contains(accountGroup.menuItems[index].linkType) &&
                  !model.isVendor.contains(model.user.role)) {
                return Container();
              } else if (accountGroup.menuItems[index].linkType == 'login' &&
                  model.user.id != 0) {
                return Container();
              } else if (accountGroup.menuItems[index].linkType == 'logout' &&
                  model.user.id == 0) {
                return Container();
              } else {
                return Column(
                  children: [
                    ListTile(
                      onTap: () {
                        onItemClick(accountGroup.menuItems[index], context);
                      },
                      leading: accountGroup.menuItems[index].leading.isNotEmpty
                          ? ColoredIcon(
                          item: accountGroup.menuItems[index])
                          : null,
                      trailing:
                      accountGroup.menuItems[index].trailing.isNotEmpty
                          ? DunesIcon(
                          iconString:
                          accountGroup.menuItems[index].trailing, color: Colors.grey)
                          : null,
                      title: Text(
                        accountGroup.menuItems[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: accountGroup.menuItems[index].description.isNotEmpty
                          ? Text(
                        accountGroup.menuItems[index].description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      )
                          : null,
                    ),
                    Divider(
                        height: 0,
                        thickness: 0)
                  ],
                );
              }
            },
            childCount: accountGroup.menuItems.length,
          ),
        ),
      );
    });
    return groups;
  }

  SliverToBoxAdapter _buildSocialLinks(AppStateModel model) {
    if (!model.blocks.settings.accountSocialLink) {
      return SliverToBoxAdapter(child: SizedBox(height: 16));
    }

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
        height: 60,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (model.blocks.settings.socialLink.facebook.isNotEmpty) _buildSocialIconButton(model.blocks.settings.socialLink.facebook, FontAwesomeIcons.facebookF, Color(0xff4267B2)),
              if (model.blocks.settings.socialLink.twitter.isNotEmpty) _buildSocialIconButton(model.blocks.settings.socialLink.twitter, FontAwesomeIcons.twitter, Color(0xff1DA1F2)),
              if (model.blocks.settings.socialLink.linkedIn.isNotEmpty) _buildSocialIconButton(model.blocks.settings.socialLink.linkedIn, FontAwesomeIcons.linkedinIn, Color(0xff0e76a8)),
              if (model.blocks.settings.socialLink.instagram.isNotEmpty) _buildSocialIconButton(model.blocks.settings.socialLink.instagram, FontAwesomeIcons.instagram, Color(0xfffb3958)),
              if (model.blocks.settings.socialLink.whatsapp.isNotEmpty) _buildSocialIconButton(model.blocks.settings.socialLink.whatsapp, FontAwesomeIcons.whatsapp, Color(0xff128C7E)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(String url, IconData icon, Color color) {
    return IconButton(
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(icon),
      iconSize: 15,
      color: color,
      onPressed: () {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
    );
  }

  SliverToBoxAdapter _buildBottomTextButton(AppStateModel model) {
    if (model.blocks.settings.socialLink.bottomText.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox(height: 16));
    }

    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
          child: TextButton(
            child: Text(model.blocks.settings.socialLink.bottomText),
            onPressed: () async {
              if (model.blocks.settings.socialLink.bottomText.contains('@') &&
                  model.blocks.settings.socialLink.bottomText.contains('.')) {
                launchUrl(Uri.parse(
                    'mailto:' + model.blocks.settings.socialLink.bottomText));
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
}
