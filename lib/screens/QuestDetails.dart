import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stodo/main.dart';
import 'package:stodo/models/QuestTask.dart';

import '../models/Quest.dart';

class QuestDetails extends StatefulWidget {
  Quest quest;

  QuestDetails({required this.quest});

  @override
  _QuestDetailsState createState() => _QuestDetailsState(quest: quest);
}

class _QuestDetailsState extends State<QuestDetails> {
  Quest quest;
  double questUpdatedOpacity = 0.0;
  bool hideWidget = true;
  bool questCompleted = false;
  final ScrollController TaskListController = ScrollController();

  Timer _questCompletedDialogTimer = Timer(Duration(seconds: 0), () {});
  Timer _questUpdatedDialogTimer = Timer(Duration(seconds: 0), () {});

  _QuestDetailsState({required this.quest});

  @override
  void dispose(){
    _questCompletedDialogTimer.cancel();
    _questUpdatedDialogTimer.cancel();
    super.dispose();
  }

  void playQuestUpdatedSound() async{
    if(soundOn) {
      AudioCache player = AudioCache();
      const String questUpdatedSoundPath = "questUpdate.mp3";
      player.play(questUpdatedSoundPath);
    }
  }

  void playQuestFinishedSound() async{
    if(soundOn) {
      AudioCache player = AudioCache();
      const String levelUpSoundPath = "levelUp.mp3";
      player.play(levelUpSoundPath);
    }
  }

  void playQuestDeletedSound() async{
    if(soundOn) {
      AudioCache player = AudioCache();
      const String levelUpSoundPath = "itemDestroy.mp3";
      player.play(levelUpSoundPath);
    }
  }

  void deleteQuest() async{
    questList.remove(quest);
    saveQuestList();
    playQuestDeletedSound();
    Navigator.pop(context);
  }

  void finishQuest(){
    playQuestFinishedSound();
    setState(() {
      questCompleted = true;
    });
    _questCompletedDialogTimer = Timer(Duration(milliseconds: 6500), () {
    Navigator.pop(context);
    });
  }

  void updateQuest(QuestTask task) async{
    task.toggleCompleted();
    setState(() {
      quest.update();
      saveQuestList();
    });
    if(quest.isComplete()){
      finishQuest();
    } else if(task.isCompleted()){
      playQuestUpdatedSound();
      setState(() {
        questUpdatedOpacity = 1.0;
        hideWidget = false;
      });
      _questUpdatedDialogTimer = Timer(Duration(milliseconds: 2500), () {
        setState(() {
          questUpdatedOpacity = 0.0;
        });
      });
    }
  }

  String getNextTask(){
    for(QuestTask task in quest.getTasks()){
      if(!task.isCompleted()){
        return task.getTaskDescription();
      }
    }
    return "";
  }

  Widget getTaskTile(QuestTask task){
    return GestureDetector(
      onTap: () => updateQuest(task),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 20, 20, 20),
          borderRadius: BorderRadius.circular(20)
        ),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Image.asset((task.isCompleted()) ? "assets/images/taskComplete.png" : "assets/images/taskIncomplete.png", scale: 2,),
            SizedBox(width: 10,),
            Expanded(
              child: Text(task.getTaskDescription(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  List<Widget> getQuestTaskTiles() {
    List<Widget> questTaskTiles = [];
    for(QuestTask task in quest.getTasks()){
      questTaskTiles.add(getTaskTile(task));
    }
    return questTaskTiles;
  }

  Widget getObjectivesText() {
    return Stack(
      children: [
        Transform.translate(
            offset: Offset(-83, 7),
            child: Image.asset("assets/images/miscQuestBannerL.png", color: Colors.white, scale: 2.2,)
        ),
        Text("OBJECTIVES",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,),
        Transform.translate(
            offset: Offset(137, 7),
            child: Image.asset("assets/images/miscQuestBannerR.png", color: Colors.white, scale: 2.2))
    ]
    );
  }
  

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Stack(
      children: [Scaffold(
        appBar: AppBar(
          title: Text(quest.getName(),
          style: Theme.of(context).textTheme.headline3
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => deleteQuest(),
                icon: Icon(Icons.close_sharp, color: Theme.of(context).colorScheme.secondary,))
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
          color: Colors.black,
          child: Stack(
            children: [Column(
              children: [
                Expanded(
                  flex: quest.getDescription().isEmpty ? 0 : (orientation == Orientation.portrait ? 7 : 6),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(quest.getDescription(),
                        style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
                    isAlwaysShown: true,
                  ),
                ),
                SizedBox(height: 12,),
                getObjectivesText(),
                Expanded(
                  flex: 10,
                  child: Scrollbar(
                    controller: TaskListController,
                    isAlwaysShown: true,
                    child: ListView(
                      controller: TaskListController,
                      children: getQuestTaskTiles(),
                    ),
                  ),
                ),
              ],
            ),
              AnimatedOpacity(
                curve: Curves.decelerate,
                opacity: questUpdatedOpacity,
                duration: Duration(seconds: 1),
                onEnd: () => setState(() {
                  if(questUpdatedOpacity == 0.0) {
                    hideWidget = true;
                  }
                }),
                child: Transform.translate(
                  offset: hideWidget ? Offset(-5000, -5000) : Offset(0, 0),
                  child: Container(
                    color: Colors.black,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Quest Updated", style: Theme.of(context).textTheme.headlineLarge,),
                        Text("Next Task: ${getNextTask()}", style: Theme.of(context).textTheme.subtitle1,),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
      AnimatedOpacity(
        opacity: questCompleted ? 1.0 : 0.0,
        duration: Duration(milliseconds: 1500),
        curve: Curves.decelerate,
        child: Transform.translate(
          offset: questCompleted ? Offset(0, 0) : Offset(-5000, -5000),
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: AnimatedScale(
                scale: questCompleted ? 1.0 : 0.5,
                curve: Curves.decelerate,
                duration: Duration(seconds: 2),
                child: Center(
                  child: Text("Quest Completed", style: Theme.of(context).textTheme.headlineLarge,)
              )
            ),
          ),
        ),
      )
    ]
    );
  }
}
