import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_netflix_responsive_ui/cubits/cubits.dart';
import 'package:flutter_netflix_responsive_ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/google_drive_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController()
      ..addListener(() {
        context.read<AppBarCubit>().setOffset(_scrollController.offset);
      });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoogleDriveProvider>(context);

    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[850],
        child: const Icon(Icons.cast),
        onPressed: null,
      ),
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 50.0),
        child: BlocBuilder<AppBarCubit, double>(
          builder: (context, scrollOffset) {
            return CustomAppBar(scrollOffset: scrollOffset);
          },
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: _generateSilvers(),
      ),
    );
  }

  List<Widget> _generateSilvers() {
    final provider = Provider.of<GoogleDriveProvider>(context, listen: false);
    List<Widget> silvers = [];

    silvers.add(
      SliverToBoxAdapter(
        child: ContentHeader(),
      ),
    );

    var index = 0;
    for (var file in provider.googleDrive.categoriesFiles.entries) {
      if (index == 0) {
        silvers.add(
          SliverPadding(
            padding: const EdgeInsets.only(top: 20.0),
            sliver: SliverToBoxAdapter(
              child: ContentList(
                key: PageStorageKey(file.key.name ?? 'None'),
                title: file.key.name ?? 'None',
                contentList: file.value ?? [],
              ),
            ),
          ),
        );
      } else {
        silvers.add(SliverToBoxAdapter(
          child: ContentList(
            key: PageStorageKey(file.key.name ?? 'None'),
            title: file.key.name ?? 'None',
            contentList: file.value ?? [],
          ),
        ));
      }

      index++;
    }

    return silvers;
  }
}
