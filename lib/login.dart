// ignore_for_file: non_constant_identifier_names, unrelated_type_equality_checks
import 'package:html/parser.dart' show parse;
import 'dart:convert';
import "package:dio/dio.dart";
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:crypto/crypto.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as html;

class Student {
  String studentId;
  String name;
  String grade;
  String educationLevel;
  String studentCategory;
  String department;
  String major;
  int requiredCredits;
  int earnedCredits;
  double gpa;
  String auditResult;
  DateTime auditTime;
  String auditor;
  String remark;

  Student({
    required this.studentId,
    required this.name,
    required this.grade,
    required this.educationLevel,
    required this.studentCategory,
    required this.department,
    required this.major,
    required this.requiredCredits,
    required this.earnedCredits,
    required this.gpa,
    required this.auditResult,
    required this.auditTime,
    required this.auditor,
    required this.remark,
  });
  @override
  String toString() {
    return 'Student('
        'StudentId: $studentId, '
        'Name: $name, '
        'Grade: $grade, '
        'EducationLevel: $educationLevel, '
        'StudentCategory: $studentCategory, '
        'Department: $department, '
        'Major: $major, '
        'RequiredCredits: $requiredCredits, '
        'EarnedCredits: $earnedCredits, '
        'GPA: $gpa, '
        'AuditResult: $auditResult, '
        'AuditTime: $auditTime, '
        'Auditor: $auditor, '
        'Remark: $remark'
        ')';
  }
}

class Course {
  int serialNumber;
  String courseCode;
  String courseName;
  int requiredCredits;
  int earnedCredits;
  String score;
  String isCompulsory;
  String isDegreeCourse;
  String isPassed;
  String remark;

  Course({
    required this.serialNumber,
    required this.courseCode,
    required this.courseName,
    required this.requiredCredits,
    required this.earnedCredits,
    required this.score,
    required this.isCompulsory,
    required this.isDegreeCourse,
    required this.isPassed,
    required this.remark,
  });
  @override
  String toString() {
    return 'Course('
        'SerialNumber: $serialNumber, '
        'CourseCode: $courseCode, '
        'CourseName: $courseName, '
        'RequiredCredits: $requiredCredits, '
        'EarnedCredits: $earnedCredits, '
        'Score: $score, '
        'IsCompulsory: $isCompulsory, '
        'IsDegreeCourse: $isDegreeCourse, '
        'IsPassed: $isPassed, '
        'Remark: $remark'
        ')';
  }
}

class CourseDataModel {
  String courseCode;
  String courseName;
  String courseType;
  double credit;
  double score;
  double gradePoint;

  CourseDataModel({
    required this.courseCode,
    required this.courseName,
    required this.courseType,
    required this.credit,
    required this.score,
    required this.gradePoint,
  });

  @override
  String toString() {
    return 'CourseDataModel: { Course Code: $courseCode, Course Name: $courseName, Course Type: $courseType, Credit: $credit, Score: $score, Grade Point: $gradePoint }';
  }
}

class Requests {
  String encryptPassword(String password, String hashkey) {
    String prefix = hashkey;
    String combinedPassword = prefix + password;
    var sha1Hash = sha1.convert(utf8.encode(combinedPassword)).toString();
    return sha1Hash;
  }

  String exHash(String webPage) {
    const String searchStr = "CryptoJS.SHA1('";
    int startIndex = webPage.indexOf(searchStr) + searchStr.length;
    int endIndex = webPage.indexOf("'", startIndex);
    return webPage.substring(startIndex, endIndex);
  }

