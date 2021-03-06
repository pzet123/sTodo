import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:stodo/components/Notifications.dart';
import 'package:stodo/models/Frequency.dart';
import 'package:stodo/screens/AddQuest.dart';
import 'package:stodo/screens/Quests.dart';
import 'package:stodo/screens/System.dart';

import 'models/Quest.dart';
import 'models/QuestTask.dart';

const int NUM_OF_SCREENS = 2;

late SharedPreferences sharedPreferences;
late List<Quest> questList;
Quest? activeQuest;
bool soundOn = true;

// RateMyApp rateMyApp = RateMyApp(
//   preferencesPrefix: "rateMyApp_",
//   minDays: 0,
//   minLaunches: 0,
//   googlePlayIdentifier: "com.app.stodo",
//   appStoreIdentifier: "1625568037"
// );

getQuestList() async {
  if (sharedPreferences.containsKey("quests")) {
    List<dynamic> jsonQuestList =
        json.decode(sharedPreferences.getString("quests")!);
    questList = jsonQuestList.map((quest) => Quest.fromJson(quest)).toList();
  } else {
    questList = [];
  }
  if (sharedPreferences.containsKey("activeQuest") && questList.length > 0) {
    activeQuest = Quest.fromJson(
        json.decode(sharedPreferences.getString("activeQuest")!));
    if (questList.contains(activeQuest)) {
      activeQuest = questList[questList.indexOf(activeQuest!)];
      createQuestTrackingNotification(questName: activeQuest?.getName(), nextTask: activeQuest?.getActiveTask());
    } else {
      activeQuest = null;
    }
  }
}

void resetQuest(Quest quest){
  for(QuestTask task in quest.getTasks()){
    task.setCompleted(false);
  }
  quest.setComplete(false);
  quest.setLastRecurrenceDate(DateTime.now());
}

updateQuests() async {
  for(Quest quest in questList){
    if(quest.isComplete()){
      if(quest.getFrequency() == Frequency.everyday){
        if(quest.getLastRecurrenceDate().isBefore(DateTime.now().subtract(Duration(days: 1)))){
          resetQuest(quest);
        }
      }
      else if(quest.getFrequency() == Frequency.everyNDays){
        if(quest.getLastRecurrenceDate().isBefore(DateTime.now().subtract(Duration(days: quest.getRepeatDays())))){
          resetQuest(quest);
        }
      }
    }
  }
}

void  saveQuestList() async {
  sharedPreferences.setString("quests", json.encode(questList));
}

void saveActiveQuest() async {
  sharedPreferences.setString("activeQuest", json.encode(activeQuest));
}

void removeActiveQuest() async {
  sharedPreferences.remove("activeQuest");
}

initialiseApp() async {
  sharedPreferences = await SharedPreferences.getInstance();
  await initialiseNotifications();
  await getQuestList();
  await updateQuests();
  saveQuestList();
  // rateMyApp.init();
  FlutterNativeSplash.remove();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);
}

void playMenuSound() async {
  if (soundOn) {
    final player = AudioPlayer();
    player.setAsset("assets/menuScroll.mp3", preload: true);
    player.play();
  }
}

void playInvalidInputSound() async {
  if (soundOn) {
    final player = AudioPlayer();
    await player.setVolume(0.5);
    player.setAsset("assets/sneakAttack.mp3", preload: true);
    player.play();
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initialiseApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
    theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black87,
            secondary: Color.fromARGB(255, 240, 240, 240),
            tertiary: Color.fromARGB(255, 140, 140, 140)),
        textTheme: TextTheme(
            headline1: TextStyle(
                fontFamily: "Futura",
                fontSize: 38,
                color: Color.fromARGB(255, 240, 240, 240)),
            headline2: TextStyle(
                fontFamily: "Futura",
                fontSize: 38,
                color: Color.fromARGB(255, 140, 140, 140)),
            headline3: TextStyle(
                fontFamily: "Futura",
                fontSize: 30,
                color: Color.fromARGB(255, 240, 240, 240)),
            headline4: TextStyle(
                fontFamily: "Futura",
                fontSize: 30,
                color: Color.fromARGB(255, 174, 174, 174)),
            headlineLarge: TextStyle(
              fontFamily: "Balgruf",
              fontSize: 40,
              color: Color.fromARGB(255, 240, 240, 240),
            ),
            headline5: TextStyle(
              fontFamily: "Balgruf",
              fontSize: 22,
              color: Color.fromARGB(255, 240, 240, 240),
            ),
            subtitle1: TextStyle(
              fontFamily: "Futura",
              fontSize: 26,
              color: Color.fromARGB(255, 240, 240, 240),
            ),
            subtitle2: TextStyle(
              fontFamily: "Futura",
              fontSize: 24,
              color: Color.fromARGB(255, 240, 240, 240),
            ))),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void changePage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= NUM_OF_SCREENS) {
      playInvalidInputSound();
    } else {
      playMenuSound();
    }
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  AppBar createAppBar() {
    List<String> appBarText = ["QUESTS", "SYSTEM"];

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
              offset: Offset(0, -1),
              child: Image.asset(
                "assets/images/mainQuestBannerL.png",
                color: Colors.white,
                scale: 2.5,
              )),
          Text(appBarText[pageIndex],
              style: Theme.of(context).textTheme.subtitle1),
          Transform.translate(
              offset: Offset(0, -1),
              child: Image.asset(
                "assets/images/mainQuestBannerR.png",
                color: Colors.white,
                scale: 2.5,
              )),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => changePage((pageIndex - 1)),
        icon: Icon(Icons.chevron_left,
            color: Theme.of(context).colorScheme.tertiary),
      ),
      actions: [
        IconButton(
            onPressed: () => changePage((pageIndex + 1)),
            icon: Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.tertiary))
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: createAppBar(),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: ClampingScrollPhysics(),
        children: [
          QuestsScreen(
            questList: questList,
          ),
          // GeneralStats(),
          System(),
        ],
      ),
      floatingActionButton: pageIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddQuestScreen(questList, null)))
                    .then((_) => setState(() {}));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/skyrimLogo.png"),
              ))
          : null,
    );
  }
}
