import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stodo/models/QuestTask.dart';

import '../models/Quest.dart';

class AddQuestScreen extends StatefulWidget {
  List<Quest> questList;

  AddQuestScreen(this.questList);

  @override
  _AddQuestScreenState createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  TextEditingController questTitleController = TextEditingController();
  TextEditingController questDescriptionController = TextEditingController();
  TextEditingController newTaskController = TextEditingController();
  double questAddedTextOpacity = 0.0;
  bool hideWidget = true;

  List<QuestTask> newTasks = [];

  List<Widget> getNewTasks(){
    List<Widget> newTaskWidgets = [];
    newTasks.forEach((task){
      newTaskWidgets.add(Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text(task.getTaskDescription(), style: Theme.of(context).textTheme.headline3,),
      ));
    });
    return newTaskWidgets;
  }

  playNewQuestSound() async{
    AudioCache player = AudioCache();
    const String newQuestSoundPath = "newQuest.mp3";
    player.play(newQuestSoundPath);
  }


  void addQuest() async{
    playNewQuestSound();
    setState(() {
      questAddedTextOpacity = 1.0;
      hideWidget = false;
    });
    Timer(Duration(seconds: 1), () {
      Quest newQuest = Quest(questTitleController.text, questDescriptionController.text, newTasks, false);
      widget.questList.add(newQuest);
      questTitleController.clear();
      questDescriptionController.clear();
      newTaskController.clear();
      newTasks = [];
    });
    Timer(Duration(seconds: 3), () {
      setState(() {
        questAddedTextOpacity = 0.0;
      });
    });
  }

  void addTask(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Add a Task"),
        content: TextField(controller: newTaskController),
        actions: [
          ElevatedButton(
              onPressed: () => setState(() {
                newTasks.add(QuestTask(newTaskController.text, false));
                newTaskController.clear();
                Navigator.pop(context);
              }),
              child: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.secondary,))
        ],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start a New Quest", style: Theme.of(context).textTheme.headline3,),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [Column(
            children: [
              TextField(
                cursorColor: Colors.white,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter Quest Name",
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  labelText: "Quest Name",
                  labelStyle: Theme.of(context).textTheme.subtitle1
                ),
                controller: questTitleController,
                style: Theme.of(context).textTheme.subtitle1
              ),
              TextField(
                cursorColor: Colors.white,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter Quest Description",
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  labelText: "Quest Description",
                  labelStyle: Theme.of(context).textTheme.subtitle1
                ),
                controller: questDescriptionController,
                style: Theme.of(context).textTheme.subtitle1
              ),
              Text("Tasks",
                style: Theme.of(context).textTheme.headline1
              ),
              ElevatedButton(
                  onPressed: addTask,
                  child: Text("Add a new task", style: Theme.of(context).textTheme.headline3,)),
              Expanded(
                child: ListView(
                  children: getNewTasks(),
                ),
              ),
              ElevatedButton(
                  onPressed: addQuest,
                  child: Icon(Icons.add, color: Colors.white,))
            ],
          ),
            AnimatedOpacity(
            curve: Curves.decelerate,
            opacity: questAddedTextOpacity,
            duration: Duration(seconds: 1),
            onEnd: () => setState(() {
              if(questAddedTextOpacity == 0.0) {
                hideWidget = true;
              }
            }),
            child: Transform.translate(
              offset: hideWidget ? Offset(-5000, -5000) : Offset(0, 0),
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(child: Text("Quest Added", style: Theme.of(context).textTheme.headlineLarge,)),
              ),
            ),
          )
        ]
        ),
      ),
    );
  }
}
