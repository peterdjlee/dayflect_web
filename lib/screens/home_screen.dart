import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  AnimationController mainController;
  AnimationController subController;

  Animation<double> contentOpacityAnimation;
  Animation<double> movingLogoOpacityAnimation;
  Animation<AlignmentGeometry> movingLogoAlignAnimation;
  Animation<double> staticLogoOpacityAnimation;
  Animation<AlignmentGeometry> staticLogoAlignAnimation;

  Size screenSize;

  static const minScreenWidthWeb = 750.0;

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.peterlee.dayflect&hl=en_US';

  static const appStoreUrl = 'https://apps.apple.com/app/id1520852249';

  static const whiteLogoUrl = 'assets/white_logo.png';
  static const iosScreenshotUrl = 'assets/ios_signin_screenshot.png';
  static const androidScreenshotUrl = 'assets/android_read_screenshot.png';
  static const appStoreButtonUrl = 'assets/download_app_store.png';
  static const playStoreButtonUrl = 'assets/download_play_store.png';

  static const titleString = 'Reflect every day';
  static const firstDecriptionString =
      'Dayflect is a diary app that lets you write about each day in a simple, manageable way.';
  static const secondDescriptionString =
      'More than a daily journal, Dayflect accumulates entries from successive years, '
      'allowing users to revisit past memories on a specific day and reflect on change and growth.';
  static const feedbackString =
      'Have questions or feedback? Email dayflect@gmail.com';

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
    if (screenSize.width < minScreenWidthWeb) {
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
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 48.0, bottom: 48.0),
            child: Column(
              children: [
                buildDayflectTitle(staticLogoOpacityAnimation),
                Padding(
                  padding: EdgeInsets.only(top: screenSize.height / 15),
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
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: contentOpacityAnimation,
              child: buildSupportText(),
            ),
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
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Stack(
              children: [
                buildDayflectTitle(staticLogoOpacityAnimation),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 64.0,
                    left: 32.0,
                    right: 32.0,
                  ),
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
              whiteLogoUrl,
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
      buildScreenshots(isMobile: isMobile),
      SizedBox(
        width: screenSize.width < 1050 ? 64 : 240.0,
        height: isMobile ? 24.0 : 0.0,
      ),
      buildDetails(
        width: 400.0,
        isMobile: isMobile,
      ),
    ];
  }

  Widget buildScreenshots({bool isMobile = false}) {
    if (screenSize.width < 1050.0) {
      return Image.asset(
        androidScreenshotUrl,
        height: limitNumber(
          number: screenSize.height * 0.5,
          min: 500,
          max: 800.0,
        ),
      );
    } else {
      return Stack(
        overflow: Overflow.visible,
        children: [
          Positioned(
            child: Image.asset(
              iosScreenshotUrl,
              height: limitNumber(
                number: screenSize.height * 0.5,
                min: 500,
                max: 800.0,
              ),
            ),
          ),
          Positioned(
            left: 150.0,
            bottom: 5.0,
            child: Image.asset(
              androidScreenshotUrl,
              height: limitNumber(
                number: screenSize.height * 0.5,
                min: 500,
                max: 800.0,
              ),
            ),
          ),
        ],
      );
    }
  }

  Container buildDetails({
    @required double width,
    bool isMobile = false,
  }) {
    return Container(
      width: width,
      child: Column(
        mainAxisAlignment:
            isMobile ? MainAxisAlignment.start : MainAxisAlignment.center,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          buildRalewayText(
            text: titleString,
            fontSize: 36.0,
            fontWeight: FontWeight.bold,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 32.0),
          buildRalewayText(
            text: firstDecriptionString,
            fontSize: 18.0,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 16.0),
          buildRalewayText(
            text: secondDescriptionString,
            fontSize: 18.0,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: 32.0),
          Center(child: buildStoreButtons(isMobile: isMobile)),
          if (isMobile)
            Column(
              children: [
                const SizedBox(height: 64.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FadeTransition(
                      opacity: contentOpacityAnimation,
                      child: buildSupportText(),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget buildStoreButtons({bool isMobile = false}) {
    final buttons = [
      buildStoreButton(
        assetUrl: appStoreButtonUrl,
        storeUrl: appStoreUrl,
      ),
      SizedBox(
        height: isMobile ? 16.0 : 0.0,
        width: isMobile ? 0.0 : 16.0,
      ),
      buildStoreButton(
        assetUrl: playStoreButtonUrl,
        storeUrl: playStoreUrl,
      ),
    ];

    if (isMobile) {
      return Column(children: buttons);
    } else {
      return Row(children: buttons);
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

  Text buildRalewayText({
    @required String text,
    @required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    Color fontColor = Colors.white,
    TextAlign textAlign = TextAlign.start,
    double height = 1.5,
  }) {
    return Text(
      text,
      style: GoogleFonts.raleway(
        textStyle: TextStyle(
          color: fontColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: height,
        ),
      ),
      textAlign: textAlign,
    );
  }

  SelectableText buildSupportText() {
    final ralewayText = buildRalewayText(
      text: feedbackString,
      fontSize: 16.0,
      textAlign: TextAlign.center,
      fontColor: Colors.white70,
    );
    return SelectableText(
      ralewayText.data,
      style: ralewayText.style,
      textAlign: ralewayText.textAlign,
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
