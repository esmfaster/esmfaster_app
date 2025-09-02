import 'package:flex_color_scheme/src/flex_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';

class IntroScreen1 extends StatefulWidget {
  final Function onFinish;
  const IntroScreen1({Key? key, required this.onFinish}) : super(key: key);

  @override
  IntroScreen1State createState() => IntroScreen1State();
}

class IntroScreen1State extends State<IntroScreen1> {
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() {
    // Trigger your completion logic
    widget.onFinish();
  }

  // Example for customizing a button style
  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0x33ffcc5c)),
      overlayColor: WidgetStateProperty.all<Color>(const Color(0x33ffcc5c)),
    );
  }

  // Render icons for navigation
  Widget renderNextBtn() => Icon(Icons.navigate_next, size: 25, color: Theme.of(context).colorScheme.onPrimary,);
  Widget renderPrevBtn() => Icon(Icons.navigate_before, size: 25, color: Theme.of(context).colorScheme.onPrimary,);
  Widget renderDoneBtn() => Icon(Icons.done, size: 25, color: Theme.of(context).colorScheme.onPrimary,);
  Widget renderSkipBtn() => Icon(Icons.skip_next, size: 25, color: Theme.of(context).colorScheme.onPrimary,);

  @override
  Widget build(BuildContext context) {
    // Define color variables for the indicator
    final Color activeColor = Theme.of(context).colorScheme.onPrimary;
    final Color inactiveColor =
    Theme.of(context).colorScheme.onPrimary.withOpacity(0.5);
    final double sizeIndicator = 20;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).colorScheme.primary.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: IntroSlider(
        indicatorConfig: IndicatorConfig(
          sizeIndicator: sizeIndicator,
          indicatorWidget: Container(
            width: sizeIndicator,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: inactiveColor,
            ),
          ),
          activeIndicatorWidget: Container(
            width: sizeIndicator,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: activeColor,
            ),
          ),
          spaceBetweenIndicator: 10,
          typeIndicatorAnimation: TypeIndicatorAnimation.sliding,
        ),

        // Navigation button renders
        renderNextBtn: renderNextBtn(),
        renderPrevBtn: renderPrevBtn(),
        renderSkipBtn: renderSkipBtn(),

        // Button styles
        doneButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        nextButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        skipButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        prevButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primary,
          ),
          foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),

        // Slide content
        listContentConfig: [
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Seamless Shopping Experience",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
            description:
            "Explore endless products at your fingertips, from anywhere, anytime. Enjoy a hassle-free shopping experience with instant access to all your favorite brands.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20.0,
              fontFamily: 'Raleway',
            ),
            pathImage: "assets/images/intro/intro1.png",
            maxLineTextDescription: 8,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Unbeatable Deals & Discounts",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
            description:
            "Save more on every purchase with our exclusive offers and promotions. Shop now and take advantage of great bargains every day.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20.0,
              fontFamily: 'Raleway',
            ),
            pathImage: "assets/images/intro/intro2.png",
            maxLineTextDescription: 8,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Fast & Secure Checkout",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
            description:
            "Complete your purchase with confidence. Our secure payment options and quick checkout ensure a worry-free transaction every time.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20.0,
              fontFamily: 'Raleway',
            ),
            pathImage: "assets/images/intro/intro3.png",
            maxLineTextDescription: 8,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Speedy Delivery & Easy Returns",
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoMono',
            ),
            description:
            "Get your orders delivered to your doorstep in record time, and enjoy a hassle-free return policy for total peace of mind.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 20.0,
              fontFamily: 'Raleway',
            ),
            pathImage: "assets/images/intro/intro4.png",
            maxLineTextDescription: 8,
          ),
        ],

        // Triggered when user taps the Done button
        onDonePress: onDonePress,
      ),
    );
  }
}
