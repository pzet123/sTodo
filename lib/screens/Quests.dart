import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
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
  late List<QuestTile> questTileList;

  @override
  _QuestsScreenState({required this.questList});

  @override
  void initState(){
    questTileList = getActiveQuests() + getCompletedQuests();
  }

  List<QuestTile> getActiveQuests(){
    List<QuestTile> questTiles = [];
    questList.forEach((quest) {
      if(!quest.isComplete()){
        questTiles.add(QuestTile(quest: quest,));
      }
    });
    return questTiles;
  }

  List<QuestTile> getCompletedQuests(){
    List<QuestTile> questTiles = [];
    questList.forEach((quest) {
      if(quest.isComplete()){
        questTiles.add(QuestTile(quest: quest,));
      }
    });
    return questTiles;
  }

  final double questListTileHeight = 60;
  final FixedExtentScrollController questListController = FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ClickableListWheelScrollView(
        scrollController: questListController,
        itemCount: questTileList.length,
        itemHeight: questListTileHeight,
        onItemTapCallback: (index) => print("Item tapped"),
        child: ListWheelScrollView(
          controller: questListController,
          itemExtent: questListTileHeight,
          squeeze: 1.2,
          perspective: 0.00001,
          useMagnifier: true,
          magnification: 1.5,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {

          },
          children:
           (questTileList = getActiveQuests() +
            getCompletedQuests()),
        ),
      )
    );
  }



}

class QuestTile extends StatelessWidget {
  final Quest quest;

  QuestTile({required this.quest});



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("Opening quest"),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Text(quest.getName(),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontFamily: "Balgruf",
              fontSize: 22
              ),
            ),
        ),
      ),
    );
  }
}

