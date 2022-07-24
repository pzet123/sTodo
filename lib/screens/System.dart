import 'package:flutter/material.dart';
// import 'package:rate_my_app/rate_my_app.dart';
import 'package:stodo/main.dart';

class System extends StatefulWidget {
  @override
  _SystemState createState() => _SystemState();
}

class _SystemState extends State<System> {
  void toggleSound() {
    setState(() {
      soundOn = !soundOn;
    });
  }

  void showHelpDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: BeveledRectangleBorder(
                side: BorderSide(color: Colors.white, width: 1)
            ),
            backgroundColor: Colors.black87,
            title: Text("Help", style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 32), textAlign: TextAlign.center,),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.height * 0.9,
              child: ListView(
                  children: [
                    Text("Removing Quests", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
                    Text("You can remove a quest by tapping the X icon in the top right of the quest screen"),
                    SizedBox(height: 20,),
                    Text("Saving Quests", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
                    Text("All your quests are automatically saved when created and when any progress or modification occurs"),
                    SizedBox(height: 20,),
                    Text("Editing Tasks", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
                    Text("You can edit a task by tapping on it in the add/edit quest view"),
                    SizedBox(height: 20,),
                    Text("Removing Tasks", style: Theme.of(context).textTheme.headline5, textAlign: TextAlign.center,),
                    Text("You can remove a task by swiping it to the right in the add/edit quest view"),
                  ],
                ),
            ),
            actions: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary)
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Done", style: Theme.of(context).textTheme.headline3!.copyWith(color: Colors.black),)
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.secondary),
                ),
                onPressed: toggleSound,
                child: Text(
                  soundOn ? "Mute Audio" : "Activate Audio",
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(color: Colors.black),
                )),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.secondary),
                ),
                onPressed: showHelpDialog,
                child: Text(
                  "Help",
                  style: Theme.of(context)
                      .textTheme
                      .headline1
                      ?.copyWith(color: Colors.black),
                )),
          ],
        ));
  }
}
