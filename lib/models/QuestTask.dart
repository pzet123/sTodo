
import 'dart:ffi';

class QuestTask{
  String _description;
  bool _isCompleted;

  QuestTask(this._description, this._isCompleted);

  QuestTask.fromJson(Map<String, dynamic> json) :
      _description = json["description"],
      _isCompleted = json["isCompleted"] == "true";

  Map<String, dynamic> toJson() => {
    "description" : _description,
    "isCompleted" : _isCompleted.toString()
  };

  String getTaskDescription(){
    return _description;
  }

  bool isCompleted(){
    return _isCompleted;
  }

  void toggleCompleted(){
    _isCompleted = !_isCompleted;
  }

  void setCompleted(bool isCompleted){
    _isCompleted = isCompleted;
  }

}