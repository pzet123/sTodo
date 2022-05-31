import 'dart:async';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:stodo/main.dart';
import 'package:stodo/models/QuestTask.dart';
import 'package:stodo/screens/AddQuest.dart';

import '../components/Notifications.dart';
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
  void dispose() {
    _questCompletedDialogTimer.cancel();
    _questUpdatedDialogTimer.cancel();
    super.dispose();
  }

  void playQuestUpdatedSound() async {
    if (soundOn) {
      final player = AudioPlayer();
      player.setAsset("assets/questUpdate.mp3", preload: true);
      player.play();
    }
  }

  void playQuestFinishedSound() async {
    if (soundOn) {
      final player = AudioPlayer();
      player.setAsset("assets/levelUp.mp3", preload: true);
      player.play();
    }
  }

  void playQuestDeletedSound() async {
    if (soundOn) {
      final player = AudioPlayer();
      player.setAsset("assets/itemDestroy.mp3", preload: true);
      player.play();
    }
  }

  void deleteQuest() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure you want to delete this quest?", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black)),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    questList.remove(quest);
                    saveQuestList();
                    playQuestDeletedSound();
                    removeActiveQuest();
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  },
                  child: Text("Yes", style: Theme.of(context).textTheme.subtitle1)),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No", style: Theme.of(context).textTheme.subtitle1)),
            ],
          );
        });
  }

  void finishQuest() {
    playQuestFinishedSound();
    setState(() {
      questCompleted = true;
    });
    removeActiveQuest();
    _questCompletedDialogTimer = Timer(Duration(milliseconds: 6500), () {
      Navigator.pop(context);
    });
  }

  void updateQuest(QuestTask task) async {
    task.toggleCompleted();
    setState(() {
      quest.update();
      if (quest.isComplete() && quest.isActive()) quest.toggleActive();
      saveQuestList();
    });
    if (quest.isComplete()) {
      finishQuest();
    } else if (task.isCompleted()) {
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

  String getNextTask() {
    for (QuestTask task in quest.getTasks()) {
      if (!task.isCompleted()) {
        return task.getTaskDescription();
      }
    }
    return "";
  }

  Widget getTaskTile(QuestTask task) {
    return GestureDetector(
      onTap: () => updateQuest(task),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 20, 20, 20),
            borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Image.asset(
              (task.isCompleted())
                  ? "assets/images/taskComplete.png"
                  : "assets/images/taskIncomplete.png",
              scale: 2,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                task.getTaskDescription(),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getQuestTaskTiles() {
    List<Widget> questTaskTiles = [];
    for (QuestTask task in quest.getTasks()) {
      questTaskTiles.add(getTaskTile(task));
    }
    return questTaskTiles;
  }

  Widget getObjectivesText() {
    return Stack(children: [
      Transform.translate(
          offset: Offset(-83, 7),
          child: Image.asset(
            "assets/images/miscQuestBannerL.png",
            color: Colors.white,
            scale: 2.2,
          )),
      Text(
        "OBJECTIVES",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline5,
      ),
      Transform.translate(
          offset: Offset(137, 7),
          child: Image.asset("assets/images/miscQuestBannerR.png",
              color: Colors.white, scale: 2.2))
    ]);
  }

  void editQuest() {
    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => AddQuestScreen(questList, quest))).then((_) => setState(() {}));
  }

  void makeActiveQuest() {
    setState(() {
      activeQuest = quest;
      quest.toggleActive();
      for (Quest diffQuest in questList) {
        if (diffQuest != quest) diffQuest.setActive(false);
      }
      saveQuestList();
      saveActiveQuest();
    });
    createQuestTrackingNotification(
        questName: quest.getName(), nextTask: quest.getActiveTask());
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          title: Text(quest.getName(),
              style: Theme.of(context).textTheme.headline3),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => deleteQuest(),
                icon: Icon(
                  Icons.close_sharp,
                  color: Theme.of(context).colorScheme.secondary,
                ))
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
          color: Colors.black,
          child: Stack(children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.secondary),
                          ),
                          onPressed: editQuest,
                          child: Text(
                            "Edit Quest",
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.black, fontSize: 16),
                          )
                      ),
                    ),
                    (!quest.isActive() && !quest.isComplete()) ? SizedBox(width: 10,) : Text(""),
                    (!quest.isActive() && !quest.isComplete()) ?
                    Expanded(
                      child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.secondary),
                          ),
                          onPressed: makeActiveQuest,
                          child: Text(
                            "Set Active Quest",
                            style: Theme.of(context)
                                .textTheme
                                .headline5!
                                .copyWith(color: Colors.black, fontSize: 16),
                          )),
                    ) : Text(""),
                  ],
                ),
                Expanded(
                  flex: quest.getDescription().isEmpty
                      ? 0
                      : (orientation == Orientation.portrait ? 7 : 6),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Text(
                          quest.getDescription(),
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
                    isAlwaysShown: true,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
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
                if (questUpdatedOpacity == 0.0) {
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
                      Text(
                        "Quest Updated",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        "Next Task: ${getNextTask()}",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
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
                    child: Text(
                  "Quest Completed",
                  style: Theme.of(context).textTheme.headlineLarge,
                ))),
          ),
        ),
      )
    ]);
  }
}
