import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stodo/models/QuestTask.dart';

import '../main.dart';
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
  bool _hideWidget = true;
  bool _questTitleValid = true;

  late Timer questAddedTimer = Timer(Duration(seconds: 0), () {});
  late Timer questAddedTimer2 = Timer(Duration(seconds: 0), () {});

  List<QuestTask> newTasks = [];

  @override
  void dispose(){
    questAddedTimer.cancel();
    questAddedTimer2.cancel();
    super.dispose();
  }

  List<Widget> getNewTasks() {
    List<Widget> newTaskWidgets = [];
    newTasks.forEach((task) {
      newTaskWidgets.add(Dismissible(
        direction: DismissDirection.startToEnd,
        key: UniqueKey(),
        onDismissed: (direction) {
          setState(() {
            newTasks.remove(task);
          });
        },
        child: ListTile(
          title: Text(task.getTaskDescription(),
            style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center,),
        ),
      ));
    });
    return newTaskWidgets;
  }

  playNewQuestSound() async{
    if(soundOn) {
      AudioCache player = AudioCache();
      const String newQuestSoundPath = "newQuest.mp3";
      player.play(newQuestSoundPath);
    }
  }

  bool questValid(){
    setState(() {
      _questTitleValid = questTitleController.text.trim().isNotEmpty;
    });
    if(newTasks.length > 0){
      return _questTitleValid;
    } else {
      SnackBar snackbar = const SnackBar(content: Text("You must include at least one task"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }
  }

  void addQuest() async{
    if(questValid()){
      Quest newQuest = Quest(questTitleController.text, questDescriptionController.text, newTasks, false);
      widget.questList.add(newQuest);
      saveQuestList();
      playNewQuestSound();
      setState(() {
        questAddedTextOpacity = 1.0;
        _hideWidget = false;
      });
      questAddedTimer = Timer(Duration(seconds: 1), () {
        questTitleController.clear();
        questDescriptionController.clear();
        newTaskController.clear();
        newTasks = [];
      });
      questAddedTimer2 = Timer(Duration(seconds: 3), () {
        setState(() {
          questAddedTextOpacity = 0.0;
        });
      });
    } else {
      playInvalidInputSound();
    }
  }


  void addTask(){
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
          title: Text("Add a Task"),
          content: TextField(controller: newTaskController,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.black),),
          actions: [
            ElevatedButton(
                onPressed: () => setState(() {
                  if(newTaskController.text.trim().isNotEmpty) {
                    newTasks.add(QuestTask(newTaskController.text, false));
                    newTaskController.clear();
                  } else {
                    SnackBar emptyTaskSnackBar = SnackBar(content: Text("Tasks cannot be empty"));
                    ScaffoldMessenger.of(context).showSnackBar(emptyTaskSnackBar);
                    playInvalidInputSound();
                  }
                  Navigator.pop(context);
                }),
                child: Icon(Icons.add, color: Theme.of(context).colorScheme.secondary,))
          ],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Start a New Quest", style: Theme.of(context).textTheme.headline3,),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  maxLength: 25,
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    errorText: _questTitleValid ? null : "Quest title cannot be empty",
                    hintText: "Enter Quest Name",
                    hintStyle: Theme.of(context).textTheme.subtitle1,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                    ),
                    labelText: "Quest Name",
                    labelStyle: Theme.of(context).textTheme.subtitle1
                  ),
                  controller: questTitleController,
                  style: Theme.of(context).textTheme.subtitle1
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  cursorColor: Colors.white,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Enter Quest Description",
                    hintStyle: Theme.of(context).textTheme.subtitle1,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary)
                      ),
                    labelText: "Quest Description",
                    labelStyle: Theme.of(context).textTheme.subtitle1
                  ),
                  controller: questDescriptionController,
                  style: Theme.of(context).textTheme.subtitle1
                ),
              ),
              Text("Tasks",
                style: Theme.of(context).textTheme.headline1
              ),
              ElevatedButton(
                  onPressed: addTask,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
                  ),
                  child: Text("Add a new task", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black),)),
              Expanded(
                child: ListView(
                  children: getNewTasks(),
                ),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 2 - 40, vertical: 10)),
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
                  ),
                  onPressed: addQuest,
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary,))
            ],
          ),
            AnimatedOpacity(
            curve: Curves.decelerate,
            opacity: questAddedTextOpacity,
            duration: Duration(seconds: 1),
            onEnd: () => setState(() {
              if(questAddedTextOpacity == 0.0) {
                _hideWidget = true;
              }
            }),
            child: Transform.translate(
              offset: _hideWidget ? Offset(-5000, -5000) : Offset(0, 0),
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
