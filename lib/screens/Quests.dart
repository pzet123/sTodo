import 'package:flutter/material.dart';
import 'package:stodo/models/Quest.dart';


class QuestsScreen extends StatefulWidget {
  final List<Quest> questList;

  QuestsScreen({required this.questList});

  @override
  _QuestsScreenState createState() => _QuestsScreenState(questList: questList);
}

class _QuestsScreenState extends State<QuestsScreen> {
  List<Quest> questList;

  @override
  _QuestsScreenState({required this.questList});

  List<Widget> getActiveQuests(){
    List<Widget> questTiles = [];
    questList.forEach((quest) {
      if(!quest.isComplete()){
        questTiles.add(QuestTile(quest: quest,));
      }
    });
    if(questTiles.length > 0){
      questTiles.add(Divider(height: 4,));
    }
    return questTiles;
  }

  List<Widget> getCompletedQuests(){
    return [Text("")];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ListView(
        children:
         (getActiveQuests() +
          getCompletedQuests()),
      )
    );
  }
}

class QuestTile extends StatelessWidget {
  final Quest quest;

  QuestTile({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.fromLTRB(5, 25, 60, 25),
      child: GestureDetector(
          child: Text(quest.getName(),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: "Balgruf",
            fontSize: 22
            ),
          ),
        )
    );
  }
}

