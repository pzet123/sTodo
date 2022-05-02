import 'package:flutter/material.dart';
import 'package:stodo/main.dart';

class System extends StatefulWidget {
  @override
  _SystemState createState() => _SystemState();
}

class _SystemState extends State<System> {

  void toggleSound(){
    soundOn = !soundOn;
  }

  void rateApp(){

  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.black,
      child: Column(
        children: [
          ElevatedButton(
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(Size(250, 50)),
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
            ),
              onPressed: toggleSound,
              child: Text("Toggle Sound", style: Theme.of(context).textTheme.headline1?.copyWith(color: Colors.black),)),
          SizedBox(height: 20,),
          ElevatedButton(
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size(250, 50)),
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary)
              ),
              onPressed: rateApp,
              child: Text("Rate the App", style: Theme.of(context).textTheme.headline1?.copyWith(color: Colors.black),))
        ],
      )
    );
  }
}
