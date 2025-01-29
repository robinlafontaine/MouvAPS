import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/pages/home/custom_bottom_navigation.dart';
import 'package:mouvaps/pages/home/selected_page/selected_content.dart';
import 'package:mouvaps/pages/home/selected_page/selected_title.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/globals/globals.dart' as globals;
import 'package:mouvaps/pages/profile/profile_screen.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:provider/provider.dart';
import 'package:mouvaps/notifiers/user_points_notifier.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/services/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index when the item is tapped
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index when the page is swiped
    });
  }


  @override
  void initState() {
    super.initState();
    final userPointsNotifier =
        Provider.of<UserPointsNotifier>(context, listen: false);
    userPointsNotifier.fetchUserPoints();
  }

  //TODO: Rework banner design
  Widget _buildCertificateBanner() {
      return FutureBuilder<bool>(
        future: Auth.instance.hasCertificate(),
        builder: (context, snapshot) {
          if (snapshot.hasData && !snapshot.data!) {
            return MaterialBanner(
              content: const Text('N\'oubliez pas d\'envoyer votre certificat médical !'),
              leading: const Icon(Icons.description),
              backgroundColor: constants.lightColor,
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/profile"),
                  child: const Text('J\'y vais !'),
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: lighterColor,
          elevation: 1,
          title: SelectedTitle(
              currentIndex: _selectedIndex, isAdmin: globals.isAdmin),
          actions: [
            Consumer<UserPointsNotifier>(
              builder: (context, userPointsNotifier, child) {
                return BadgeText(
                  content: '${userPointsNotifier.points}',
                );
              },
            ),
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.solidCircleUser,
                color: primaryColor,
                size: 32,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfileScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                SelectedPage(currentIndex: 0, isAdmin: globals.isAdmin),
                SelectedPage(currentIndex: 1, isAdmin: globals.isAdmin),
                SelectedPage(currentIndex: 2, isAdmin: globals.isAdmin),
                if(!globals.isAdmin) SelectedPage(currentIndex: 3, isAdmin: globals.isAdmin),
                if(!globals.isAdmin) SelectedPage(currentIndex: 4, isAdmin: globals.isAdmin),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildCertificateBanner(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          isAdmin: globals.isAdmin),
    );
  }
}
