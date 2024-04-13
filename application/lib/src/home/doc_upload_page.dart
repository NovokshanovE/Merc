import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';

import '../settings/settings_view.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
// import 'dio';

class MyAppState extends ChangeNotifier {
  var req_body = '';
  void getNext(text) {
    req_body = text;
    notifyListeners();
  }

  final dio = Dio();
  void getHttp() async {
    final response = await dio.get('http://0.0.0.0:8002/');
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
        formData = FormData.fromMap(
            {file: await MultipartFile.fromFile(file, filename: filename)});
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
        getNext(response.data.toString());
      } else {
        print('Failed to send request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }
}

class DocUploadPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  static const routeName = '/';

  DocUploadPage({super.key});

  bool fileFlag = false;
  FilePickerResult? result;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
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
      body: Column(children: [
        Text(appState.req_body.toString()),
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
        ),
        Center(
          child: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('UPLOAD FILE'),
              onPressed: () async {
                appState.getHttp();
                var picked =
                    await FilePicker.platform.pickFiles(type: FileType.image);

                print(picked?.files.last.path);

                if (picked?.files.last.path != null) {
                  appState.createReport(
                      picked?.files.last.path, picked!.files.last.name);
                } else {
                  appState.createReport('', '');
                }
              }),
        )
      ]),
    );
  }
}
