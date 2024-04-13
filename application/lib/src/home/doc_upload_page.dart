import 'dart:ffi';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
    final response = await dio.get('http://127.0.0.1:8002/');
    print(response);
  }

  void createReport(String? path, String filename) async {
    String url = 'http://192.168.1.5:8002/detect';
    // String f = (file != null && file != '') ? file : '';
    try {
      FormData formData;
      String? file = path;
      print(file);

      if (file != null && file != '') {
        formData = FormData.fromMap(
            {"file": await MultipartFile.fromFile(file, filename: filename)});
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
    var text = appState.req_body;
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
      body: Center(
        child: Column(children: [
          BigCard(text: text),
          const Padding(padding: const EdgeInsets.all(50.0)),
          ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('UPLOAD FILE'),
              onPressed: () async {
                // appState.getHttp();
                // var picked =
                // await FilePicker.platform.pickFiles(type: FileType.image);

                var picked = await ImagePicker.platform.getImageFromSource(source: ImageSource.gallery);
                // const XTypeGroup jpgsTypeGroup = XTypeGroup(
                //   label: 'JPEGs',
                //   extensions: <String>['jpg', 'jpeg'],
                // );
                // const XTypeGroup pngTypeGroup = XTypeGroup(
                //   label: 'PNGs',
                //   extensions: <String>['png'],
                // );
                // final List<XFile> picked =
                //     await openFiles(acceptedTypeGroups: <XTypeGroup>[
                //   jpgsTypeGroup,
                //   pngTypeGroup,
                // ]);
                // final ImagePicker picker = ImagePicker.platform.getMedia(options: options);

                print(picked?.name.toString());

                if (picked?.path != null) {
                  appState.createReport(
                      picked?.path, picked!.name);
                } else {
                  appState.createReport('', '');
                }
                // print(picked.first.path);

                // appState.createReport(picked.first.path, picked.first.name);
              }),
        ]),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.text,
  });

  final text;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Card(
      // color: theme.colorScheme.primary,

      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Text(text),
      ),
    );
  }
}
