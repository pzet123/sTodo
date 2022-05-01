import 'dart:convert';
import 'dart:io';

import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:stodo/models/Quest.dart';
import 'package:stodo/models/QuestTask.dart';
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
  late List<QuestTile> completedQuests;

  @override
  _QuestsScreenState({required this.questList});

  @override
  void initState() {
    completedQuests = getCompletedQuests();
    questTileList = getActiveQuests() + completedQuests;
  }

  List<QuestTile> getActiveQuests(){
    List<QuestTile> questTiles = [];
    questList.forEach((quest) {
      if(!quest.isComplete()){
        questTiles.add(QuestTile(quest: quest,));
      }
    });
    if(questTiles.isNotEmpty && completedQuests.isNotEmpty){
      questTiles.last = QuestTile(quest: questTiles.last.quest, lastActive: true);
    }
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

  void playMenuSound() async{
    AudioCache player = AudioCache();
    const String menuScrollSoundPath = "menuScroll.mp3";
    player.play(menuScrollSoundPath);
  }

  final double questListTileHeight = 70;
  final FixedExtentScrollController questListController = FixedExtentScrollController();

  @override
  Widget build(BuildContext context) {
    completedQuests = getCompletedQuests();
    questTileList = getActiveQuests() + completedQuests;
    return Container(
      color: Colors.black,
      child: questTileList.isNotEmpty ? ClickableListWheelScrollView(
        scrollController: questListController,
        itemCount: questTileList.length,
        itemHeight: questListTileHeight,
        scrollOnTap: false,
        onItemTapCallback: (index) {
          if(index == questListController.selectedItem || index == questListController.selectedItem - 1 || index == questListController.selectedItem + 1){
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)
              => QuestDetails(quest: questTileList[questListController.selectedItem].quest))
            ).then((_) => setState(() {}));
          } else {
            questListController.animateToItem(index, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
          }
        },
        child: ListWheelScrollView.useDelegate(
          controller: questListController,
          itemExtent: questListTileHeight,
          overAndUnderCenterOpacity: 0.7,
          perspective: 0.00001,
          useMagnifier: true,
          magnification: 1.5,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) => playMenuSound(),
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) => questTileList[index],
            childCount: questTileList.length,
          ),
        ),
      ) : Column(
        children: [
          Image.asset("assets/images/steelSword.png",
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 2,
          ),
          Text("Add a Quest", style: Theme.of(context).textTheme.headlineLarge),
        ],
      )
    );
  }



}

class QuestTile extends StatelessWidget {
  final Quest quest;
  bool lastActive;

  QuestTile({required this.quest, this.lastActive = false});



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [Center(
          child: Text(quest.getName(),
            style: !quest.isComplete() ? Theme.of(context).textTheme.headline1 : Theme.of(context).textTheme.headline2
            ),
        ),
          lastActive ? Transform.translate(
          offset: Offset(0, 62),
            child: Divider(thickness: 4, color: Theme.of(context).colorScheme.tertiary, indent: 30, endIndent: 30,),
        ) : Text("")
        ]
      ),
    );
  }
}

