import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Createnewtrippage extends StatefulWidget {
  const Createnewtrippage({super.key});

  @override
  State<Createnewtrippage> createState() => _CreatenewtrippageState();
}

class _CreatenewtrippageState extends State<Createnewtrippage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Dima Project"),
          backgroundColor: Colors.lightBlue
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
              children: [
                Card(
                  child: Container(
                    color: Colors.green[100],
                    //clipBehavior: Clip.hardEdge,
                    padding: EdgeInsets.all(10),
                    height: 350,
                  ),
                )

                //TODO
              ]
          ),
        ),
      ),
    );
  }
}
