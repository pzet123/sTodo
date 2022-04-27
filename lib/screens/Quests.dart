import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/material.dart';
import 'package:stodo/models/Quest.dart';
import 'package:stodo/screens/QuestDetails.dart';


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

  final double questListTileHeight = 70;
  final FixedExtentScrollController questListController = FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    questTileList = getActiveQuests() + getCompletedQuests();
    return Container(
      color: Colors.black,
      child: ClickableListWheelScrollView(
        scrollController: questListController,
        itemCount: questTileList.length,
        itemHeight: questListTileHeight,
        scrollOnTap: false,
        onItemTapCallback: (index) {
          if(index == questListController.selectedItem || index == questListController.selectedItem - 1 || index == questListController.selectedItem + 1){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => QuestDetails(quest: questTileList[questListController.selectedItem].quest)));
          } else {
            questListController.animateToItem(index, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
          }
          print(questListController.selectedItem);
          print(index);

        },
        child: ListWheelScrollView.useDelegate(
          controller: questListController,
          itemExtent: questListTileHeight,
          perspective: 0.00001,
          useMagnifier: true,
          magnification: 1.5,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            print(questListController.selectedItem);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) => questTileList[index],
            childCount: questTileList.length,
          ),
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
    return Center(
      child: Container(
        child: Text(quest.getName(),
          textAlign: TextAlign.end,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: "Balgruf",
            fontSize: 22
            ),
          ),
      ),
    );
  }
}

