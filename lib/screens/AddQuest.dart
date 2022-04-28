import 'package:flutter/material.dart';
import 'package:stodo/models/QuestTask.dart';

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

  List<QuestTask> newTasks = [];

  List<Widget> getNewTasks(){
    List<Widget> newTaskWidgets = [];
    newTasks.forEach((task){
      newTaskWidgets.add(Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Text(task.getTaskDescription(), style: Theme.of(context).textTheme.headline3,),
      ));
    });
    return newTaskWidgets;
  }

  void addQuest(){
    Quest newQuest = Quest(questTitleController.text, questDescriptionController.text, newTasks, false);
    widget.questList.add(newQuest);
    Navigator.pop(context);
  }

  void addTask(){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Add a Task"),
        content: TextField(controller: newTaskController),
        actions: [
          ElevatedButton(
              onPressed: () => setState(() {
                newTasks.add(QuestTask(newTaskController.text, false));
                newTaskController.clear();
                Navigator.pop(context);
              }),
              child: Icon(Icons.add_circle_outline_rounded, color: Theme.of(context).colorScheme.secondary,))
        ],
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Start a New Quest"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            TextField(
              controller: questTitleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: "Futura",
                fontSize: 18
              ),
            ),
            TextField(
              controller: questDescriptionController,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontFamily: "Balgruf",
                  fontSize: 18
              ),
            ),
            Text("Tasks",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: "Balgruf",
                fontSize: 26
              ),
            ),
            ElevatedButton(
                onPressed: addTask,
                child: Text("Add a new task", style: Theme.of(context).textTheme.headline3,)),
            Expanded(
              child: ListView(
                children: getNewTasks(),
              ),
            ),
            ElevatedButton(
                onPressed: addQuest,
                child: Icon(Icons.add, color: Colors.white,))
          ],
        ),
      ),
    );
  }
}
