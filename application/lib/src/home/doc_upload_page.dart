import 'dart:collection';
import 'dart:ffi';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';

import '../settings/settings_view.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dio';

class MyAppState extends ChangeNotifier{
  late Map req_body = {};
  List<Map> history = [];


  void getNext(data) {
    req_body = data;
    switch (req_body["type"]){
      case "personal_passport":
        req_body["type"] = "Персональный паспорт";
      case "vehicle_passport":
        req_body["type"] = "Паспорт ТС";
      case "vehicle_certificate":
        req_body["type"] = "Сертификат ТС";
      case "driver_license":
        req_body["type"] = "Водительское удостоверение";
    }
    print(req_body.toString());
    history.add(req_body);
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
        getNext(response.data);
      } else {
        print('Failed to send request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      getNext({"No file received"});
      print('Error sending request: $error');
    }
  }
}

class DocUploadPage extends StatelessWidget{
  final TextEditingController nameController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  static const routeName = '/';

  DocUploadPage({super.key});

  bool fileFlag = false;
  FilePickerResult? result;




  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var data = appState.req_body;
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
      body:
        Center(
          child: Column(children: [
            ViewDocInfo(data: data),
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

class ViewDocInfo extends StatelessWidget {
  const ViewDocInfo({
    super.key,
    required this.data,
  });

  final Map data;

  @override
  Widget build(BuildContext context) {
    if (data.isNotEmpty) {
      return Column(
        children: [
         Text("Информаия о документе"),
          Padding(padding: const EdgeInsets.all(20.0),),

          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
            border: TableBorder.all(color: Colors.black),
            children: [

              TableRow(
                  children: [BigCard(text: "Тип: "), BigCard(text:data["type"]),]
              ),
              TableRow(
                  children: [BigCard(text: "Вероятность: "), BigCard(text:data["confidence"].toString()),]
              ),

              TableRow(children: [
                BigCard(text: "Серия: "), //.["series"]),
                BigCard(text: data["series"]), //["number"]),
              ],),
              TableRow(children: [
                BigCard(text: "Номер: "), //.["series"]),
                BigCard(text: data["number"]), //["number"]),
              ],),
              TableRow(
                  children: [BigCard(text: "Номер страницы: "), BigCard(text: data["page_number"].toString()),]
              ),

            ],
          ),
        ],
      );
    } else{
      return Column(
        children: [

          BigCard(text: "No file received"),
        ],
      );
    }

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
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(text),

    );
  }
}
