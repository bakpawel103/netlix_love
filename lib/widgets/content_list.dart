import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:googleapis/drive/v3.dart';
import 'package:provider/provider.dart';

import '../providers/google_drive_provider.dart';

class ContentList extends StatelessWidget {
  final String title;
  final List<File> contentList;
  final bool isOriginals;

  const ContentList({
    Key? key,
    required this.title,
    required this.contentList,
    this.isOriginals = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: isOriginals ? 500.0 : 220.0,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: contentList.length,
              itemBuilder: (BuildContext context, int index) {
                final File content = contentList[index];
                return GestureDetector(
                  onTap: () => _imageClicked(context, content),
                  child: FutureBuilder(
                    future: _buildImage(context, content),
                    builder: (BuildContext context,
                        AsyncSnapshot<Uint8List?> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == null) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            height: isOriginals ? 400.0 : 200.0,
                            width: isOriginals ? 200.0 : 130.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                            child:
                                CupertinoActivityIndicator(color: Colors.black),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: isOriginals ? 400.0 : 200.0,
                          width: isOriginals ? 200.0 : 130.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(snapshot.data!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: isOriginals ? 400.0 : 200.0,
                          width: isOriginals ? 200.0 : 130.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                          child: Icon(Icons.remove),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: isOriginals ? 400.0 : 200.0,
                          width: isOriginals ? 200.0 : 130.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
                          child:
                              CupertinoActivityIndicator(color: Colors.black),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _buildImage(BuildContext context, File? content) async {
    if (content == null) {
      return null;
    }

    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);

    return provider.googleDrive.fetchImage(content);
  }

  _imageClicked(BuildContext context, File content) {
    var width = MediaQuery.of(context).size.width * 1 / 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 20.0,
                top: 20.0,
                child: IconButton(
                  iconSize: 20,
                  color: Colors.white,
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Center(
                child: FutureBuilder(
                  future: _buildBigImage(context, content, width),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List?> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == null) {
                        return SizedBox();
                      }
                      return Image.memory(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return SizedBox();
                    } else {
                      return CupertinoActivityIndicator(
                        color: Colors.white,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List?> _buildBigImage(
      BuildContext context, File? content, double width) async {
    if (content == null) {
      return null;
    }

    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);

    return provider.googleDrive.fetchImage(content, size: width);
  }
}
