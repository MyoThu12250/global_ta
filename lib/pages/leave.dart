import 'package:CheckMate/pages/attdanceHistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

import '../Controller/leaveController.dart';
import '../pages/annualLeave.dart';
import '../pages/leaveDetail.dart';
import '../pages/medicalLeave.dart';
import 'calender.dart';
import 'homepage.dart';

class Leave extends StatefulWidget {
  late final Map<String, dynamic> leaveDetail;

  Leave({required this.leaveDetail});

  @override
  State<Leave> createState() => _LeaveState();
}

// String status = 'Pending';

// final String leaveType = 'Annual Leave';

IconData getIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.pending;
    case 'approved':
      return Icons.check_circle;
    case 'rejected':
      return Icons.cancel;
    default:
      return Icons.error;
  }
}

Color getColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.grey;
    case 'approved':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    default:
      return Colors.transparent;
  }
}

class _LeaveState extends State<Leave> {
  @override
  void initState() {
    _controller.pagingController;
    // TODO: implement initState
    super.initState();
    GetStorage.init();

    WidgetsFlutterBinding.ensureInitialized();
  }

  final LeaveController _controller = Get.put(LeaveController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(
          HomePage(
            leaveDetail: {},
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Leave History'),
        ),
        body: _controller.isloading == true
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          color: Colors.lightGreenAccent,
                          child: TabBar(
                            tabs: [
                              Tab(text: 'All'),
                              Tab(text: 'Pending'),
                              Tab(text: 'Approved'),
                              Tab(text: 'Rejected'),
                            ],
                            controller: _controller.tabController,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _controller.tabController,
                      children: [
                        LeaveListView(
                            pagingController: _controller.pagingController,
                            leaves: _controller.allLeaves),
                        LeaveListView(
                          leaves: _controller.Plist,
                        ),
                        LeaveListView(
                          leaves: _controller.Alist,
                        ),
                        LeaveListView(
                          leaves: _controller.Rlist,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: SpeedDial(
          child: Icon(Icons.add),
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: Icon(
                Icons.medication,
                color: Colors.pink,
              ),
              labelWidget: Text('Medical leave'),
              onTap: () {
                Get.off(
                    MedicalLeave(
                      isedit: false,
                      leaveDetail: {},
                    ),
                    transition: Transition.fadeIn);
              },
            ),
            SpeedDialChild(
              elevation: 0,
              child: Icon(
                Icons.access_time,
                color: Colors.purpleAccent,
              ),
              labelWidget: Text('Annual leave'),
              onTap: () {
                Get.off(AnnualLeave(
                  isedit: false,
                  leaveDetail: {},
                ));
              },
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 35,
                onPressed: () {
                  Get.off(
                      HomePage(
                        leaveDetail: {},
                      ),
                      transition: Transition.fadeIn);
                },
                icon: Image.asset(
                  'assets/icons/home.png',
                  color: Colors.black,
                  width: 35,
                ),
              ),
              IconButton(
                iconSize: 35,
                onPressed: () {
                  Get.off(
                      Leave(
                        leaveDetail: widget.leaveDetail,
                      ),
                      transition: Transition.fadeIn);
                },
                icon: Image.asset(
                  'assets/icons/leave.png',
                  color: Colors.green,
                  width: 35,
                ),
              ),
              IconButton(
                iconSize: 35,
                onPressed: () {
                  Get.off(
                      RequestPage(
                        attendanceDetail: {},
                      ),
                      transition: Transition.fadeIn);
                },
                icon: Image.asset(
                  'assets/icons/attendance_history.png',
                  color: Colors.black,
                  width: 35,
                ),
              ),
              IconButton(
                iconSize: 35,
                onPressed: () {
                  Get.off(
                      Calender(
                        leaveDetail: {},
                      ),
                      transition: Transition.fadeIn);
                },
                icon: Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaveListView extends StatelessWidget {
  final PagingController<int, dynamic>? pagingController;
  final RxList<dynamic> leaves;

  LeaveListView({this.pagingController, required this.leaves});

  @override
  Widget build(BuildContext context) {
    if (pagingController != null) {
      return PagedListView<int, dynamic>(
        pagingController: pagingController!,
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
          itemBuilder: (context, item, index) => Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(LeaveDetailPage(leaveDetail: item));
                },
                child: ListTile(
                  title: Text(item['leaveType']),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(item['createdAt'])),
                  ),
                  trailing: Icon(
                    getIcon(item['status']),
                    color: getColor(item['status']),
                  ),
                ),
              ),
              index.isOdd ? Divider() : Divider(),
            ],
          ),
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Text('No leave records found'),
          ),
        ),
      );
    } else {
      return Obx(
        () {
          return ListView.separated(
            itemCount: leaves.length,
            itemBuilder: (context, index) {
              final item = leaves[index];
              return GestureDetector(
                onTap: () {
                  Get.to(LeaveDetailPage(leaveDetail: item));
                },
                child: ListTile(
                  title: Text(item['leaveType']),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(
                      DateTime.parse(
                        item['createdAt'],
                      ),
                    ),
                  ),
                  trailing: Icon(
                    getIcon(item['status']),
                    color: getColor(
                      item['status'],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.black,
                thickness: 0.5,
              );
            },
          );
        },
      );
    }
  }
}
