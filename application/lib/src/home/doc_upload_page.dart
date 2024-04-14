import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../settings/settings_view.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
// import 'dio';

class MyAppState extends ChangeNotifier {
  late Map req_body = {};
  List<Map> history = [];

  void getNext(data) {
    req_body = data;
    req_body["page_number"] = 0;
    switch (req_body["doc_type"]) {
      case "passport_first_page":
        req_body["doc_type"] = "Персональный паспорт";
        req_body["page_number"] = 1;
      case "passport_register_page":
        req_body["doc_type"] = "Персональный паспорт";
        req_body["page_number"] = 2;
      case "pts":
        req_body["doc_type"] = "Паспорт ТС";
        req_body["page_number"] = 1;
      case "sts_front":
        req_body["doc_type"] = "Сертификат ТС";
        req_body["page_number"] = 1;
      case "sts_back":
        req_body["doc_type"] = "Сертификат ТС";
        req_body["page_number"] = 2;
      case "drivers_front":
        req_body["doc_type"] = "Водительское удостоверение";
        req_body["page_number"] = 1;
      case "drivers_back":
        req_body["doc_type"] = "Водительское удостоверение";
        req_body["page_number"] = 2;
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
    // String url = 'http://192.168.1.5:8002/detect';
    String url = 'http://192.168.1.5:8000/detect';
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
      getNext(Map());
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
      body: Center(
        child: Column(children: [
          ViewDocInfo(data: data),
          const Padding(padding: const EdgeInsets.all(50.0)),
          ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('UPLOAD FILE'),
              onPressed: () async {
                var picked = await ImagePicker.platform
                    .getImageFromSource(source: ImageSource.gallery);

                print(picked?.name.toString());

                if (picked?.path != null) {
                  appState.createReport(picked?.path, picked!.name);
                } else {
                  appState.createReport('', '');
                }
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(width: 5, color: Colors.deepPurpleAccent),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Информаия о документе",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
          ),
          Table(
            defaultVerticalAlignment:
                TableCellVerticalAlignment.intrinsicHeight,
            border: TableBorder.all(color: Colors.black),
            children: [
              TableRow(children: [
                BigCard(text: "Тип: "),
                BigCard(text: data["doc_type"]),
              ]),
              TableRow(children: [
                BigCard(text: "Вероятность: "),
                BigCard(text: data["confidence"].toString()),
              ]),
              TableRow(
                children: [
                  BigCard(text: "Серия: "), //.["series"]),
                  BigCard(text: data["series_numbers"]["series"]), //["number"]),
                ],
              ),
              TableRow(
                children: [
                  BigCard(text: "Номер: "), //.["series"]),
                  BigCard(text: data["series_numbers"]["number"]), //["number"]),
                ],
              ),
              TableRow(children: [
                BigCard(text: "Номер страницы: "),
                BigCard(text: data["page_number"].toString()),
              ]),
            ],
          ),
        ],
      );
    } else {
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
