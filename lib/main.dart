// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, must_be_immutable, use_build_context_synchronously, prefer_typing_uninitialized_variables
import "package:aping/topbar.dart";
import 'package:path_provider/path_provider.dart';
import "package:roundcheckbox/roundcheckbox.dart";
import "login.dart";

// import 'dart:math';
import "package:flutter/material.dart";
import 'dart:convert';
import "dart:io";

value() {
  return {"initial": "", "content": []};
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<Map<String, dynamic>> readCounter() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return {};
    }
  }

  Future<File> writeCounter(var counter) async {
    final file = await _localFile;
    // Write the file
    return file.writeAsString(jsonEncode(counter));
  }
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Grade",
      theme: ThemeData(
        platform: TargetPlatform.android, // 或 TargetPlatform.android
      ),
      home: LoginPage(
        ctrlFile: CounterStorage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.ctrlFile});
  final CounterStorage ctrlFile;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String tip = "使用长江大学账号"; // 初始文本
  bool state = false;
  bool autoLogin = false;
  bool rememberPassword = false;
  var session;
  String contxt = "page source";
  final TextEditingController _numController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool loginState = false;
  Map initdata = {"initial": "", "content": {}, "goal": "0"};
  void fetchData() async {}

  @override
  void initState() {
    super.initState();
    widget.ctrlFile.readCounter().then((value) {
      if (value.isEmpty) {
        widget.ctrlFile.writeCounter(initdata);
      } else {
        initdata = value;
        _numController.text = initdata["initial"];
        _pwdController.text = initdata["content"][initdata["initial"]][0];
        rememberPassword = true;
        autoLogin = initdata["content"][initdata["initial"]][1] == "true"
            ? true
            : false;
        if (autoLogin) {
          Loginact();
        }
      }
      setState(() {});
    });
  }

  Future<void> Loginact() async {
    String account = _numController.text;
    String password = _pwdController.text;
    if (account != "" && password != "") {
      Requests iTing = Requests();
      setState(() {
        tip = "正在尝试登陆";
        state = true;
      });
      while (true) {
        List netdata = await iTing.Login(account, password);
        if (netdata[1] == 302) {
          List maintable = await iTing.GetData(netdata[0]);
          var gradetable = await iTing.Getgrade(netdata[0]);
          if (rememberPassword) {
            initdata["initial"] = account;
            initdata["content"][account] = [password, autoLogin.toString()];
            initdata["goal"] = initdata["content"].length.toString();
            widget.ctrlFile.writeCounter(initdata);
          }
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MainPage(maintable[0], maintable[1], gradetable);
              },
            ),
          );
          break;
        } else if (netdata[1] == 400) {
          _pwdController.clear();
          setState(() {
            tip = "账号或密码错误";
            state = false;
          });
          break;
        }
      }
    } else {
      setState(() {
        tip = "账号或密码为空";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
                child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          Container(
              padding: const EdgeInsets.all(25),
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                  gradient: RadialGradient(colors: [
                    Color.fromARGB(255, 118, 216, 240),
                    Color.fromARGB(255, 255, 212, 203)
                  ], center: Alignment.topLeft, radius: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(92, 105, 105, 105),
                      offset: Offset(0, 5),
                      blurRadius: 10.0,
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Column(
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tip,
                          style: const TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Container(
                        width: 80,
                        height: 50,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30)),
                        child: const Image(
                          fit: BoxFit.fitHeight,
                          image: NetworkImage(
                              "https://assets.msn.cn/weathermapdata/1/static/background/v2.0/jpg/partlysunny_day.jpg"),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _numController,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20), // 文本颜色为白色
                    decoration: InputDecoration(
                      label: const Text("学号"),
                      contentPadding: const EdgeInsets.all(10.0),
                      filled: true,
                      fillColor:
                          const Color.fromARGB(95, 129, 129, 129), // 背景颜色
                      hintText: 'Enter account', // 提示文本
                      hintStyle: const TextStyle(color: Colors.white), // 提示文本颜色
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.white, width: 3.0), // 边框颜色和宽度
                        borderRadius: BorderRadius.circular(10.0), // 边框圆角
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    obscureText: true,
                    controller: _pwdController,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20), // 文本颜色为白色
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      filled: true,
                      fillColor:
                          const Color.fromARGB(95, 129, 129, 129), // 背景颜色

                      label: const Text("密码"),
                      hintText: 'Enter password', // 提示文本
                      hintStyle: const TextStyle(color: Colors.white), // 提示文本颜色
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.white, width: 3.0), // 边框颜色和宽度
                        borderRadius: BorderRadius.circular(10.0), // 边框圆角
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              RoundCheckBox(
                                  size: 30,
                                  checkedWidget: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  checkedColor:
                                      const Color.fromARGB(255, 113, 191, 243),
                                  uncheckedColor: const Color(0x003C78FF),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      width: 2),
                                  isChecked: autoLogin,
                                  onTap: (selected) {
                                    autoLogin = !autoLogin;

                                    setState(() {});
                                  }),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "自动登录",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: autoLogin
                                        ? const Color.fromARGB(
                                            255, 113, 191, 243)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              RoundCheckBox(
                                  size: 30,
                                  checkedWidget: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  checkedColor:
                                      const Color.fromARGB(255, 113, 191, 243),
                                  uncheckedColor: const Color(0x003C78FF),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      width: 2),
                                  isChecked: rememberPassword,
                                  onTap: (selected) {
                                    rememberPassword = !rememberPassword;
                                    setState(() {});
                                  }),
                              const SizedBox(
                                width: 2,
                              ),
                              Text(
                                "保存账号",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: rememberPassword
                                        ? const Color.fromARGB(
                                            255, 113, 191, 243)
                                        : const Color.fromARGB(
                                            255, 255, 255, 255)),
                              )
                            ],
                          )
                        ],
                      ),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: TextButton(
                                  onPressed: () async {
                                    await Loginact();
                                  },
                                  child: state == false
                                      ? Text(
                                          "登录",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                            shadows: [
                                              Shadow(
                                                color: const Color.fromARGB(
                                                        255, 92, 91, 91)
                                                    .withOpacity(0.2), // 阴影颜色
                                                offset:
                                                    const Offset(2, 2), // 阴影偏移
                                                blurRadius: 10, // 阴影模糊半径
                                              ),
                                            ],
                                          ),
                                        )
                                      : const CircularProgressIndicator(
                                          color: Colors.white,
                                        ))))
                    ],
                  ),
                ],
              )),
          Text(initdata.toString())
        ],
      ),
    ))));
  }
}

