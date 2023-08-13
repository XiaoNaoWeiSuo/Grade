// ignore_for_file: camel_case_types, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _topwidget createState() => _topwidget();
}

class _topwidget extends State<TopBar> {
  int _labelstate = 0;
  void _buttonstate(int index) {
    setState(() {
      _labelstate = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 300,
        height: 55,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(40),
        decoration: const BoxDecoration(
            gradient: RadialGradient(
                colors: [Colors.orange, Colors.red],
                center: Alignment.topLeft,
                radius: 5),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 233, 139, 132),
                offset: Offset(0.5, 8.5),
                blurRadius: 10.0,
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _buttonstate(0),
                // ignore: sort_child_properties_last
                child: Text(
                  "调试",
                  style: TextStyle(
                      fontSize: 22,
                      color: _labelstate == 0
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 107, 178, 236)),
                ),
                style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(80, 50))),
              ),
              TextButton(
                onPressed: () => _buttonstate(1),
                // ignore: sort_child_properties_last
                child: Text(
                  "主页",
                  style: TextStyle(
                      fontSize: 22,
                      color: _labelstate == 1
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 107, 178, 236)),
                ),
                style: ButtonStyle(
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(80, 50))),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
            width: 83,
            height: 5,
            transform: _labelstate == 0
                ? Matrix4.translationValues(-40, 0, 0)
                : Matrix4.translationValues(40, 0, 0),
            //color: Colors.white,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
          )
        ]));
  }
}

class widgetshow extends StatelessWidget {
  String name;
  var value;
  var fill;
  widgetshow({required this.name, this.value, this.fill});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 5, right: 10),
        width: 110,
        height: 50,
        child: Row(children: [
          Expanded(
              child: Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 15, color: Color.fromARGB(255, 255, 255, 255)),
              ),
              Text(
                value.toString(),
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ],
          )),
          CircularProgressIndicator(
            value: value / fill,
            backgroundColor: const Color.fromARGB(255, 145, 167, 163),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 172, 255, 240)),
          )
        ]));
  }
}

class ContributionGraph extends StatelessWidget {
  final List<bool> activityData;

  ContributionGraph({required this.activityData});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: List.generate(
        activityData.length,
        (index) => ActivityTile(activityLevel: activityData[index]),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final bool activityLevel;

  ActivityTile({required this.activityLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2),
      width: 15.0,
      height: 15.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _getColorForActivityLevel(activityLevel),
      ),
    );
  }

  Color _getColorForActivityLevel(bool level) {
    // Define your own color mapping based on activity levels.
    if (level) {
      return const Color.fromARGB(255, 255, 255, 255);
    } else {
      return const Color.fromARGB(255, 221, 124, 94);
    }
  }
}

class SubjectCreditsList extends StatelessWidget {
  late var courseList;
  SubjectCreditsList(this.courseList);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: courseList.length,
      itemBuilder: (context, index) {
        var course = courseList[index];
        return Container(
            margin:
                const EdgeInsets.only(left: 10, top: 0, right: 10, bottom: 5),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                // border: Border.all(
                //     width: 2, color: const Color.fromARGB(255, 54, 53, 53)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 198, 198, 198),
                    offset: Offset(0.5, 2.5),
                    blurRadius: 5.0,
                  )
                ],
                color: Colors.white),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.courseName,
                          style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 107, 178, 236))),
                      const SizedBox(height: 2.0),
                      Text(
                        '学分:${course.credit} | 绩点:${course.gradePoint} | 课程类型:${course.courseType}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  course.score.toString(),
                  style: TextStyle(
                      fontSize: 30,
                      color: (course.score) >= 60
                          ? const Color.fromARGB(255, 102, 235, 107)
                          : const Color.fromARGB(255, 235, 111, 102)),
                )
              ],
            ));
      },
    );
  }
}
