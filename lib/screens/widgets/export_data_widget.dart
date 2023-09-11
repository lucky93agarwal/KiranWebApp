import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import '../../design/app_colors.dart';
import 'package:universal_html/html.dart' show AnchorElement;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ExportDataWidget extends StatefulWidget {
  const ExportDataWidget({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  final String groupId;
  @override
  State<ExportDataWidget> createState() => _ExportDataWidgetState();
}

class _ExportDataWidgetState extends State<ExportDataWidget> {
  final box = GetStorage();
  bool isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  Duration? executionTime;
  int rowIndex = 2;

  Future<void> createExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.getRangeByName('A1').setText('Username');
    sheet.getRangeByName('B1').setText('Phone Number');
    sheet.getRangeByName('C1').setText('Email');
    sheet.getRangeByName('D1').setText('Permission');
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('groupMembers')
        .get()
        .then((value) async {
      for (var user in value.docs) {
        await _firestore.collection('users').doc(user.id).get().then(
          (userData) {
            sheet.getRangeByName('A$rowIndex').setText(userData['username']);
            sheet.getRangeByName('B$rowIndex').setText(userData['phoneNumber']);
            sheet.getRangeByName('C$rowIndex').setText(userData['email']);
            if (userData['isAdmin']) {
              sheet.getRangeByName('D$rowIndex').setText('Admin');
            } else {
              sheet.getRangeByName('D$rowIndex').setText('Not Admin');
            }
            // sheet
            //     .cell(
            //       CellIndex.indexByColumnRow(
            //           columnIndex: 0, rowIndex: rowIndex),
            //     )
            //     .value = userData['username'];
            // sheet
            //     .cell(
            //       CellIndex.indexByColumnRow(
            //           columnIndex: 1, rowIndex: rowIndex),
            //     )
            //     .value = userData['phoneNumber'];
            // sheet
            //     .cell(
            //       CellIndex.indexByColumnRow(
            //           columnIndex: 2, rowIndex: rowIndex),
            //     )
            //     .value = userData['email'];
          },
        );
        rowIndex++;
      }
    });
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    if (kIsWeb) {
      AnchorElement(
          href:
              'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
        ..setAttribute('download', 'Output.xlsx')
        ..click();
    } else {
      final String path = (await getApplicationSupportDirectory()).path;
      final String fileName =
          Platform.isWindows ? '$path\\Output.xlsx' : '$path/Output.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);
      OpenFile.open(fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: Palette.appColor,
        height: kIsWeb ? 20.h : 25.h,
        width: kIsWeb ? 20.w : 70.w,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Export Group Data'),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.black,
          ),
          backgroundColor: Palette.secondColor,
          body: Container(
            color: Palette.searchTextFieldColor,
            child: const Center(
              child: Text(
                "Expoer this groups's data to excel !",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            height: kIsWeb ? 5.h : 7.h,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      // ignore: deprecated_member_use
                      child: FlatButton(
                        color: Colors.white,
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await createExcel().then((value) {
                            Get.back();
                          });
                          setState(() {
                            isLoading = false;
                          });
                        },
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'Export',
                          style: TextStyle(
                            color: Palette.appColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
