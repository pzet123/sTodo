import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
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

  _QuestDetailsState({required this.quest});

  void playQuestUpdatedSound() async{
    AudioCache player = AudioCache();
    const String questUpdatedSoundPath = "questUpdate.mp3";
    player.play(questUpdatedSoundPath);
  }

  void playQuestFinishedSound() async{
    AudioCache player = AudioCache();
    const String levelUpSoundPath = "levelUp.mp3";
    player.play(levelUpSoundPath);
  }

  void finishQuest(){
    playQuestFinishedSound();
    setState(() {
      questCompleted = true;
    });
    Timer(Duration(milliseconds: 6500), () {
      questCompleted = false;
      Navigator.pop(context);
    });
  }

  void updateQuest(QuestTask task) async{
    task.toggleCompleted();
    setState(() {
      quest.update();
    });
    if(quest.isComplete()){
      finishQuest();
    } else if(task.isCompleted()){
      playQuestUpdatedSound();
      setState(() {
        questUpdatedOpacity = 1.0;
        hideWidget = false;
      });
      Timer(Duration(seconds: 3), () {
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
        padding: EdgeInsets.symmetric(vertical: 30),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon((task.isCompleted()) ? Icons.brightness_1 : Icons.brightness_1_outlined, color: Theme.of(context).colorScheme.secondary,),
            SizedBox(width: 10,),
            Text(task.getTaskDescription(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary
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
  

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Stack(
      children: [Scaffold(
        appBar: AppBar(
          title: Text(quest.getName(),
          style: TextStyle(
            fontFamily: "Balgruf",
            fontSize: 24,
            color: Theme.of(context).colorScheme.secondary
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.black,
          padding: EdgeInsets.fromLTRB(20, 10, 15, 5),
          child: Stack(
            children: [Column(
              children: [
                Expanded(
                  flex: orientation == Orientation.portrait ? 5 : 3,
                  child: SingleChildScrollView(
                    child: Text(quest.getDescription(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontFamily: "Balgruf",
                      fontSize: 18
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                Text("OBJECTIVES",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Balgruf",
                      fontSize: 24,
                      color: Theme.of(context).colorScheme.secondary
                  ),),
                Expanded(
                  flex: 5,
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
            child: Center(child: Text("Quest Completed", style: Theme.of(context).textTheme.headlineLarge,)),
          ),
        ),
      )
    ]
    );
  }
}
