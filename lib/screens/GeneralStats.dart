import 'package:flutter/material.dart';

class GeneralStats extends StatefulWidget {
  @override
  _GeneralStatsState createState() => _GeneralStatsState();
}

class _GeneralStatsState extends State<GeneralStats> {
  List<List<String>> statList = [
    ["Active Quests", "21"],
    ["Completed Quests", "8"],
    ["Quest Completion Rate", "2 per week"]
  ];

  Widget getStats() {
    List<Widget> Attributes = [];
    List<Widget> values = [];
    statList.forEach((pair) {
      Attributes.add(Text(pair.first,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary)));
      values.add(Text(pair.last,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary)));
    });
    return Row(
      children: [
        Column(
          children: Attributes,
        ),
        Column(
          children: values,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black, child: getStats());
  }
}
