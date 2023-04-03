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
                  onTap: () => print(content.toJson()),
                  child: FutureBuilder(
                    future: _buildImage(context, content.id),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == null) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            height: isOriginals ? 400.0 : 200.0,
                            width: isOriginals ? 200.0 : 130.0,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: isOriginals ? 400.0 : 200.0,
                          width: isOriginals ? 200.0 : 130.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(snapshot.data!),
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
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          height: isOriginals ? 400.0 : 200.0,
                          width: isOriginals ? 200.0 : 130.0,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                          ),
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

  Future<String?> _buildImage(BuildContext context, String? id) async {
    if (id == null) {
      return null;
    }

    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);

    return provider.googleDrive.fetchImage(id);
  }
}
