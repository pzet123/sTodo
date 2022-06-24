import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:stodo/models/QuestTask.dart';

import 'Frequency.dart';

class Quest{
  List<QuestTask> _tasks;
  bool _isComplete;
  bool _isActive;
  String _name;
  String _description;
  String _key;
  Frequency _questFrequency;
  int _repeatDays;
  DateTime _lastRecurrenceDate;


  Quest(this._name, this._description, this._tasks, this._isComplete, this._isActive, this._questFrequency, this._repeatDays) : _key = UniqueKey().toString(), _lastRecurrenceDate = DateTime.now();

  Quest.fromJson(Map<String, dynamic> jsonMap) :
      _name = jsonMap["name"],
      _isComplete = jsonMap["isComplete"] == "true",
      _isActive = jsonMap["isActive"] == "true",
      _tasks = (json.decode(jsonMap["tasks"]) as List<dynamic>).map((e) => QuestTask.fromJson(e)).toList(),
      _description = jsonMap["description"],
      _key = jsonMap["key"],
      _questFrequency = jsonMap.containsKey("questFrequency") ? getFrequencyFromString(jsonMap["questFrequency"]) : Frequency.completeOnce,
      _repeatDays = jsonMap.containsKey("repeatDays") ? jsonMap["repeatDays"] : 0,
      _lastRecurrenceDate = jsonMap.containsKey("lastRecurrenceDate") ? DateTime.parse(jsonMap["lastRecurrenceDate"]) : DateTime.now();


  Map<String, dynamic> toJson() => {
    "name": _name,
    "isComplete" : _isComplete.toString(),
    "isActive" : _isActive.toString(),
    "tasks" : json.encode(_tasks),
    "description" : _description,
    "key" : _key,
    "questFrequency" : _questFrequency.toString(),
    "repeatDays" : _repeatDays,
    "lastRecurrenceDate" : _lastRecurrenceDate.toIso8601String()
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

  void setFrequency(Frequency frequency){
    _questFrequency = frequency;
  }

  void setRepeatDays(int repeatDays){
    _repeatDays = repeatDays;
  }

  void setLastRecurrenceDate(DateTime lastRecurrenceDate){
    _lastRecurrenceDate = lastRecurrenceDate;
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

  int getRepeatDays(){
    return _repeatDays;
  }

  Frequency getFrequency(){
    return _questFrequency;
  }

  DateTime getLastRecurrenceDate(){
    return _lastRecurrenceDate;
  }

  String toString(){
    return "Quest Name $_name \n" +
            "Quest Description $_description \n" +
            "Quest is active? $_isActive \n" +
            "Quest is completed? $_isComplete \n" +
            "Quest tasks $_tasks \n" +
            "Quest frequency $_questFrequency \n" +
            "Quest last recurrence date $_lastRecurrenceDate \n" +
            "Quest repeat days $_repeatDays \n\n";
  }


  bool operator ==(dynamic quest) {
    return (quest is Quest) && (quest.getKey() == _key) && (quest.getName() == _name);
  }

}