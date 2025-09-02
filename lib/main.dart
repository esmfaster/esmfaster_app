import 'dart:async';
import 'dart:io';
import 'package:app/src/app.dart';
import 'package:app/src/config.dart';
import 'package:app/src/models/app_state_model.dart';
import 'package:app/src/resources/api_provider.dart';
import 'package:app/src/ui/blocks/zoom_drawer.dart';
import 'package:app/src/ui/blocks/products/wishlist_icon.dart';
import 'package:app/src/ui/checkout/cart/shopping_cart.dart';
import 'package:app/src/ui/intro/intro_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';

void setOverrideForDesktop() {
  if (kIsWeb) return;
  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  } else if (Platform.isFuchsia) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() async {
  setOverrideForDesktop();
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  final model = AppStateModel();
  await model.getLocalData();
  await model.getStoredBlocks();

  runApp(MyApp(model: model));
}

class MyApp extends StatelessWidget {
  final AppStateModel model;

  MyApp({Key? key, required this.model}) : super(key: key);

  //final _messangerKey = GlobalKey<ScaffoldMessengerState>();


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ShoppingCart>(create: (_) => ShoppingCart()),
        ChangeNotifierProvider<Favourites>(create: (_) => Favourites()),
      ],
      child: ScopedModel<AppStateModel>(
        model: model,
        child: ScopedModelDescendant<AppStateModel>(
            builder: (context, child, model) {
            return MaterialApp(
              //scaffoldMessengerKey: _messangerKey,
              title: Config().appName,
              debugShowCheckedModeBanner: false,
              theme: model.blocks.blockTheme.light,
              darkTheme: model.blocks.blockTheme.dark,
              themeMode: model.themeMode,
              home: AppStartScreen(model: model),
              localizationsDelegates: [
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: supportedLocales,
            );
          }
        ),
      ),
    );
  }
}

class AppStartScreen extends StatefulWidget {
  final AppStateModel model;
  AppStartScreen({Key? key, required this.model}) : super(key: key);

  @override
  _AppStartScreenState createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  final apiProvider = ApiProvider();
  late Timer _timer;
  int _start = 0;
  //final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    apiProviderInit();
    _start = widget.model.blocks.settings.splashDuration;
    startTimer();

    //widget.model.messageStream.listen((event) => _manageMessage(event));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return Builder(
      builder: (context) {
        if ((widget.model.blocks.blocks.isNotEmpty || widget.model.blocks.recentProducts.isNotEmpty) && _start == 0) {
          FlutterNativeSplash.remove();
          return IntroOrAppScreen(model: widget.model);
        } else {
          return SplashScreen();
        }
      },
    );
  }

  void apiProviderInit() async {
    await apiProvider.init();
    await widget.model.getStoredBlocks();
    await widget.model.updateAllBlocks();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            cancelTimer();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void cancelTimer() {
    _timer.cancel();
    setState(() {
      _start = 0;
    });
  }

 /* _manageMessage(SnackBarActivity event) {
    if (event.show && widget.messangerKey.currentState != null) {
      final snackBar = SnackBar(
        duration: event.duration,
        backgroundColor: event.success ? Colors.green : Colors.red,
        content: Wrap(
          children: [
            Container(
              child: Text(
                parseHtmlString(event.message),
                maxLines: 6,
                style: TextStyle(color: Colors.white),
              ),
            ),
            event.loading
                ? Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
              child: Container(
                height: 20,
                width: 20,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
                : Container(),
          ],
        ),
      );
      widget.messangerKey.currentState!.showSnackBar(snackBar);
    } else {
      widget.messangerKey.currentState!.hideCurrentSnackBar();
    }
  }*/
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white, appBarTheme: AppBarTheme(elevation: 0)),
      darkTheme: ThemeData(primaryColor: Colors.white, appBarTheme: AppBarTheme(elevation: 0)),
      home: Material(
        child: Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Center(
              child: Container(
                child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IntroOrAppScreen extends StatelessWidget {
  final AppStateModel model;

  const IntroOrAppScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return model.hasSeenIntro == false && model.blocks.settings.showIntro == true
        ? IntroScreen(
      onFinish: () {
        model.setIntroScreenSeen();
        model.hasSeenIntro = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MyApp(model: model)));
      },
      model: model,
    )
        : model.blocks.settings.zoomDrawer
        ? ZoomDrawerPage()
        : App();
  }
}

