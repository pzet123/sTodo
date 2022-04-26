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
      questTaskTiles.add(Row(
        children: [
          Icon((task.isCompleted()) ? Icons.diamond : Icons.diamond_outlined),
          Text(task.getTaskDescription())
        ],
      ));
    }
    return questTaskTiles;
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(quest.getName(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "Balgruf",
            fontSize: 24,
            color: Theme.of(context).colorScheme.secondary
          ),),
        Text(quest.getDescription()),
        Text("OBJECTIVES",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "Balgruf",
              fontSize: 24,
              color: Theme.of(context).colorScheme.secondary
          ),),
        ListView(
          children: getQuestTaskTiles(),
        )
      ],
    );
  }
}
