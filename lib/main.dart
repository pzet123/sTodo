import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stodo/models/QuestTask.dart';
import 'package:stodo/screens/AddQuest.dart';
import 'package:stodo/screens/GeneralStats.dart';
import 'package:stodo/screens/Quests.dart';
import 'package:stodo/screens/System.dart';

import 'models/Quest.dart';

const int NUM_OF_SCREENS = 2;

late SharedPreferences sharedPreferences;
late List<Quest> questList;
bool soundOn = true;

getQuestList() async{
  if(sharedPreferences.containsKey("quests")){
    List<dynamic> jsonQuestList = json.decode(sharedPreferences.getString("quests")!);
    questList = jsonQuestList.map((quest) => Quest.fromJson(quest)).toList();
  } else {
    questList = [];
  }
}

saveQuestList() async{
  sharedPreferences.setString("quests", json.encode(questList));
}

initialiseApp() async{
  sharedPreferences = await SharedPreferences.getInstance();
  getQuestList();
  FlutterNativeSplash.remove();
}

void playMenuSound() async{
  if(soundOn) {
    AudioCache player = AudioCache();
    const String menuScrollSoundPath = "menuScroll.mp3";
    player.play(menuScrollSoundPath);
  }
}

void playInvalidInputSound() async{
  if(soundOn) {
    AudioCache player = AudioCache();
    const String sneakAttackSoundPath = "sneakAttack.mp3";
    player.play(sneakAttackSoundPath);
  }
}

void main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await initialiseApp();
  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.black87,
        secondary: Color.fromARGB(255, 240, 240, 240),
        tertiary: Color.fromARGB(255, 140, 140, 140)
      ),
      textTheme: TextTheme(
        headline1: TextStyle(
          fontFamily: "Futura",
          fontSize: 38,
          color: Color.fromARGB(255, 240, 240, 240)
        ),
        headline2: TextStyle(
            fontFamily: "Futura",
            fontSize: 38,
            color: Color.fromARGB(255, 140, 140, 140)
        ),
        headline3: TextStyle(
            fontFamily: "Futura",
            fontSize: 30,
            color: Color.fromARGB(255, 240, 240, 240)
        ),
        headline4: TextStyle(
            fontFamily: "Futura",
            fontSize: 30,
            color: Color.fromARGB(255, 174, 174, 174)
        ),
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
          )
      )
    ),
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
    pageController = PageController();
  }

  void changePage(int pageIndex) {
    if(pageIndex < 0 || pageIndex >= NUM_OF_SCREENS){
      playInvalidInputSound();
    }
    else {
      playMenuSound();
    }
    pageController.animateToPage(
        pageIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.decelerate);
  }

  void onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  AppBar createAppBar(){

    List<String> appBarText = ["QUESTS", "SYSTEM"];

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
              offset: Offset(0, -1),
              child: Image.asset("assets/images/mainQuestBannerL.png", color: Colors.white, scale: 2.5,)),
          Text(appBarText[pageIndex],
              style: Theme.of(context).textTheme.subtitle1
          ),
          Transform.translate(
              offset: Offset(0, -1),
              child: Image.asset("assets/images/mainQuestBannerR.png", color: Colors.white, scale: 2.5,)),
        ],
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => changePage((pageIndex - 1) ),
        icon: Icon(Icons.chevron_left,
            color: Theme.of(context).colorScheme.tertiary),
      ),
      actions: [IconButton(
          onPressed: () => changePage((pageIndex + 1) ),
          icon: Icon(Icons.chevron_right,
          color: Theme.of(context).colorScheme.tertiary)
      )],
    );
  }



  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: createAppBar(),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: [
          QuestsScreen(questList: questList,),
          // GeneralStats(),
          System(),
        ],
      ),
      floatingActionButton: pageIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddQuestScreen(questList))).then((_) => setState(() {}));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/skyrimLogo.png"),
        )
      ) : null,
    );
  }

}
