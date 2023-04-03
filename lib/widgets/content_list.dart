import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:googleapis/drive/v3.dart';
import 'package:intl/intl.dart';
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
    print(contentList.length);

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
              shrinkWrap: true,
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

    DateTime? dateTime =
        formatGoogleTimeToDateTime(content.imageMediaMetadata?.time);
    String dateString = 'None';
    if (dateTime != null) {
      dateString = DateFormat.yMEd().add_jms().format(dateTime);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 30.0,
                top: 30.0,
                child: IconButton(
                  iconSize: 30,
                  color: Colors.white,
                  icon: const Icon(CupertinoIcons.clear),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder(
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
                    SizedBox(height: 30.0),
                    FutureBuilder(
                      future: _getImageAddress(content),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null) {
                            return SizedBox();
                          }
                          return Text(
                            'Address: ${snapshot.data!}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return SizedBox();
                        } else {
                          return CupertinoActivityIndicator(
                            color: Colors.white,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      'Date: $dateString',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime? formatGoogleTimeToDateTime(String? text) {
    if (text == null) {
      return null;
    }

    text = text.replaceAll(' ', ':');
    var array = text.split(':');

    if (array.length < 6) {
      return null;
    }

    return DateTime(
        int.parse(array[0].trim()),
        int.parse(array[1].trim()),
        int.parse(array[2].trim()),
        int.parse(array[3].trim()),
        int.parse(array[4].trim()),
        int.parse(array[5].trim()));
  }

  Future<Uint8List?> _buildBigImage(
      BuildContext context, File? content, double width) async {
    if (content == null) {
      return null;
    }

    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);

    return provider.googleDrive.fetchImage(content, size: width);
  }

  Future<String> _getImageAddress(File? content) async {
    if (content == null ||
        content.imageMediaMetadata == null ||
        content.imageMediaMetadata?.location == null ||
        content.imageMediaMetadata?.location?.latitude == null ||
        content.imageMediaMetadata?.location?.longitude == null) {
      return "Can't find location...";
    }

    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${content.imageMediaMetadata?.location?.latitude},${content.imageMediaMetadata?.location?.longitude}&key=AIzaSyDlxDVy4VJHsbBfRGhuyC0PZsZR23i5HqY'));

    if (jsonDecode(response.body)['results'] == null ||
        jsonDecode(response.body)['results'][0] == null ||
        jsonDecode(response.body)['results'][0]['formatted_address'] == null) {
      return "Can't find location...";
    }

    return jsonDecode(response.body)['results'][0]?['formatted_address'];
  }
}
