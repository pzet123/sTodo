
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