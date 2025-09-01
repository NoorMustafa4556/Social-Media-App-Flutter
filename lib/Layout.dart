import 'package:flutter/material.dart';

class ContainerLayout3 extends StatefulWidget {
  const ContainerLayout3({super.key});

  @override
  State<ContainerLayout3> createState() => _ContainerLayout3State();
}

class _ContainerLayout3State extends State<ContainerLayout3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Top Row with 3 containers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),




              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration:  BoxDecoration(
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                   SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration:  BoxDecoration(
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),


              // Full-width container
              Container(
                width: double.infinity,
                height: 140,
                decoration:  BoxDecoration(
                  color: Colors.deepPurple,
                ),
              ),



              // Bottom two Expanded containers in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration:  BoxDecoration(
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                   SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration:  BoxDecoration(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
