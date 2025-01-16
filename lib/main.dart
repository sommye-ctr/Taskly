import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskly/providers/tags_provider.dart';
import 'package:taskly/providers/theme_provider.dart';
import 'package:taskly/screens/home_screen.dart';
import 'package:taskly/screens/intro_screen.dart';
import 'package:taskly/screens/splash_screen.dart';
import 'package:taskly/service/local_db_service.dart';
import 'package:taskly/service/speech_service.dart';
import 'package:taskly/storage/tags_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool first = await LocalDbService.getFirstTime();
  runApp(TasklyApp(
    isFirstTime: first,
  ));
}

class TasklyApp extends StatefulWidget {
  final bool isFirstTime;
  const TasklyApp({
    super.key,
    required this.isFirstTime,
  });

  @override
  State<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends State<TasklyApp> {
  late ThemeProvider themeProvider;
  TagsProvider tagsProvider = TagsProvider();

  @override
  void initState() {
    super.initState();
    themeProvider = ThemeProvider();
    SpeechService.intialize();
    _loadTags();
  }

  void _loadTags() async {
    tagsProvider.updateTags(await TagsStorage.loadTags());
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => tagsProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Taskly',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Quicksand',
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Quicksand',
            ),
          ),
          themeMode: value.darkTheme ? ThemeMode.dark : ThemeMode.light,
          // home: widget.isFirstTime ? const IntroScreen() : const HomeScreen(),
          initialRoute: '/',
          routes: {
            '/': (context) =>
                SplashScreen(), // Add Splash Screen as the initial route
            '/main': (context) =>
                widget.isFirstTime ? const IntroScreen() : const HomeScreen(),
          },
        ),
      ),
    );
  }
}
