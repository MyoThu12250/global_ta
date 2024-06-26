import 'dart:convert';

import 'package:CheckMate/config_route.dart';
import 'package:CheckMate/pages/session_expire.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Controller/leaveController.dart';
import '../Controller/loginController.dart';
import 'leave.dart';

class AnnualLeave extends StatefulWidget {
  bool isedit;
  int? index;
  final Map<String, dynamic> leaveDetail;

  AnnualLeave(
      {Key? key, required this.isedit, this.index, required this.leaveDetail})
      : super(key: key);

  @override
  State<AnnualLeave> createState() => _AnnualLeaveState();
}

final LoginController loginController = Get.find();
final LeaveController controller = Get.put(LeaveController());

class _AnnualLeaveState extends State<AnnualLeave> {
  RxString count = ''.obs;

  Future<void> fetchLeaveCount() async {
    final response = await http.get(
      Uri.parse('${Config.count}/${loginController.userInfo['userId']}'),
      headers: {
        'Authorization': 'Bearer ${loginController.authorization.value}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      count.value = data['annualLeave'].toString();
    } else {
      // Handle error
      print('Failed to fetch leave count: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isedit == true) {
      _reasonController.text = widget.leaveDetail['reason'];
      ;
      _selectedDateTimef = DateTime.parse(widget.leaveDetail['from']);
      _selectedDateTimet = DateTime.parse(widget.leaveDetail['to']);
    }
    fetchLeaveCount();
  }

  Future<void> _sendData() async {
    isLoading.value = true;
    final id = loginController.userInfo['userId'].toString();
    final todate = DateFormat('yyyy-MM-dd').format(_selectedDateTimet!);
    final fromdate = DateFormat('yyyy-MM-dd').format(_selectedDateTimef!);
    final String reason = _reasonController.text;
    final String leavetype = 'Annual Leave';

    final response = await http.post(
      Uri.parse(Config.createLeaveRecordRoute),
      body: {
        'reasons': reason,
        'from': fromdate,
        'to': todate,
        'leaveType': leavetype,
        'UserId': id
      },
      headers: {
        'Authorization': 'Bearer ${loginController.authorization.value}',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      isLoading.value = false;
      final data = jsonDecode(response.body);
      count.value = data['annual'].toString();
      print(count.value);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 8,
            title: Text('Successful'),
            content: Container(
              width: 300,
              height: 60,
              child: Text("Annual Leave Request Submitted Successful"),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.lightGreenAccent)),
                child: Text('Ok'),
                onPressed: () {
                  Get.offAll(
                    Leave(
                      leaveDetail: widget.leaveDetail,
                    ),
                  ); // Close the dialog.
                },
              ),
            ],
          );
        },
      );
    } else if (response.statusCode == 401) {
      showSessionExpiredDialog();
    } else if (response.statusCode == 400) {

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 8,
            title: Text('Unsuccessful '),
            content: Container(
              width: 300,
              height: 60,
              child:  Text(jsonDecode(response.body)['message'],style: TextStyle(fontSize: 16),) ,
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.red)),
                child: Text('Ok'),
                onPressed: () {
                  Get.off(
                    Leave(
                      leaveDetail: widget.leaveDetail,
                    ),
                  ); // Close the dialog.
                },
              ),
            ],
          );
        },
      );
    } else {
      isLoading.value = false;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 8,
            title: Text('Unsuccessful'),
            content: Container(
              width: 300,
              height: 60,
              child: Text("Check Your Connection and Try Again"),
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.red)),
                child: Text('Ok'),
                onPressed: () {
                  Get.off(
                    Leave(
                      leaveDetail: widget.leaveDetail,
                    ),
                  ); // Close the dialog.
                },
              ),
            ],
          );
        },
      );
    }
  }

  DateTime? _selectedDateTimef;
  DateTime? _selectedDateTimet;
  TextEditingController _reasonController = TextEditingController();

  RxBool isLoading = false.obs;

  bool _validate() {
    String _fromDate = _selectedDateTimef.toString();
    String _toDate = _selectedDateTimet.toString();
    String _reason = _reasonController.text;
    if (_fromDate.isNotEmpty && _toDate.isNotEmpty && _reason.isNotEmpty) {
      return true;
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Required'),
              content: Text('Please enter your data'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          });
      return false;
    }
  }

  Future<void> Update() async {
    isLoading.value = true;
    final recordId = widget.leaveDetail['id'];
    final todate = DateFormat('yyyy-MM-dd').format(_selectedDateTimet!);
    final fromdate = DateFormat('yyyy-MM-dd').format(_selectedDateTimef!);

    final String reason = _reasonController.text;
    final String leavetype = 'Annual Leave';
    try {
      final response = await http.put(
        Uri.parse('${Config.updateLeaveRecordByIdRoute}/$recordId'),
        body: {
          'reasons': reason,
          'from': fromdate,
          'to': todate,
          'leaveType': leavetype
        },
        headers: {
          'Authorization': 'Bearer ${loginController.authorization.value}',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Update successful',
            backgroundColor: Colors.greenAccent,
            duration: const Duration(seconds: 4));
        Get.offAllNamed('/leave');
      } else if (response.statusCode == 401) {
        showSessionExpiredDialog();
      } else {
        print('Failed to update: ${response.statusCode}');
        Get.snackbar('Fail', 'Unable to update. Please try again.',
            backgroundColor: Colors.red, duration: const Duration(seconds: 4));
      }
    } catch (e) {
      print('Error updating: $e');
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red, duration: const Duration(seconds: 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size size = mediaQuery.size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    return WillPopScope(
      onWillPop: () async {
        Get.off(Leave(leaveDetail: {}));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: MediaQuery(
          data: MediaQuery.of(context),
          child: Container(
            // width: screenWidth,
            // height: screenHeight * 0.7,
            child: SingleChildScrollView(
              child: Obx(
                    () => Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    count.value == '0'
                        ? Center(
                      child: Text(
                        'You have nothing attempt left',
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    )
                        : Center(
                      child: Text(
                        'Remaining Annual Leave : ${count.value}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 90.0),
                      child: Center(
                        child: Text(
                          'Annual Leave Form',
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                                    child: Icon(Icons.access_time),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                                    child: Icon(Icons.library_books),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            // width: 320,
                            child: Column(
                              children: [
                                Container(
                                  // height: screenHeight * .15,
                                  // width: screenWidth * .8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: SizedBox(
                                              height: 70,
                                              width: 140,
                                              child: TextField(
                                                controller:
                                                TextEditingController(
                                                  text: _selectedDateTimef !=
                                                      null
                                                      ? '${_selectedDateTimef!.day}/${_selectedDateTimef!.month}/${_selectedDateTimef!.year}'
                                                      : null,
                                                ),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'From',
                                                  hintText: 'From',
                                                  suffixIcon: Icon(
                                                    Icons.date_range,
                                                    size: 20,
                                                  ),
                                                ),
                                                onTap: () {
                                                  _selectedDatef();
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          SizedBox(
                                            height: 70,
                                            width: 140,
                                            child: TextField(
                                              controller: TextEditingController(
                                                text: _selectedDateTimet != null
                                                    ? '${_selectedDateTimet!.day}/${_selectedDateTimet!.month}/${_selectedDateTimet!.year}'
                                                    : null,
                                              ),
                                              readOnly: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'to',
                                                hintText: 'to',
                                                suffixIcon: Icon(
                                                  Icons.date_range,
                                                  size: 20,
                                                ),
                                              ),
                                              onTap: () {
                                                _selectedDateTo();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: screenHeight * .15,
                                  width: screenWidth * .85,
                                  child: Container(
                                    width: 290,
                                    height: 95,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextField(
                                        controller: _reasonController,
                                        maxLines: null,
                                        expands: true,
                                        decoration: InputDecoration(
                                          labelText: 'Reason',
                                          hintText: 'Enter reason ',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ) //
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Obx(
                          () => isLoading.value == true
                          ? CircularProgressIndicator()
                          : SizedBox(
                        width: 130,
                        child: widget.isedit == true
                            ? ElevatedButton(
                          onPressed: () {
                            _validate() ? Update() : print("error");
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 8,
                              backgroundColor: Color(0xFFE1FF3C)),
                        )
                            : ElevatedButton(
                          onPressed: count.value == '0'
                              ? null
                              : () {
                            _validate()
                                ? _sendData()
                                : print("error");
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 8,
                              backgroundColor: Color(0xFFE1FF3C)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectedDatef() async {
    final _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTimef ?? DateTime.now().add(Duration(days: 4)),
      firstDate: DateTime.now().add(Duration(days: 4)),
      lastDate: DateTime(2100),
    );
    if (_pickedDate != null) {
      setState(() {
        _selectedDateTimef = _pickedDate;
        if (_selectedDateTimet != null &&
            _pickedDate.isAfter(_selectedDateTimet!)) {
          _selectedDateTimet = null;
        }
      });
    }
  }

  Future<void> _selectedDateTo() async {
    final _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTimet ?? _selectedDateTimef ?? DateTime.now(),
      firstDate: _selectedDateTimef ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (_pickedDate != null) {
      setState(() {
        if (_selectedDateTimef != null &&
            _pickedDate.isBefore(_selectedDateTimef!)) {
          return;
        }
        _selectedDateTimet = _pickedDate;
      });
    }
  }
}
