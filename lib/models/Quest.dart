
import 'package:stodo/models/QuestTask.dart';

class Quest{
  List<QuestTask> _tasks;
  bool _isComplete;
  String _name;
  String _description;

  Quest(this._name, this._description, this._tasks, this._isComplete);

  bool isComplete(){
    return _isComplete;
  }

  void setComplete(bool isComplete){
    _isComplete = isComplete;
  }

  void setName(String name){
    _name = name;
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
    return this._name;
  }

  String getDescription(){
    return this._description;
  }

  List<QuestTask> getTasks(){
    return this._tasks;
  }

}