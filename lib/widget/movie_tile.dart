import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/movie.dart';

class MovieTile extends StatefulWidget {
  @override
  _MovieTileState createState() => _MovieTileState();

  Movie movie;

  MovieTile({
    Key? key,
    required this.movie,
  }) : super(key: key);
}

class _MovieTileState extends State<MovieTile> {
  double posterHeight = 240;
  double posterWidth = 150;
  RoundedRectangleBorder posterBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

  @override
  void initState() {
    super.initState();
  }

  /* _launchLink() {

    Format ID + Default link

    launchUrl(
      Uri.parse(),
      mode: LaunchMode.externalApplication,
    );
  }*/

  void _delete() async {}

  /* void openBottomMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      widget.playlist.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text(
                      "Share",
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Share.share(
                          "${widget.playlist.title} - ${widget.playlist.artist!}\n\n${widget.playlist.link}");
                    },
                  ),
                  Visibility(
                    visible:
                    widget.playlist.state != 0 && !widget.isPageDownloads,
                    child: ListTile(
                      leading: const Icon(Icons.queue_music_outlined),
                      title: const Text(
                        "Listen",
                      ),
                      onTap: () {
                        _changePlaylistState(0);
                        widget.refreshHome();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Visibility(
                    visible:
                    widget.playlist.state != 1 && !widget.isPageDownloads,
                    child: ListTile(
                      leading: const Icon(Icons.archive_outlined),
                      title: const Text(
                        "Archive",
                      ),
                      onTap: () {
                        _changePlaylistState(1);
                        widget.refreshHome();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Visibility(
                    visible:
                    widget.playlist.state != 2 && !widget.isPageDownloads,
                    child: ListTile(
                      leading: const Icon(Icons.favorite_border_outlined),
                      title: const Text(
                        "Favorite",
                      ),
                      onTap: () {
                        _changePlaylistState(2);
                        widget.refreshHome();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text(
                      "Edit",
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => EditPlaylist(
                              playlist: widget.playlist,
                              refreshHome: widget.refreshHome,
                            ),
                          ));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_outlined),
                    title: const Text(
                      "Delete",
                    ),
                    onTap: () {
                      widget.removeFromList(widget.index);
                      Navigator.of(context).pop();
                      _showSnackBar();
                      Timer(const Duration(seconds: 5), () {
                        if (deleteAfterTimer) {
                          _delete();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }*/

  /*void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Playlist deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            deleteAfterTimer = false;
            widget.refreshHome();
          },
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {

    return InkWell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          flex: 1,
          child: (widget.movie.getPoster() == null)
              ? SizedBox(
                  height: posterHeight,
                  width: posterWidth,
                  child: Card(
                    elevation: 1,
                    shape: posterBorder,
                    child: Icon(
                      Icons.image_outlined,
                      size: 30,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                )
              : SizedBox(
                  height: posterHeight,
                  width: posterWidth,
                  child: Card(
                    elevation: 1,
                    shape: posterBorder,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(widget.movie.getPoster()!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
        ),
      ]),
    );
  }
}
