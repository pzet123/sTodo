import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stodo/models/QuestTask.dart';

import '../main.dart';
import '../models/Quest.dart';
import '../models/Frequency.dart';

class AddQuestScreen extends StatefulWidget {
  List<Quest> questList;
  Quest? questToEdit;

  AddQuestScreen(this.questList, this.questToEdit);

  @override
  _AddQuestScreenState createState() => _AddQuestScreenState(this.questToEdit);
}

class _AddQuestScreenState extends State<AddQuestScreen> {
  TextEditingController questTitleController = TextEditingController();
  TextEditingController questDescriptionController = TextEditingController();
  TextEditingController questFrequencyController = TextEditingController();
  TextEditingController newTaskController = TextEditingController();
  TextEditingController repeatDaysController = TextEditingController();
  double questAddedTextOpacity = 0.0;
  bool _hideWidget = true;
  bool _questTitleValid = true;
  bool _editingQuest = false;
  Frequency? _questFrequency = Frequency.completeOnce;
  String _questFrequencyString = "Complete Once";

  late Quest questToEdit;
  late Timer questAddedTimer = Timer(Duration(seconds: 0), () {});
  late Timer questAddedTimer2 = Timer(Duration(seconds: 0), () {});

  List<QuestTask> newTasks = [];

  _AddQuestScreenState(Quest? questToEdit){
    _editingQuest = questToEdit != null;
    if(_editingQuest){
      this.questToEdit = questToEdit!;
      questTitleController.text = questToEdit.getName();
      questDescriptionController.text = questToEdit.getDescription();
      repeatDaysController.text = questToEdit.getRepeatDays().toString();
      _questFrequency = questToEdit.getFrequency();
      newTasks = questToEdit.getTasks();
      updateQuestFrequencyText();
    }
  }

  @override
  void dispose() {
    questAddedTimer.cancel();
    questAddedTimer2.cancel();
    super.dispose();
  }

  List<Widget> getNewTasks() {
    List<Widget> newTaskWidgets = [];
    newTasks.forEach((task) {
      newTaskWidgets.add(Dismissible(
        direction: DismissDirection.startToEnd,
        key: UniqueKey(),
        onDismissed: (direction) {
          setState(() {
            newTasks.remove(task);
          });
        },
        child: ListTile(
          title: Text(
            task.getTaskDescription(),
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.center,
          ),
        ),
      ));
    });
    return newTaskWidgets;
  }

  playNewQuestSound() async {
    if (soundOn) {
      final player = AudioPlayer();
      player.setAsset("assets/newQuest.mp3", preload: true);
      player.play();
    }
  }

