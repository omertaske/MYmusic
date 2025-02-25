
import 'package:audio_service/audio_service.dart';
import 'package:benim_music/CustomWidgets/add_playlist.dart';
import 'package:benim_music/Helpers/add_mediaitem_to_queue.dart';
import 'package:benim_music/Helpers/mediaitem_converter.dart';
import 'package:benim_music/Screens/Common/song_list.dart';
import 'package:benim_music/Screens/Search/albums.dart';
import 'package:benim_music/Screens/Search/search.dart';
import 'package:benim_music/Services/youtube_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongTileTrailingMenu extends StatefulWidget {
  final Map data;
  final bool isPlaylist;
  final Function(Map)? deleteLiked;
  const SongTileTrailingMenu({
    super.key,
    required this.data,
    this.isPlaylist = false,
    this.deleteLiked,
  });

  @override
  _SongTileTrailingMenuState createState() => _SongTileTrailingMenuState();
}

class _SongTileTrailingMenuState extends State<SongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        if (widget.isPlaylist)
          PopupMenuItem(
            value: 6,
            child: Row(
              children: [
                const Icon(
                  Icons.delete_rounded,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  AppLocalizations.of(
                    context,
                  )!
                      .remove,
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text(AppLocalizations.of(context)!.playNext),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text(AppLocalizations.of(context)!.addToQueue),
            ],
          ),
        ),
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text(AppLocalizations.of(context)!.addToPlaylist),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.album_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Albüme bak"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text(AppLocalizations.of(context)!.viewArtist),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text(AppLocalizations.of(context)!.share),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        final MediaItem mediaItem =
            MediaItemConverter.mapToMediaItem(widget.data);
        if (value == 3) {
          Share.share(widget.data['perma_url'].toString());
        }
        if (value == 4) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => SongsListPage(
                listItem: {
                  'type': 'album',
                  'id': mediaItem.extras?['album_id'],
                  'title': mediaItem.album,
                  'image': mediaItem.artUri,
                },
              ),
            ),
          );
        }
        if (value == 5) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => AlbumSearchPage(
                query: mediaItem.artist.toString().split(', ').first,
                type: 'Artists',
              ),
            ),
          );
        }
        if (value == 6) {
          widget.deleteLiked!(widget.data);
        }
        if (value == 0) {
          AddToPlaylist().addToPlaylist(context, mediaItem);
        }
        if (value == 1) {
          addToNowPlaying(context: context, mediaItem: mediaItem);
        }
        if (value == 2) {
          playNext(mediaItem, context);
        }
      },
    );
  }
}

class YtSongTileTrailingMenu extends StatefulWidget {
  final Video data;
  const YtSongTileTrailingMenu({super.key, required this.data});

  @override
  _YtSongTileTrailingMenuState createState() => _YtSongTileTrailingMenuState();
}

class _YtSongTileTrailingMenuState extends State<YtSongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Text("Anasayfa Ara"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Sonrakini çal"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Sıraya Ekle"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Playlist'e Ekle"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.radio_sharp,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Video İzle"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              Text("Paylaş"),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                query: widget.data.title.split('|')[0].split('(')[0],
              ),
            ),
          );
        }
        if (value == 1 || value == 2 || value == 3) {
          YouTubeServices()
              .formatVideo(
            video: widget.data,
            quality: Hive.box('settings')
                .get(
                  'ytQuality',
                  defaultValue: 'Low',
                )
                .toString(),
          )
              .then((songMap) {
            final MediaItem mediaItem =
                MediaItemConverter.mapToMediaItem(songMap!);
            if (value == 1) {
              playNext(mediaItem, context);
            }
            if (value == 2) {
              addToNowPlaying(context: context, mediaItem: mediaItem);
            }
            if (value == 3) {
              AddToPlaylist().addToPlaylist(context, mediaItem);
            }
          });
        }
        if (value == 4) {
          launchUrl(
            Uri.parse(widget.data.url),
            mode: LaunchMode.externalApplication,
          );
        }
        if (value == 5) {
          Share.share(widget.data.url);
        }
      },
    );
  }
}
