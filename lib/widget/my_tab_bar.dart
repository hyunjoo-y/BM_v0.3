import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/constant.dart';

class MyTabBar extends StatelessWidget {

  final TabController tabController;

  const MyTabBar({
    Key? key,
    required this.tabController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: size.height * 0.08,
      color: homeColor,
      child: TabBar(
          controller: tabController,
          indicator: ShapeDecoration(
              color: homeColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
              )
          ),
          tabs: [
            Tab(
              icon: Text('Friends', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600),),
            ),
            Tab(
              icon: Text('Chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
            ),
            Tab(
              icon: Text('Setting',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
            ),
          ]),
    );
  }
}
