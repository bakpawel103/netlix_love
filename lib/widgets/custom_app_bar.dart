import 'package:flutter/material.dart';

import 'package:flutter_netflix_responsive_ui/widgets/widgets.dart';

class CustomAppBar extends StatelessWidget {
  final double scrollOffset;

  const CustomAppBar({
    Key? key,
    this.scrollOffset = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 24.0,
      ),
      color:
          Colors.black.withOpacity((scrollOffset / 350).clamp(0, 1).toDouble()),
      child: Responsive(
        mobile: _CustomAppBarMobile(),
        desktop: _CustomAppBarDesktop(),
      ),
    );
  }
}

class _CustomAppBarMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Image.asset('assets/images/netflix_logo.png'),
          const SizedBox(width: 12.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AppBarButton(
                  title: 'Strona główna',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Seriale i programy',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Filmy',
                  onTap: () => null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAppBarDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          Image.asset('assets/images/netflix_logo.png', height: 30.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AppBarButton(
                  title: 'Strona główna',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Seriale i programy',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Filmy',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Nowe i popularne',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Moja lista',
                  onTap: () => null,
                ),
                _AppBarButton(
                  title: 'Przeglądaj wg języka',
                  onTap: () => null,
                ),
              ],
            ),
          ),
          Spacer(),
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.search),
                iconSize: 28.0,
                color: Colors.white,
                onPressed: () => null,
              ),
              SizedBox(width: 20.0),
              _AppBarButton(
                title: 'Dzieci',
                onTap: () => null,
              ),
              SizedBox(width: 20.0),
              ClipOval(
                child: Image.asset(
                  'assets/images/avatar.jpg',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String title;
  final Function onTap;

  const _AppBarButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap(),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
