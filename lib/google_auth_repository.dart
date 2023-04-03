import 'dart:typed_data';

import 'package:flutter_netflix_responsive_ui/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

class GoogleAuthRepository {
  Map<String, String>? authHeaders;
  GoogleAuthClient? authenticateClient;
  DriveApi? driveApi;

  Map<File, List<File>?> categoriesFiles = {};

  static final String Netflix_catalog_id = '1HSgNR-rU1kXAxNC26_2jjYiY15FUJe_x';

  Future<void> signIn() async {
    final googleSignIn = GoogleSignIn.standard(scopes: [DriveApi.driveScope]);
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    print("User account $account");

    authHeaders = await account?.authHeaders;
    authenticateClient = GoogleAuthClient(authHeaders!);
    driveApi = DriveApi(authenticateClient!);
  }

  Future<List<File>?> fetchCategories() async {
    // Get categories
    var categories = await driveApi?.files.list(
        q: "'$Netflix_catalog_id' in parents",
        $fields:
            'files(kind,id,name,mimeType,thumbnailLink,hasThumbnail,imageMediaMetadata(location))');
    if (categories == null || categories.files == null) {
      return null;
    }

    for (var categoryFile in categories.files!) {
      var imagesFiles = await driveApi?.files.list(
          q: "'${categoryFile.id}' in parents",
          $fields:
              'files(kind,id,name,mimeType,thumbnailLink,hasThumbnail,imageMediaMetadata(location))');
      if (imagesFiles == null || imagesFiles.files == null) {
        return null;
      }

      categoriesFiles.addEntries([MapEntry(categoryFile, imagesFiles.files)]);
    }
  }

  Future<Uint8List?> fetchImage(File content, {double? size}) async {
    print(content.thumbnailLink);
    if (content.hasThumbnail == null || content.hasThumbnail == false) {
      print('[${content.id}] has no thumbnail');
      return null;
    }

    if (size != null) {
      content.thumbnailLink = content.thumbnailLink
          ?.replaceAll(RegExp(r'[s][0-9]{3}'), 's${size.toInt()}');
    }

    http.Response? response;
    try {
      response = await http.get(Uri.parse(content.thumbnailLink!));
    } catch (e) {
      print(e.toString());
    }

    if (response == null) {
      print('[${content.id}] error downloading thumbnail...');
      return null;
    }

    return response.bodyBytes;
  }
}