  bool questValid() {
    setState(() {
      _questTitleValid = questTitleController.text.trim().isNotEmpty;
    });
    if (newTasks.length > 0) {
      return _questTitleValid;
    } else {
      SnackBar snackbar =
          const SnackBar(content: Text("You must include at least one task"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return false;
    }
  }

  bool questFrequencyValid(Frequency frequency) {
    if(frequency == Frequency.everyNDays){
      if(repeatDaysController.text.length != 0 && int.parse(repeatDaysController.text) > 1){
        return true;
      } else {
        SnackBar snackBar = SnackBar(content: Text("Invalid quest frequency input"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return false;
      }
    } else {
      return true;
    }
  }

  void addQuest() async {
    if (questValid()) {
      if(!_editingQuest){
        Quest newQuest = Quest(questTitleController.text,
            questDescriptionController.text, newTasks, false,
            false, _questFrequency!, (repeatDaysController.text.length > 0) ? int.parse(repeatDaysController.text) : 1);
        widget.questList.add(newQuest);
        playNewQuestSound();
        saveQuestList();
      }
      else {
        questToEdit.setName(questTitleController.text);
        questToEdit.setDescription(questDescriptionController.text);
        questToEdit.setTasks(newTasks);
        questToEdit.setFrequency(_questFrequency!);
        questToEdit.setRepeatDays(int.parse(repeatDaysController.text));
        playMenuSound();
        saveQuestList();
        Navigator.pop(context);
      }
      setState(() {
        questAddedTextOpacity = 1.0;
        _hideWidget = false;
      });
      questAddedTimer = Timer(Duration(seconds: 1), () {
        questTitleController.clear();
        questDescriptionController.clear();
        newTaskController.clear();
        newTasks = [];
      });
      questAddedTimer2 = Timer(Duration(seconds: 3), () {
        setState(() {
          questAddedTextOpacity = 0.0;
        });
      });
    } else {
      playInvalidInputSound();
    }
  }

  void updateQuestFrequencyText(){
    if(_questFrequency == Frequency.completeOnce){
      _questFrequencyString = "Complete Once";
    } else if(_questFrequency == Frequency.everyday){
      _questFrequencyString = "Repeat everyday";
    } else {
      _questFrequencyString = "Repeat every ${repeatDaysController.text} days";
    }
  }

  void chooseQuestFrequency() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Frequency tempFrequency = _questFrequency!;
          return StatefulBuilder(
              builder: (context, setState) {
            return AlertDialog(
              title: Text("Choose Quest Frequency", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text("Complete Once", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black)),
                    leading: Radio<Frequency>(
                      value: Frequency.completeOnce,
                      groupValue: tempFrequency,
                      onChanged: (Frequency? newFreq){
                        setState((){
                          tempFrequency = newFreq!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Everyday", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black)),
                    leading: Radio<Frequency>(
                      value: Frequency.everyday,
                      groupValue: tempFrequency,
                      onChanged: (Frequency? newFreq){
                        setState((){
                          tempFrequency = newFreq!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Every ", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black)),
                        Expanded(
                            child: TextField(
                              maxLength: 2,
                              decoration: InputDecoration(
                                  counterText: ''
                              ),
                              style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black),
                              controller: repeatDaysController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                              ],
                            )
                        ),
                        Text(" days", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.black))
                      ],
                    ),
                    leading: Radio<Frequency>(
                      value: Frequency.everyNDays,
                      groupValue: tempFrequency,
                      onChanged: (Frequency? newFreq){
                        setState((){
                          tempFrequency = newFreq!;
                        });
                      },
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if(questFrequencyValid(tempFrequency)){
                        _questFrequency = tempFrequency;
                        updateQuestFrequencyText();
                        Navigator.pop(context);
                      } else {
                        playInvalidInputSound();
                      }
                    },
                    child: Text("Confirm", style: Theme.of(context).textTheme.subtitle1,))
              ],
            );
          }
          );
      }
    ).then((_) {
      setState(() {});
    });
  }

  void addTask() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add a Task", style: Theme.of(context).textTheme.headline3?.copyWith(color: Colors.black)),
            content: TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardAppearance: Brightness.dark,
              controller: newTaskController,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.black),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => setState(() {
                        if (newTaskController.text.trim().isNotEmpty) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          newTasks
                              .add(QuestTask(newTaskController.text, false));
                          newTaskController.clear();
                        } else {
                          SnackBar emptyTaskSnackBar =
                              SnackBar(content: Text("Tasks cannot be empty"));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(emptyTaskSnackBar);
                          playInvalidInputSound();
                        }
                        Navigator.pop(context);
                      }),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.secondary,
                  ))
            ],
          );
        });
  }

  Widget getPortraitLayout() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 10, 10, 2),
          child: TextField(
              textCapitalization: TextCapitalization.words,
              keyboardAppearance: Brightness.dark,
              maxLength: 25,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  errorText:
                      _questTitleValid ? null : "Quest title cannot be empty",
                  hintText: "Enter Quest Name",
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  labelText: "Quest Name",
                  labelStyle: Theme.of(context).textTheme.subtitle1),
              controller: questTitleController,
              style: Theme.of(context).textTheme.subtitle1),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: TextField(
              textCapitalization: TextCapitalization.sentences,
              keyboardAppearance: Brightness.dark,
              cursorColor: Colors.white,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                  hintText: "Enter Quest Description",
                  hintStyle: Theme.of(context).textTheme.subtitle1,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary)),
                  labelText: "Quest Description",
                  labelStyle: Theme.of(context).textTheme.subtitle1),
              controller: questDescriptionController,
              style: Theme.of(context).textTheme.subtitle1),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white)
            ),
            onPressed: chooseQuestFrequency,
            child: Text(_questFrequencyString, style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.black),),
          ),
        ),
        Text("Tasks", style: Theme.of(context).textTheme.headline1),
        ElevatedButton(
            onPressed: addTask,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary)),
            child: Text(
              "Add a new task",
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  ?.copyWith(color: Colors.black),
            )),

        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: ListView(
              children: getNewTasks(),
            ),
          ),
        ),
        ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 2 - 60,
                    vertical: 10)),
                backgroundColor: MaterialStateProperty.all(
                    Theme.of(context).colorScheme.secondary)),
            onPressed: addQuest,
            child: Text(_editingQuest ? "Edit Quest" : "Add Quest", style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.black),)
        ),
        SizedBox(height: 20,)
      ],
    );
  }

  Widget getLandscapeLayout() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: (MediaQuery.of(context).size.width / 2) - 40,
                    child: TextField(
                        textCapitalization: TextCapitalization.words,
                        keyboardAppearance: Brightness.dark,
                        maxLength: 25,
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            counterText: "",
                            errorText: _questTitleValid
                                ? null
                                : "Quest title cannot be empty",
                            hintText: "Enter Quest Name",
                            hintStyle: Theme.of(context).textTheme.subtitle1,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            labelText: "Quest Name",
                            labelStyle: Theme.of(context).textTheme.subtitle1),
                        controller: questTitleController,
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: (MediaQuery.of(context).size.width / 2) - 40,
                    child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardAppearance: Brightness.dark,
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            counterText: "",
                            hintText: "Enter Quest Description",
                            hintStyle: Theme.of(context).textTheme.subtitle1,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary)),
                            labelText: "Quest Description",
                            labelStyle: Theme.of(context).textTheme.subtitle1),
                        controller: questDescriptionController,
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white)
                      ),
                      onPressed: chooseQuestFrequency,
                      child: Text(_questFrequencyString, style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.black),),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text("Tasks", style: Theme.of(context).textTheme.headline1),
                  ElevatedButton(
                      onPressed: addTask,
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondary)),
                      child: Text(
                        "Add a new task",
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            ?.copyWith(color: Colors.black),
                      )),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.tertiary),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListView(
                        children: getNewTasks(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 4 - 60,
                              vertical: 10)),
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.secondary)),
                      onPressed: addQuest,
                      child: Text(_editingQuest ? "Edit Quest" : "Add Quest", style: Theme.of(context).textTheme.headline5?.copyWith(color: Colors.black),)
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          (_editingQuest) ? "Edit Quest" : "Start a New Quest",
          style: Theme.of(context).textTheme.headline3,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Stack(children: [
          orientation == Orientation.portrait
              ? getPortraitLayout()
              : getLandscapeLayout(),
          AnimatedOpacity(
            curve: Curves.decelerate,
            opacity: questAddedTextOpacity,
            duration: Duration(seconds: 1),
            onEnd: () => setState(() {
              if (questAddedTextOpacity == 0.0) {
                _hideWidget = true;
              }
            }),
            child: Transform.translate(
              offset: _hideWidget ? Offset(-5000, -5000) : Offset(0, 0),
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: Text(
                  "Quest Added",
                  style: Theme.of(context).textTheme.headlineLarge,
                )),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
