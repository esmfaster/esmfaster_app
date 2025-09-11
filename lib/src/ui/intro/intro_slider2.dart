import 'package:flex_color_scheme/src/flex_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/intro_slider.dart';

class IntroScreen2 extends StatefulWidget {
  final Function onFinish;
  const IntroScreen2({Key? key, required this.onFinish})
      : super(key: key);

  @override
  IntroScreen2State createState() => IntroScreen2State();
}

class IntroScreen2State extends State<IntroScreen2> {
  @override
  void initState() {
    super.initState();
  }

  void onDonePress() {
    // Trigger your completion logic
    widget.onFinish();
  }

  // You can still customize your button style, or use default.
  ButtonStyle myButtonStyle() {
    return ButtonStyle(
      shape: WidgetStateProperty.all<OutlinedBorder>(const StadiumBorder()),
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0x338BC34A)),
      overlayColor: WidgetStateProperty.all<Color>(const Color(0x338BC34A)),
    );
  }

  // Render icons with different choices
  Widget renderNextBtn() => Icon(
    Icons.arrow_forward,
    size: 25,
    color: Theme.of(context).colorScheme.onPrimary,
  );
  Widget renderPrevBtn() => Icon(
    Icons.arrow_back,
    size: 25,
    color: Theme.of(context).colorScheme.onPrimary,
  );
  Widget renderDoneBtn() => Icon(
    Icons.check_circle,
    size: 25,
    color: Theme.of(context).colorScheme.onPrimary,
  );
  Widget renderSkipBtn() => Icon(
    Icons.skip_next,
    size: 25,
    color: Theme.of(context).colorScheme.onPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.onPrimary;
    final Color inactiveColor =
    Theme.of(context).colorScheme.onPrimary.withOpacity(0.5);
    const double sizeIndicator = 20;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).colorScheme.primary.isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: IntroSlider(
        // Configure the indicator appearance
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
          typeIndicatorAnimation: TypeIndicatorAnimation.sizeTransition,
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

        // Define all slides here
        listContentConfig: [
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Discover Unique Products",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
            description:
            "Browse thousands of exclusive items. From the trendiest gadgets to the latest fashion—find it all in one place.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
            ),
            pathImage: "assets/images/intro/intro1.png",
            maxLineTextDescription: 6,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Special Offers Everyday",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
            description:
            "Never miss out on the best deals again! Enjoy daily discounts and promotional bundles for unbeatable savings.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
            ),
            pathImage: "assets/images/intro/intro2.png",
            maxLineTextDescription: 6,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Simple & Secure Payments",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
            description:
            "Check out with just a few taps. Our robust security measures ensure your data is always protected.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
            ),
            pathImage: "assets/images/intro/intro3.png",
            maxLineTextDescription: 6,
          ),
          ContentConfig(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: "Lightning-Fast Delivery",
            maxLineTitle: 2,
            styleTitle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
            description:
            "Receive your orders quickly and reliably. Enjoy easy returns and dedicated customer support whenever you need it.",
            styleDescription: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18.0,
              fontFamily: 'Montserrat',
            ),
            pathImage: "assets/images/intro/intro4.png",
            maxLineTextDescription: 6,
          ),
        ],

        // Triggered when user taps the Done button
        onDonePress: onDonePress,
      ),
    );
  }
}
