import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.peterlee.dayflect&hl=en_US';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  AnimationController mainController;
  AnimationController subController;

  Animation<double> contentOpacityAnimation;
  Animation<double> movingLogoOpacityAnimation;
  Animation<AlignmentGeometry> movingLogoAlignAnimation;
  Animation<double> staticLogoOpacityAnimation;
  Animation<AlignmentGeometry> staticLogoAlignAnimation;

  Size screenSize;

  @override
  void initState() {
    super.initState();

    mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    subController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    movingLogoOpacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: subController,
        curve: const Interval(0.66, 1.0), // 1000 - 1500
      ),
    );

    movingLogoAlignAnimation = AlignmentGeometryTween(
      begin: Alignment.center,
      end: Alignment.topCenter,
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut), // 1500 - 2000
      ),
    );

    staticLogoOpacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.8, 0.8), // 2000
      ),
    );

    contentOpacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: mainController,
        curve: const Interval(0.8, 1.0), // 2000 - 2500
      ),
    );

    mainController.addListener(() {
      if (mainController.value > 0.8) {
        subController.reverse(from: 0.0);
      }
    });

    subController.forward();
    mainController.forward();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kPastelPurple,
              kPastelBlue,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: buildScreen(),
      ),
    );
  }

  Widget buildScreen() {
    if (screenSize.width < 850) {
      return buildMobileScreen();
    } else {
      return buildWebScreen();
    }
  }

  Stack buildWebScreen() {
    return Stack(
      children: [

        Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: buildDayflectTitle(movingLogoOpacityAnimation),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Stack(
            children: [
              buildDayflectTitle(staticLogoOpacityAnimation),
              Padding(
                padding: const EdgeInsets.only(top: 48.0),
                child: FadeTransition(
                  opacity: contentOpacityAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildContentWidgets(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Stack buildMobileScreen() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: buildDayflectTitle(movingLogoOpacityAnimation),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Stack(
              children: [
                buildDayflectTitle(staticLogoOpacityAnimation),
                Padding(
                  padding: const EdgeInsets.only(top: 64.0),
                  child: Center(
                    child: FadeTransition(
                      opacity: contentOpacityAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: buildContentWidgets(isMobile: true),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  FadeTransition buildDayflectTitle(Animation<double> opacityAnimation) {
    return FadeTransition(
      opacity: opacityAnimation,
      child: AlignTransition(
        alignment: movingLogoAlignAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/white_logo.png',
              width: 32.0,
              height: 32.0,
            ),
            const SizedBox(
              width: 8.0,
            ),
            buildRalewayText(text: 'Dayflect', fontSize: 32.0),
          ],
        ),
      ),
    );
  }

  List<Widget> buildContentWidgets({bool isMobile = false}) {
    return [
      Image.asset(
        'assets/galaxy_read_screenshot.png',
        width: limitNumber(
          min: 300.0,
          number: screenSize.width * 0.25,
          max: 500.0,
        ),
        height: limitNumber(
          min: 400.0,
          number: screenSize.height * 0.65,
          max: 750.0,
        ),
      ),
      SizedBox(
        width: isMobile ? 0.0 : 48.0,
        height: isMobile ? 24.0 : 0.0,
      ),
      buildDetails(
        width: 400.0,
        height: limitNumber(
          min: 300.0,
          number: screenSize.height - 100,
          max: 1000.0,
        ),
        isMobile: isMobile,
      ),
    ];
  }

  Container buildDetails({
    @required double width,
    @required double height,
    bool isMobile = false,
  }) {
    return Container(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          buildRalewayText(
            text: 'Write your memories every day',
            fontSize: 58.0,
            fontWeight: FontWeight.bold,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 32.0),
          buildRalewayText(
            text:
                'Dayflect is a diary app where you can easily see what you wrote '
                'in the past years for a given day. Every day, you can remember and reflect '
                'on what you did a year ago, 2 years ago, and on.',
            fontSize: 18.0,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 32.0),
          Center(child: buildStoreButtons()),
        ],
      ),
    );
  }

  Widget buildStoreButtons() {
    if (screenSize.width < 1025) {
      return Column(
        children: [
          Image.asset('assets/download_app_store.png'),
          const SizedBox(height: 16.0),
          buildStoreButton(
            assetUrl: 'assets/download_play_store.png',
            storeUrl: HomeScreen.playStoreUrl,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Image.asset('assets/download_app_store.png'),
          const SizedBox(width: 16.0),
          buildStoreButton(
            assetUrl: 'assets/download_play_store.png',
            storeUrl: HomeScreen.playStoreUrl,
          ),
        ],
      );
    }
  }

  MouseRegion buildStoreButton({
    @required String assetUrl,
    @required String storeUrl,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (await canLaunch(storeUrl)) {
            await launch(storeUrl);
          } else {
            throw 'Could not launch $storeUrl';
          }
        },
        child: Image.asset(assetUrl),
      ),
    );
  }

  SelectableText buildRalewayText(
      {@required String text,
      @required double fontSize,
      FontWeight fontWeight = FontWeight.normal,
      Color fontColor = Colors.white,
      TextAlign textAlign = TextAlign.start}) {
    return SelectableText(
      text,
      style: GoogleFonts.raleway(
        textStyle: TextStyle(
          color: fontColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: textAlign,
    );
  }

  double limitNumber({
    @required double number,
    @required double min,
    @required double max,
  }) {
    if (number < min) return min;
    if (number > max) return max;
    return number;
  }
}

const Color kPastelPurple = Color.fromRGBO(138, 115, 238, 1.0);
const Color kPastelBlue = Color.fromRGBO(102, 153, 255, 1.0);
