import 'dart:io';
import 'dart:math';

import 'package:benim_music/CustomWidgets/custom_physics.dart';
import 'package:benim_music/CustomWidgets/gradient_containers.dart';
import 'package:benim_music/CustomWidgets/miniplayer.dart';
import 'package:benim_music/CustomWidgets/snackbar.dart';
import 'package:benim_music/CustomWidgets/textinput_dialog.dart';
import 'package:benim_music/Helpers/backup_restore.dart';
import 'package:benim_music/Helpers/downloads_checker.dart';
import 'package:benim_music/Helpers/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:benim_music/Helpers/supabase.dart';
import 'package:benim_music/Screens/Home/saavn.dart';
import 'package:benim_music/Screens/Library/library.dart';
import 'package:benim_music/Screens/LocalMusic/downed_songs.dart';
import 'package:benim_music/Screens/Search/search.dart';
import 'package:benim_music/Screens/Settings/setting.dart';
import 'package:benim_music/Screens/YouTube/youtube_home.dart';
import 'package:benim_music/Services/ext_storage_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  bool checked = false;
  String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  bool checkUpdate =
      Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  DateTime? backButtonPressTime;

  void callback() {
    setState(() {});
  }

  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
  }

  bool compareVersion(String latestVersion, String currentVersion) {
    bool update = false;
    final List latestList = latestVersion.split('.');
    final List currentList = currentVersion.split('.');

    for (int i = 0; i < latestList.length; i++) {
      try {
        if (int.parse(latestList[i] as String) >
            int.parse(currentList[i] as String)) {
          update = true;
          break;
        }
      } catch (e) {
        break;
      }
    }
    return update;
  }

  void updateUserDetails(String key, dynamic value) {
    final userId = Hive.box('settings').get('userId') as String?;
    SupaBase().updateUserDetails(userId, key, value);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  Widget checkVersion() {
    if (!checked && Theme.of(context).platform == TargetPlatform.android) {
      checked = true;
      final SupaBase db = SupaBase();
      final DateTime now = DateTime.now();
      final List lastLogin = now
          .toUtc()
          .add(const Duration(hours: 5, minutes: 30))
          .toString()
          .split('.')
        ..removeLast()
        ..join('.');
      updateUserDetails('lastLogin', '${lastLogin[0]} IST');
      final String offset =
          now.timeZoneOffset.toString().replaceAll('.000000', '');

      updateUserDetails(
        'timeZone',
        'Zone: ${now.timeZoneName}, Offset: $offset',
      );

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        appVersion = packageInfo.version;
        updateUserDetails('version', packageInfo.version);

        if (checkUpdate) {
          db.getUpdate().then((Map value) async {
            if (compareVersion(
              value['LatestVersion'] as String,
              appVersion!,
            )) {
              List? abis =
                  await Hive.box('settings').get('supportedAbis') as List?;

              if (abis == null) {
                final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                final AndroidDeviceInfo androidDeviceInfo =
                    await deviceInfo.androidInfo;
                abis = androidDeviceInfo.supportedAbis;
                await Hive.box('settings').put('supportedAbis', abis);
              }

              ShowSnackBar().showSnackBar(
                context,
                AppLocalizations.of(context)!.updateAvailable,
                duration: const Duration(seconds: 15),
                action: SnackBarAction(
                  textColor: Theme.of(context).colorScheme.secondary,
                  label: AppLocalizations.of(context)!.update,
                  onPressed: () {
                    Navigator.pop(context);
                    if (abis!.contains('arm64-v8a')) {
                      launchUrl(
                        Uri.parse(value['arm64-v8a'] as String),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (abis.contains('armeabi-v7a')) {
                        launchUrl(
                          Uri.parse(value['armeabi-v7a'] as String),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        launchUrl(
                          Uri.parse(value['universal'] as String),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                ),
              );
            }
          });
        }
        if (autoBackup) {
          final List<String> checked = [
            AppLocalizations.of(
              context,
            )!
                .settings,
            AppLocalizations.of(
              context,
            )!
                .downs,
            AppLocalizations.of(
              context,
            )!
                .playlists,
          ];
          final List playlistNames = Hive.box('settings').get(
            'playlistNames',
            defaultValue: ['Favorite Songs'],
          ) as List;
          final Map<String, List> boxNames = {
            AppLocalizations.of(
              context,
            )!
                .settings: ['settings'],
            AppLocalizations.of(
              context,
            )!
                .cache: ['cache'],
            AppLocalizations.of(
              context,
            )!
                .downs: ['downloads'],
            AppLocalizations.of(
              context,
            )!
                .playlists: playlistNames,
          };
          final String autoBackPath = Hive.box('settings').get(
            'autoBackPath',
            defaultValue: '',
          ) as String;
          if (autoBackPath == '') {
            ExtStorageProvider.getExtStorage(
              dirName: 'Benimmusic/Backups',
            ).then((value) {
              Hive.box('settings').put('autoBackPath', value);
              createBackup(
                context,
                checked,
                boxNames,
                path: value,
                fileName: 'Benimmusic_AutoBackup',
                showDialog: false,
              );
            });
          } else {
            createBackup(
              context,
              checked,
              boxNames,
              path: autoBackPath,
              fileName: 'Benimmusic_AutoBackup',
              showDialog: false,
            );
          }
        }
      });
      if (Hive.box('settings').get('proxyIp') == null) {
        Hive.box('settings').put('proxyIp', '103.47.67.134');
      }
      if (Hive.box('settings').get('proxyPort') == null) {
        Hive.box('settings').put('proxyPort', 8080);
      }
      downloadChecker();
      return const SizedBox();
    } else {
      return const SizedBox();
    }
  }

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: GradientContainer(
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  stretch: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: RichText(
                      text: TextSpan(
                        text: 'MY Music',
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w500,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: appVersion == null ? '' : '\nv$appVersion',
                            style: const TextStyle(
                              fontSize: 7.0,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 40.0),
                    centerTitle: true,
                    background: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.1),
                          ],
                        ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height),
                        );
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image(
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/header-dark.jpg'
                              : 'assets/header.jpg',
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        title: Text(
                          'Ana Sayfa',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.home_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        selected: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      if (Platform.isAndroid)
                        ListTile(
                          title: const Text('Müziklerim'),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20.0),
                          leading: Icon(
                            MdiIcons.folderMusic,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DownloadedSongs(
                                  showPlaylists: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ListTile(
                        title: const Text('İndirilenler'),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.download_done_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/downloads');
                        },
                      ),
                      ListTile(
                        title: const Text('Playlist'),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.playlist_play_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/playlists');
                        },
                      ),
                      ListTile(
                        title: const Text('Ayarlar'),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons
                              .settings_rounded, // miscellaneous_services_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SettingPage(callback: callback),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Hakkında'),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: const <Widget>[
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 30, 5, 20),
                        child: Center(
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: SafeArea(
            child: Row(
              children: [
                if (rotated)
                  ValueListenableBuilder(
                    valueListenable: _selectedIndex,
                    builder:
                        (BuildContext context, int indexValue, Widget? child) {
                      return NavigationRail(
                        minWidth: 70.0,
                        groupAlignment: 0.0,
                        backgroundColor:
                            // Colors.transparent,
                            Theme.of(context).cardColor,
                        selectedIndex: indexValue,
                        onDestinationSelected: (int index) {
                          _onItemTapped(index);
                        },
                        labelType: screenWidth > 1050
                            ? NavigationRailLabelType.selected
                            : NavigationRailLabelType.none,
                        selectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                        ),
                        selectedIconTheme: Theme.of(context).iconTheme.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                        unselectedIconTheme: Theme.of(context).iconTheme,
                        useIndicator: screenWidth < 1050,
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        leading: screenWidth > 1050
                            ? null
                            : Builder(
                                builder: (context) => Transform.rotate(
                                  angle: 22 / 7 * 2,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.horizontal_split_rounded,
                                    ),
                                    // color: Theme.of(context).iconTheme.color,
                                    onPressed: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                    tooltip: MaterialLocalizations.of(context)
                                        .openAppDrawerTooltip,
                                  ),
                                ),
                              ),
                        destinations: [
                          const NavigationRailDestination(
                            icon: Icon(Icons.home_rounded),
                            label: Text(""),
                          ),
                          // NavigationRailDestination(
                          //   icon: const Icon(Icons.trending_up_rounded),
                          //   label: Text(
                          //     AppLocalizations.of(context)!.topCharts,
                          //   ),
                          // ),
                          const NavigationRailDestination(
                            icon: Icon(MdiIcons.youtube),
                            label: Text(""),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.radio_sharp),
                            label: Text(""),
                          ),
                        ],
                      );
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          physics: const CustomPhysics(),
                          onPageChanged: (indx) {
                            _selectedIndex.value = indx;
                          },
                          controller: _pageController,
                          children: [
                            Stack(
                              children: [
                                checkVersion(),
                                NestedScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  controller: _scrollController,
                                  headerSliverBuilder: (
                                    BuildContext context,
                                    bool innerBoxScrolled,
                                  ) {
                                    return <Widget>[
                                      SliverAppBar(
                                        expandedHeight:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        // pinned: true,
                                        toolbarHeight: 65,
                                        // floating: true,
                                        automaticallyImplyLeading: false,
                                        flexibleSpace: LayoutBuilder(
                                          builder: (
                                            BuildContext context,
                                            BoxConstraints constraints,
                                          ) {
                                            return FlexibleSpaceBar(
                                              collapseMode:
                                                  CollapseMode.parallax,
                                              background: GestureDetector(
                                                onTap: () async {
                                                  await showTextInputDialog(
                                                    context: context,
                                                    title: 'Name',
                                                    initialText: name,
                                                    keyboardType:
                                                        TextInputType.name,
                                                    onSubmitted: (value) {
                                                      Hive.box('settings').put(
                                                        'name',
                                                        value.trim(),
                                                      );
                                                      name = value.trim();
                                                      Navigator.pop(context);
                                                      updateUserDetails(
                                                        'name',
                                                        value.trim(),
                                                      );
                                                    },
                                                  );
                                                  setState(() {});
                                                },
                                                child: Column(
                                                  children: <Widget>[
                                                    const SizedBox(
                                                      height: 60,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 15.0,
                                                          ),
                                                          child: Text(
                                                            'Merhaba',
                                                            style: TextStyle(
                                                              letterSpacing: 2,
                                                              color: Theme.of(
                                                                context,
                                                              )
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontSize: 30,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 25.0,
                                                              top: 10),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          ValueListenableBuilder(
                                                            valueListenable:
                                                                Hive.box(
                                                              'settings',
                                                            ).listenable(),
                                                            builder: (
                                                              BuildContext
                                                                  context,
                                                              Box box,
                                                              Widget? child,
                                                            ) {
                                                              return Expanded(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      (box.get('name') == null ||
                                                                              box.get('name') == '')
                                                                          ? 'Guest'
                                                                          : box
                                                                              .get(
                                                                                'name',
                                                                              )
                                                                              .split(
                                                                                ' ',
                                                                              )[0]
                                                                              .toString()
                                                                              .capitalize(),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        letterSpacing:
                                                                            5,
                                                                        fontSize:
                                                                            35,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      // const SliverAppBar(
                                      //   automaticallyImplyLeading: false,
                                      //   pinned: true,
                                      //   backgroundColor: Colors.transparent,
                                      //   elevation: 0,
                                      //   stretch: true,
                                      //   toolbarHeight: 65,
                                      //   // title: Align(
                                      //   //   alignment: Alignment.centerRight,
                                      //   //   child: AnimatedBuilder(
                                      //   //     animation: _scrollController,
                                      //   //     builder: (context, child) {
                                      //   //       return GestureDetector(
                                      //   //         child: AnimatedContainer(
                                      //   //           width: (!_scrollController
                                      //   //                       .hasClients ||
                                      //   //                   _scrollController
                                      //   //                           // ignore: invalid_use_of_protected_member
                                      //   //                           .positions
                                      //   //                           .length >
                                      //   //                       1)
                                      //   //               ? MediaQuery.of(context)
                                      //   //                   .size
                                      //   //                   .width
                                      //   //               : max(
                                      //   //                   MediaQuery.of(context)
                                      //   //                           .size
                                      //   //                           .width -
                                      //   //                       _scrollController
                                      //   //                           .offset
                                      //   //                           .roundToDouble(),
                                      //   //                   MediaQuery.of(context)
                                      //   //                           .size
                                      //   //                           .width -
                                      //   //                       75,
                                      //   //                 ),
                                      //   //           height: 52.0,
                                      //   //           duration: const Duration(
                                      //   //             milliseconds: 150,
                                      //   //           ),
                                      //   //           padding:
                                      //   //               const EdgeInsets.all(2.0),
                                      //   //           // margin: EdgeInsets.zero,
                                      //   //           decoration: BoxDecoration(
                                      //   //             borderRadius:
                                      //   //                 BorderRadius.circular(
                                      //   //               10.0,
                                      //   //             ),
                                      //   //             color: Theme.of(context)
                                      //   //                 .cardColor,
                                      //   //             boxShadow: const [
                                      //   //               BoxShadow(
                                      //   //                 color: Colors.black26,
                                      //   //                 blurRadius: 5.0,
                                      //   //                 offset:
                                      //   //                     Offset(1.5, 1.5),
                                      //   //                 // shadow direction: bottom right
                                      //   //               )
                                      //   //             ],
                                      //   //           ),
                                      //   //           child: Row(
                                      //   //             children: [
                                      //   //               const SizedBox(
                                      //   //                 width: 10.0,
                                      //   //               ),
                                      //   //               Icon(
                                      //   //                 CupertinoIcons.search,
                                      //   //                 color: Theme.of(context)
                                      //   //                     .colorScheme
                                      //   //                     .secondary,
                                      //   //               ),
                                      //   //               const SizedBox(
                                      //   //                 width: 10.0,
                                      //   //               ),
                                      //   //               Text(
                                      //   //                 "Şarkılar, Albümler ve Sanatçılar",
                                      //   //                 style: TextStyle(
                                      //   //                   fontSize: 16.0,
                                      //   //                   color:
                                      //   //                       Theme.of(context)
                                      //   //                           .textTheme
                                      //   //                           .caption!
                                      //   //                           .color,
                                      //   //                   fontWeight:
                                      //   //                       FontWeight.normal,
                                      //   //                 ),
                                      //   //               ),
                                      //   //             ],
                                      //   //           ),
                                      //   //         ),
                                      //   //         onTap: () => Navigator.push(
                                      //   //           context,
                                      //   //           MaterialPageRoute(
                                      //   //             builder: (context) =>
                                      //   //                 const SearchPage(
                                      //   //               query: '',
                                      //   //               fromHome: true,
                                      //   //               autofocus: true,
                                      //   //             ),
                                      //   //           ),
                                      //   //         ),
                                      //   //       );
                                      //   //     },
                                      //   //   ),
                                      //   // ),
                                      // ),
                                    ];
                                  },
                                  body: SaavnHomePage(),
                                ),
                                if (!rotated || screenWidth > 1050)
                                  Builder(
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        left: 4.0,
                                      ),
                                      child: Transform.rotate(
                                        angle: 22 / 7 * 2,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.horizontal_split_rounded,
                                          ),
                                          // color: Theme.of(context).iconTheme.color,
                                          onPressed: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          tooltip:
                                              MaterialLocalizations.of(context)
                                                  .openAppDrawerTooltip,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // TopCharts(
                            //   pageController: _pageController,
                            // ),
                            const YouTube(),
                            LibraryPage(),
                          ],
                        ),
                      ),
                      const MiniPlayer()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: rotated
            ? null
            : SafeArea(
                child: ValueListenableBuilder(
                  valueListenable: _selectedIndex,
                  builder:
                      (BuildContext context, int indexValue, Widget? child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: 60,
                      child: SalomonBottomBar(
                        currentIndex: indexValue,
                        onTap: (index) {
                          _onItemTapped(index);
                        },
                        items: [
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.home_rounded),
                            title: const Text(''),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          // SalomonBottomBarItem(
                          //   icon: const Icon(Icons.trending_up_rounded),
                          //   title: Text(
                          //     AppLocalizations.of(context)!.topCharts,
                          //   ),
                          //   selectedColor:
                          //       Theme.of(context).colorScheme.secondary,
                          // ),
                          SalomonBottomBarItem(
                            icon: const Icon(MdiIcons.youtube),
                            title: const Text(''),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          SalomonBottomBarItem(
                            icon: const Icon(Icons.radio_sharp),
                            title: const Text(''),
                            selectedColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