  Future<List> Login(String account, String pass) async {
    Dio dio = Dio();
    var cookieJar = CookieJar(); // 创建一个 CookieJar 对象，用于自动管理 Cookie
    dio.interceptors.add(LogInterceptor()); // 添加一个日志拦截器，方便查看请求和响应日志
    dio.interceptors.add(CookieManager(cookieJar)); // 添加一个用于自动管理 Cookie 的拦截器
    dio.options.headers["User-Agent"] =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36 Edg/111.0.1661.51";
    Response response =
        await dio.post("http://jwc3.yangtzeu.edu.cn/eams/login.action");
    String password = encryptPassword(
        pass, exHash(response.data)); //解析第一次进入登陆页面的hash并与密码组合进行加密
    FormData data = FormData.fromMap({
      "username": account,
      "password": password,
    });
    Response callback = await dio.post(
      "http://jwc3.yangtzeu.edu.cn/eams/login.action",
      data: data,
      options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status != 500;
          }),
    ); //模拟登陆
    if (callback.data.contains("账号或密码错误")) {
      return [dio, 400];
    } else {
      return [dio, callback.statusCode];
    }
  }

  //获取计划完成情况
  Future<List> GetData(Dio dio) async {
    String url = "http://jwc3.yangtzeu.edu.cn/eams/myPlanCompl.action";
    Response call = await dio.get(url);
    List<Student> studentList = parseStudentTable(call.data);
    List<Course> courseList = parseCourseTable(call.data);
    return [studentList, courseList];
  }

  Future<List<CourseDataModel>> Getgrade(Dio dio) async {
    String url =
        "http://jwc3.yangtzeu.edu.cn/eams/teach/grade/course/person!search.action?semesterId=269&projectType=";
    Response call = await dio.get(url);
    List<CourseDataModel> studentList = parseTableData(call.data);
    studentList.removeAt(0);
    return studentList;
  }

  List<Student> parseStudentTable(String htmlSource) {
    List<Student> studentList = [];
    var document = htmlParser.parse(htmlSource);

    var table = document.querySelector('table.infoTable');
    if (table == null) {
      return studentList;
    }

    var rows = table.querySelectorAll('tr');
    if (rows.length < 5) {
      return studentList;
    }

    var cells = rows[0].querySelectorAll('td.content');
    var studentId = cells[0].text.trim();
    var name = cells[1].text.trim();
    var grade = cells[2].text.trim();

    cells = rows[1].querySelectorAll('td.content');
    var educationLevel = cells[0].text.trim();
    var studentCategory = cells[1].text.trim();
    var department = cells[2].text.trim();

    cells = rows[2].querySelectorAll('td.content');
    var major = cells[0].text.trim();
    var credits = cells[1].text.split('/');
    var requiredCredits = int.tryParse(credits[0].trim()) ?? 0;
    var earnedCredits = int.tryParse(credits[1].trim()) ?? 0;
    var gpa = double.tryParse(cells[2].text.trim()) ?? 0.0;

    cells = rows[3].querySelectorAll('td.content');
    var auditResult = cells[0].text.trim();
    var auditTime = DateTime.tryParse(cells[1].text.trim());
    var auditor = cells[2].text.trim();

    cells = rows[4].querySelectorAll('td.content');
    var remark = cells[0].text.trim();

    var student = Student(
      studentId: studentId,
      name: name,
      grade: grade,
      educationLevel: educationLevel,
      studentCategory: studentCategory,
      department: department,
      major: major,
      requiredCredits: requiredCredits,
      earnedCredits: earnedCredits,
      gpa: gpa,
      auditResult: auditResult,
      auditTime: auditTime ?? DateTime(0),
      auditor: auditor,
      remark: remark,
    );

    studentList.add(student);
    return studentList;
  }

  List<Course> parseCourseTable(String htmlSource) {
    List<Course> courseList = [];
    var document = htmlParser.parse(htmlSource);

    var table = document.querySelector('div#chartView table.formTable');
    if (table == null) {
      return courseList;
    }

    var rows = table.querySelectorAll('tr');
    if (rows.length < 2) {
      return courseList;
    }

    for (var i = 1; i < rows.length; i++) {
      var cells = rows[i].querySelectorAll('td');
      if (cells.length < 10) {
        continue;
      }

      var serialNumber = int.tryParse(cells[0].text.trim()) ?? 0;
      var courseCode = cells[1].text.trim();
      var courseName = cells[2].text.trim();
      var requiredCredits = int.tryParse(cells[3].text.trim()) ?? 0;
      var earnedCredits = int.tryParse(cells[4].text.trim()) ?? 0;
      var score = cells[5].text.trim();
      var isCompulsory = cells[6].text.trim();
      var isDegreeCourse = cells[7].text.trim();
      var isPassed = cells[8].text.trim();
      var remark = cells[9].text.trim();

      var course = Course(
        serialNumber: serialNumber,
        courseCode: courseCode,
        courseName: courseName,
        requiredCredits: requiredCredits,
        earnedCredits: earnedCredits,
        score: score,
        isCompulsory: isCompulsory,
        isDegreeCourse: isDegreeCourse,
        isPassed: isPassed,
        remark: remark,
      );

      courseList.add(course);
    }

    return courseList;
  }

  List<CourseDataModel> parseTableData(String html) {
    List<CourseDataModel> courses = [];
    var document = htmlParser.parse(html);
    var tableRows = document.querySelectorAll('tr');

    for (var row in tableRows) {
      var rowData = row.children;

      if (rowData.length != 9) {
        continue; // Skip rows that don't have the expected number of columns
      }

      var courseCode = rowData[1].text.trim();
      var courseName = rowData[3].text.trim();
      var courseType = rowData[4].text.trim();
      var credit = double.tryParse(rowData[5].text.trim()) ?? 0.0;
      var score = double.tryParse(rowData[7].text.trim()) ?? 0.0;
      var gradePoint = double.tryParse(rowData[8].text.trim()) ?? 0.0;

      var courseData = CourseDataModel(
        courseCode: courseCode,
        courseName: courseName,
        courseType: courseType,
        credit: credit,
        score: score,
        gradePoint: gradePoint,
      );

      courses.add(courseData);
    }

    return courses;
  }
}

// void main() async {
//   Requests lizi = Requests();
//   String page;
//   List insert = await lizi.Login("2022007923", "1234ZXCVBN@rt");
//   page = await lizi.GetData(insert[0]);
//   List<Student> studentList = parseStudentTable(page);
//   List<Course> courseList = parseCourseTable(page);

//   // 打印解析后的学生信息和课程信息
//   print('Student Information:');
//   for (var student in studentList) {
//     print(student.toString());
//   }

//   print('Course Information:');
//   for (var course in courseList) {
//     print(course.toString());
//   }
// }
