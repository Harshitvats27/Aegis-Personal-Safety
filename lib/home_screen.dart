import 'dart:math';

import 'package:flutter/material.dart';
import 'package:women_safety/utils/constants/sizes.dart';
import 'package:women_safety/widgets/home_widgets/custom_appBar.dart';
import 'package:women_safety/widgets/home_widgets/custom_carousel.dart';
import 'package:women_safety/widgets/home_widgets/emergency.dart';
import 'package:women_safety/widgets/home_widgets/live_safe.dart';
import 'package:women_safety/widgets/home_widgets/safehome/SafeHome.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // const HomeScreen({super.key});
 int qIndex = 0;

 getRandomQuote(){
   Random random = Random();
   setState(() {
     qIndex=random.nextInt(6);
   });
 }
 @override
  void initState() {
    getRandomQuote();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(USizes.screenPadding),
            child: Column(
              children: [
                CustomAppBar(
                  onTap: getRandomQuote,
                  quoteIndex: qIndex,
                ),
              SizedBox(height: USizes.spaceBtwSections,),
              Expanded(child: ListView(
                shrinkWrap: true,
                children: [
                  CustomCarouel(),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Text('Emergency',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Emergency(),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Text('Explore LiveSafe',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                  SizedBox(height: USizes.spaceBtwSections,),
                  LiveSafe(),
                  SizedBox(height: USizes.spaceBtwItems),
                  SafeHome(),
                ],
              ))

              ],
            ),
          ),
        ),
    );
  }
}
