import 'dart:convert';
import 'dart:io';

import 'package:clickable_list_wheel_view/clickable_list_wheel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stodo/models/Quest.dart';
import 'package:stodo/models/QuestTask.dart';
import 'package:stodo/screens/QuestDetails.dart';

import '../components/Notifications.dart';
import '../main.dart';
import 'AddQuest.dart';

late Image activeQuestIcon;

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
  final double questListTileHeight = 70;
  final FixedExtentScrollController questListController =
      FixedExtentScrollController();

  @override
  _QuestsScreenState({required this.questList});

  @override
  void initState() {
    completedQuests = getCompletedQuests();
    questTileList = getActiveQuests() + completedQuests;
    activeQuestIcon = Image.asset("assets/images/activeQuestMarker.png");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(activeQuestIcon.image, context);
  }

  List<QuestTile> getActiveQuests() {
    List<QuestTile> questTiles = [];
    questList.forEach((quest) {
      if (!quest.isComplete()) {
        questTiles.add(QuestTile(
          quest: quest,
        ));
      }
    });
    if (questTiles.isNotEmpty && completedQuests.isNotEmpty) {
      questTiles.last =
          QuestTile(quest: questTiles.last.quest, lastNotComplete: true);
    }
    return questTiles;
  }

  List<QuestTile> getCompletedQuests() {
    List<QuestTile> questTiles = [];
    questList.forEach((quest) {
      if (quest.isComplete()) {
        questTiles.add(QuestTile(
          quest: quest,
        ));
      }
    });
    return questTiles;
  }

  void selectCurrentQuest() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => QuestDetails(
                quest: questTileList[questListController.selectedItem]
                    .quest))).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    completedQuests = getCompletedQuests();
    questTileList = getActiveQuests() + completedQuests;
    return Container(
        color: Colors.black,
        child: Stack(fit: StackFit.expand, children: [
          Image(
            image: AssetImage(isPortrait
                ? "assets/images/background.png"
                : "assets/images/backgroundH.png"),
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          questTileList.isNotEmpty
              ? Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ClickableListWheelScrollView(
                    scrollController: questListController,
                    itemCount: questTileList.length,
                    itemHeight: questListTileHeight,
                    scrollOnTap: true,
                    onItemTapCallback: (index) {
                      if (index == questListController.selectedItem) {
                        selectCurrentQuest();
                      }
                    },
                    child: ListWheelScrollView.useDelegate(
                      controller: questListController,
                      itemExtent: questListTileHeight,
                      overAndUnderCenterOpacity: 0.7,
                      perspective: 0.00001,
                      useMagnifier: true,
                      magnification: 1.3,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) => playMenuSound(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => questTileList[index],
                        childCount: questTileList.length,
                      ),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/helmet.png",
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 2,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddQuestScreen(questList, null)))
                            .then((_) => setState(() {}));
                      },
                      child: Text("Add a Quest",
                          style: Theme.of(context).textTheme.headlineLarge),
                    ),
                  ],
                ),
        ]));
  }
}

class QuestTile extends StatelessWidget {
  final Quest quest;
  bool lastNotComplete;

  QuestTile({required this.quest, this.lastNotComplete = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              quest.isActive()
                  ? SizedBox(
                      width: 25,
                    )
                  : Text(""),
              Text(quest.getName(),
                  style: !quest.isComplete()
                      ? Theme.of(context).textTheme.headline1
                      : Theme.of(context).textTheme.headline2),
              quest.isActive()
                  ? SizedBox(
                      width: 5,
                    )
                  : Text(""),
              quest.isActive() ? activeQuestIcon : Text(""),
            ],
          ),
        ),
        lastNotComplete
            ? Transform.translate(
                offset: Offset(0, 62),
                child: Divider(
                  thickness: 4,
                  color: Theme.of(context).colorScheme.tertiary,
                  indent: 60,
                  endIndent: 60,
                ),
              )
            : Text("")
      ]),
    );
  }
}
