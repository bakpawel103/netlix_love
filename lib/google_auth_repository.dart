import 'package:flutter_netflix_responsive_ui/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    var categories =
        await driveApi?.files.list(q: "'$Netflix_catalog_id' in parents");
    if (categories == null || categories.files == null) {
      return null;
    }

    for (var categoryFile in categories.files!) {
      var imagesFiles =
          await driveApi?.files.list(q: "'${categoryFile.id}' in parents");
      if (imagesFiles == null || imagesFiles.files == null) {
        return null;
      }

      categoriesFiles.addEntries([MapEntry(categoryFile, imagesFiles.files)]);
    }
  }

  Future<String> fetchImage(String id) async {
    var image = await driveApi?.files
        .get(id, downloadOptions: DownloadOptions.fullMedia);

    return image.toString();
  }
}
