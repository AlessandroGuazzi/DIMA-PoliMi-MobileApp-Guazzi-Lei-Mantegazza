import 'package:dima_project/screens/homePage.dart';
import 'package:dima_project/screens/myTripsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dima_project/models/tripModel.dart';

class Createnewtrippage extends StatefulWidget {
  const Createnewtrippage({super.key});

  @override
  State<Createnewtrippage> createState() => _CreatenewtrippageState();
}

class _CreatenewtrippageState extends State<Createnewtrippage> {

  final TextEditingController creatorIdController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController nationsController = TextEditingController();
  final TextEditingController citiesController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Dima Project"),
          backgroundColor: Colors.lightBlue
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
                children: [
                  const Center(
                    child: Card(
                      elevation: 16.0,
                      child: Text(
                        'Create a New Trip',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
                  ),

                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'insert a title';
                      }
                      return null;
                    },
                    onSaved: (value) {
                     //title = value;
                    },
                    controller: titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(label: Text('Title')),
                  ),

                  TextFormField(
                    controller: nationsController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(label: Text('Nations (comma-separated)')),
                  ),

                  TextFormField(
                    controller: citiesController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(label: Text('Cities (comma-separated)')),
                  ),

                  TextFormField(
                    controller: activitiesController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(label: Text('Activities (comma-separated)')),
                  ),


                  //TODO BOTTONE FINALE E ALTRI DATI DI TIPO NON TESTUALE
                  //TODO CHECK SUI INPUT, NAZIONI E CITTA' FATTI A LISTA A SCELTA?
                  ElevatedButton(
                      onPressed: (){
                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();
                        }
                        Navigator.push(context, MaterialPageRoute<void>(builder: (context) => MyHomePage(title: 'Flutter Demo Home Page')));
                        //TODO FIXARE QUESTIONE TITLE HOMEPAGE INUTILE??
                      },
                      child: Text('Complete'))
                ]
            ),
          ),
        ),
      ),
    );
  }
}
