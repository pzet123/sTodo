import 'package:flutter/material.dart';
import 'package:stodo/models/QuestTask.dart';

class AddQuestScreen extends StatefulWidget {
  @override
  _AddQuestScreenState createState() => _AddQuestScreenState();
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  @override
  Widget build(BuildContext context) {
    TextEditingController questTitleController = TextEditingController();
    TextEditingController questDescriptionController = TextEditingController();
    TextEditingController newTaskController = TextEditingController();

    List<QuestTask> newTasks = [];

    List<Widget> getNewTasks(){
      List<Widget> newTaskWidgets = [];
      newTasks.forEach((task){
        newTaskWidgets.add(Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: Text(task.getTaskDescription()),
        ));
      });
      return newTaskWidgets;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Start a New Quest"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black
        ,
        child: Column(
          children: [
            TextField(
              controller: questTitleController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: "Balgruf",
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
            Expanded(
              child: ListView(
                children: getNewTasks(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
