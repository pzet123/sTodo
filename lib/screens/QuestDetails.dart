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

  _QuestDetailsState({required this.quest});
  
  List<Widget> getQuestTaskTiles() {
    List<Widget> questTaskTiles = [];
    for(QuestTask task in quest.getTasks()){
      questTaskTiles.add(Container(
        padding: EdgeInsets.symmetric(vertical: 12),
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
      ));
    }
    return questTaskTiles;
  }
  

  @override
  Widget build(BuildContext context) {
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
            Text(quest.getDescription(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: "Balgruf",
              fontSize: 18
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
              child: Scrollbar(
                isAlwaysShown: true,
                child: ListView(
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
