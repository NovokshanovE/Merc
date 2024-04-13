import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

import '../settings/settings_view.dart';
import 'package:dio/dio.dart';
// import 'dio';

class ReportPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  static const routeName = '/';

  final dio = Dio();

  ReportPage({super.key});

  void getHttp() async {
    final response = await dio.get('http://127.0.0.1:4000/order?id=id_1');
    print(response);
  }

  void createReport(String? path, String filename) async {
    String url = 'http://0.0.0.0:8002/file';
    // String f = (file != null && file != '') ? file : '';
    try {
      FormData formData;
      String? file = path;
      print(file);

      if (file != null && file != '') {
        formData = FormData.fromMap({
          'files': {
            file: await MultipartFile.fromFile(file, filename: filename)
          },
        });
      } else {
        formData = FormData.fromMap({});
      }

      Response response = await dio.post(
        url,
        data: formData,
      );

      if (response.statusCode == 200) {
        print('Request sent successfully');
        print(response.data);
      } else {
        print('Failed to send request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  bool fileFlag = false;
  FilePickerResult? result;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        child: SingleChildScrollView(
          child: Column(children: [
            const Text(''),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
            ),
            // Column(
            //   children: [
            //     TextField(
            //         controller: nameController,
            //         decoration: InputDecoration(
            //           labelText: 'Input name...',
            //           enabledBorder: UnderlineInputBorder(
            //             borderSide: const BorderSide(
            //               color: Color(0xFFE5E7EB),
            //               width: 2,
            //             ),
            //             borderRadius: BorderRadius.circular(0),
            //           ),
            //         )),
            //     TextField(
            //       controller: reportController,
            //       autofocus: true,
            //       obscureText: false,
            //       decoration: InputDecoration(
            //         hintText: 'Input report',
            //         enabledBorder: UnderlineInputBorder(
            //           borderSide: const BorderSide(
            //             color: Color(0xFFE5E7EB),
            //             width: 2,
            //           ),
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //         focusedBorder: UnderlineInputBorder(
            //           borderSide: const BorderSide(
            //             color: Color(0xFF6F61EF),
            //             width: 2,
            //           ),
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //         errorBorder: UnderlineInputBorder(
            //           borderSide: const BorderSide(
            //             color: Color(0xFFFF5963),
            //             width: 2,
            //           ),
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //         focusedErrorBorder: UnderlineInputBorder(
            //           borderSide: const BorderSide(
            //             color: Color(0xFFFF5963),
            //             width: 2,
            //           ),
            //           borderRadius: BorderRadius.circular(0),
            //         ),
            //         contentPadding:
            //             const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 12),
            //       ),
            //       maxLines: 100,
            //       minLines: 6,
            //       cursorColor: const Color(0xFF6F61EF),
            //     )
            //   ],
            // ),
            const Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
            ),
            Center(
              child: TextButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text('UPLOAD FILE'),
                  onPressed: () async {
                    var picked = await FilePicker.platform.pickFiles();

                    print(picked?.files.last.path);

                    if (picked?.files.last.path != null) {
                      createReport(
                          picked?.files.last.path, picked!.files.last.name);
                    } else {
                      createReport('', '');
                    }
                  }),
            )
            // Row(children: [
            //   // IconButton(
            //   //   onPressed: () async {
            //   //     FilePickerResult? result =
            //   //         await FilePicker.platform.pickFiles();
            //   //     if (result != null) {
            //   //       fileFlag = true;
            //   //       print(result.files.first.name);
            //   //     }
            //   //   },
            //   //   icon: const Icon(Icons.upload_file),
            //   // ),

            //   // IconButton(
            //   //   onPressed: () {
            //   //     print("post");
            //   //     if (fileFlag == true) {
            //   //       print("With file");
            //   //       String? filePath = result?.files.first.path;
            //   //       print("!!!!!!!!!!!!!!");
            //   //       print(filePath);
            //   //       createReport(
            //   //           nameController.text, reportController.text, filePath);
            //   //     } else {
            //   //       print("Without file");
            //   //       createReport(
            //   //           nameController.text, reportController.text, '');
            //   //     }
            //   //     //getHttp();
            //   //   },
            //   //   icon: const Icon(Icons.outbond_outlined),
            //   // )
            // ]),
          ]),
        ),
      )),
    );
  }
}



// class FileUploadButton extends StatelessWidget {
//     final dio = Dio();
//    void createReport(String name, String text, String? file) async {
//     String url = 'http://127.0.0.1:5000/report';
//     try {
//       FormData formData;
//       print(file);
//       if (file != null && file != '') {
//         formData = FormData.fromMap({
//           'name': name,
//           'text': text,
//           'files': {file: await MultipartFile.fromFile(file, filename: 'file')},
//         });
//       } else {
//         formData = FormData.fromMap({
//           'name': name,
//           'text': text,
//         });
//       }

//       Response response = await dio.post(
//         url,
//         data: formData,
//       );

//       if (response.statusCode == 200) {
//         print('Request sent successfully');
//         print(response.data);
//       } else {
//         print('Failed to send request. Status code: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error sending request: $error');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return 
//   }
// }