/// A list of this localizations delegate's supported locales.
const List<Locale> supportedLocales = <Locale>[
  Locale('en'),
  Locale('af'),
  Locale('am'),
  Locale('ar'),
  Locale('ar', 'EG'),
  Locale('ar', 'JO'),
  Locale('ar', 'MA'),
  Locale('ar', 'SA'),
  Locale('as'),
  Locale('az'),
  Locale('be'),
  Locale('bg'),
  Locale('bn'),
  Locale('bs'),
  Locale('ca'),
  Locale('cs'),
  Locale('da'),
  Locale('de'),
  Locale('de', 'AT'),
  Locale('de', 'CH'),
  Locale('el'),
  Locale('en', 'AU'),
  Locale('en', 'CA'),
  Locale('en', 'GB'),
  Locale('en', 'IE'),
  Locale('en', 'IN'),
  Locale('en', 'NZ'),
  Locale('en', 'SG'),
  Locale('en', 'ZA'),
  Locale('es'),
  Locale('es', '419'),
  Locale('es', 'AR'),
  Locale('es', 'BO'),
  Locale('es', 'CL'),
  Locale('es', 'CO'),
  Locale('es', 'CR'),
  Locale('es', 'DO'),
  Locale('es', 'EC'),
  Locale('es', 'GT'),
  Locale('es', 'HN'),
  Locale('es', 'MX'),
  Locale('es', 'NI'),
  Locale('es', 'PA'),
  Locale('es', 'PE'),
  Locale('es', 'PR'),
  Locale('es', 'PY'),
  Locale('es', 'SV'),
  Locale('es', 'US'),
  Locale('es', 'UY'),
  Locale('es', 'VE'),
  Locale('et'),
  Locale('eu'),
  Locale('fa'),
  Locale('fi'),
  Locale('fil'),
  Locale('fr'),
  Locale('fr', 'CA'),
  Locale('fr', 'CH'),
  Locale('gl'),
  Locale('gsw'),
  Locale('gu'),
  Locale('he', 'IL'),
  Locale('he'),
  Locale('hi'),
  Locale('hr'),
  Locale('hu'),
  Locale('hy'),
  Locale('id'),
  Locale('is'),
  Locale('it'),
  Locale('ja'),
  Locale('ka'),
  Locale('kk'),
  Locale('km'),
  Locale('kn'),
  Locale('ko'),
  Locale('ky'),
  Locale('lo'),
  Locale('lt'),
  Locale('lv'),
  Locale('mk'),
  Locale('ml'),
  Locale('mn'),
  Locale('mr'),
  Locale('ms'),
  Locale('my'),
  Locale('nb'),
  Locale('ne'),
  Locale('nl'),
  Locale('or'),
  Locale('pa'),
  Locale('pl'),
  Locale('pt'),
  Locale('pt', 'BR'),
  Locale('pt', 'PT'),
  Locale('ro'),
  Locale('ru'),
  Locale('si'),
  Locale('sk'),
  Locale('sl'),
  Locale('sq'),
  Locale('sr'),
  Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
  Locale('sv'),
  Locale('sw'),
  Locale('ta'),
  Locale('te'),
  Locale('th'),
  Locale('tl'),
  Locale('tr'),
  Locale('uk'),
  Locale('ur'),
  Locale('uz'),
  Locale('vi'),
  Locale('zh'),
  Locale('zh', 'CN'),
  Locale('zh', 'HK'),
  Locale('zh', 'TW'),
  Locale('zu')
];
