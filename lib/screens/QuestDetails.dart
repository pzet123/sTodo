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
  final ScrollController TaskListController = ScrollController();

  _QuestDetailsState({required this.quest});

  Widget getTaskTile(QuestTask task){
    return GestureDetector(
      onTap: () => setState(() {
        task.toggleCompleted();
        quest.update();
      }),
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
    return Scaffold(
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
        child: Column(
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
      ),
    );
  }
}
