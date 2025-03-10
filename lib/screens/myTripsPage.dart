import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/screens/createNewTripPage.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable content
        Scrollbar(
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

        // Fixed positioned button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              // Action when the button is pressed
              Navigator.push(context, MaterialPageRoute<void>(builder: (context) => Createnewtrippage()));
              print("Create New Trip");
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}




