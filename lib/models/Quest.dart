import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:stodo/models/QuestTask.dart';

class Quest{
  List<QuestTask> _tasks;
  bool _isComplete;
  bool _isActive;
  String _name;
  String _description;
  String _key;


  Quest(this._name, this._description, this._tasks, this._isComplete, this._isActive) : _key = UniqueKey().toString();

  Quest.fromJson(Map<String, dynamic> jsonMap) :
      _name = jsonMap["name"],
      _isComplete = jsonMap["isComplete"] == "true",
      _isActive = jsonMap["isActive"] == "true",
      _tasks = (json.decode(jsonMap["tasks"]) as List<dynamic>).map((e) => QuestTask.fromJson(e)).toList(),
      _description = jsonMap["description"],
      _key = jsonMap["key"];


  Map<String, dynamic> toJson() => {
    "name": _name,
    "isComplete" : _isComplete.toString(),
    "isActive" : _isActive.toString(),
    "tasks" : json.encode(_tasks),
    "description" : _description,
    "key" : _key,
  };

  bool isComplete(){
    return _isComplete;
  }

  bool isActive() {
    return _isActive;
  }

  void toggleActive() {
    _isActive = !_isActive;
  }

  void setComplete(bool isComplete){
    _isComplete = isComplete;
  }

  void setName(String name){
    _name = name;
  }

  void setDescription(String description){
    _description = description;
  }

  void setTasks(List<QuestTask> tasks){
    _tasks = tasks;
  }

  void setActive(bool active){
    _isActive = active;
  }

  void update(){
    bool questCompleted = true;
    for(QuestTask task in _tasks){
      if(!task.isCompleted()){
        questCompleted = false;
        break;
      }
    }
    _isComplete = questCompleted;
  }

  String getName(){
    return _name;
  }

  String getDescription(){
    return _description;
  }

  String getKey(){
    return _key;
  }

  List<QuestTask> getTasks(){
    return _tasks;
  }

  QuestTask? getActiveTask(){
    for(QuestTask task in _tasks){
      if(!task.isCompleted()){
        return task;
      }
    }
    return null;
  }

  bool operator ==(dynamic quest) {
    return (quest is Quest) && (quest.getKey() == _key) && (quest.getName() == _name);
  }

}