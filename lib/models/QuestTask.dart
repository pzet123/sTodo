
class QuestTask{
  String _description;
  bool _isCompleted;

  String getTaskDescription(){
    return _description;
  }

  bool isCompleted(){
    return _isCompleted;
  }

  QuestTask(this._description, this._isCompleted);

}