class MainPage extends StatefulWidget {
  var topdata;
  var listdata;
  var otherdata;
  MainPage(this.topdata, this.listdata, this.otherdata, {super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _labelstate = 0;
  int number = 2;
  CounterStorage ctrlFile = CounterStorage();
  var datalist;
  void _buttonstate(int index) {
    setState(() {
      _labelstate = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();

    ctrlFile.readCounter().then((value) {
      setState(() {
        datalist = value;
        number = datalist["content"].length;
      });
    });
  }

  void backlogin(String account) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LoginPage(
            ctrlFile: CounterStorage(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // 禁用返回按钮
        onWillPop: () async => false,
        child: Scaffold(
            body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _labelstate = index;
                });
              },
              children: [HomoPage(), OtherPage()],
            ),
            Positioned(
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: 300,
                        height: 55,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0),
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(30, 90, 90, 90),
                                offset: Offset(0, 0),
                                blurRadius: 10.0,
                              )
                            ],
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30))),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => _buttonstate(0),
                                // ignore: sort_child_properties_last
                                child: Text(
                                  "数据",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: _labelstate == 0
                                          ? const Color.fromARGB(
                                              255, 65, 65, 65)
                                          : const Color.fromARGB(
                                              255, 107, 178, 236)),
                                ),
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(80, 50))),
                              ),
                              TextButton(
                                onPressed: () => _buttonstate(1),
                                // ignore: sort_child_properties_last
                                child: Text(
                                  "功能",
                                  style: TextStyle(
                                      fontSize: 22,
                                      color: _labelstate == 1
                                          ? const Color.fromARGB(
                                              255, 65, 65, 65)
                                          : const Color.fromARGB(
                                              255, 107, 178, 236)),
                                ),
                                style: ButtonStyle(
                                    fixedSize: MaterialStateProperty.all<Size>(
                                        const Size(80, 50))),
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
                                gradient: RadialGradient(colors: [
                                  Color.fromARGB(255, 118, 216, 240),
                                  Color.fromARGB(255, 255, 226, 220)
                                ], center: Alignment.topLeft, radius: 10),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )
                        ]))))
          ],
        )));
  }

  Widget HomoPage() {
    List<bool> datalist = [];
    for (var num in widget.listdata) {
      if (num.isPassed == "是") {
        datalist.add(true);
      } else {
        datalist.add(false);
      }
    }
    return WillPopScope(
        // 禁用返回按钮
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(
            child: Container(
              decoration: const BoxDecoration(color: Colors.transparent),
              padding: const EdgeInsets.all(10),
              // decoration:
              //     const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          gradient: RadialGradient(colors: [
                            Color.fromARGB(255, 118, 216, 240),
                            Color.fromARGB(255, 255, 226, 220)
                          ], center: Alignment.topLeft, radius: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(92, 105, 105, 105),
                              offset: Offset(0, 5),
                              blurRadius: 10.0,
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.only(left: 10, right: 5),
                                width: 4,
                                height: 90,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.topdata[0].name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.topdata[0].studentId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    widget.topdata[0].department,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 20,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                  )
                                ],
                              ),
                              const Expanded(child: SizedBox()),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                    color:
                                        const Color.fromARGB(62, 88, 88, 88)),
                                child: Column(
                                  children: [
                                    widgetshow(
                                      name: "GPA",
                                      value: widget.topdata[0].gpa,
                                      fill: 10,
                                    ),
                                    widgetshow(
                                      name: "Credits",
                                      value: widget.topdata[0].earnedCredits,
                                      fill: widget.topdata[0].requiredCredits,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ContributionGraph(activityData: datalist),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(child: SubjectCreditsList(widget.otherdata)),
                  const SizedBox(
                    height: 45,
                  )
                ],
              ),
            ),
          ),
        ));
  }

  Widget OtherPage() {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        SizedBox(
          width: 400,
          height: 500,
          child: ListView.builder(
            itemCount: number,
            itemBuilder: (context, index) {
              final account = datalist["content"].keys.elementAt(index);
              final values = datalist["content"][account] ?? [];
              //final password = values.isNotEmpty ? values[0] : '';
              final autoLogin = values.length > 1 ? values[1] : '';

              return GestureDetector(
                  onTap: () => backlogin(account),
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account: $account'),
                            //Text('Password: $password'),
                            Text('Auto Login: $autoLogin'),
                          ],
                        ),
                      ])));
            },
          ),
        ),
        Text(
          datalist.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        )
      ],
    )));
  }
}
