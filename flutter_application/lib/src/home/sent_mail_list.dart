import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/src/home/home.dart';

class SentMailList extends StatelessWidget {
  final dio = Dio();
  Future<Map<String, dynamic>> getActiveMail() async {
    final String url = 'http://127.0.0.1:5000/sent'; // Замените на ваш URL

    try {
      final Response response = await dio.get(url);

      if (response.statusCode == 200) {
        // Если запрос успешен, преобразуйте ответ в словарь
        Map<String, dynamic> data = response.data;
        return data;
      } else {
        // Если запрос завершился неудачно, выведите сообщение об ошибке
        print('Failed to load data. Status code: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      // Если произошла ошибка во время выполнения запроса, выведите ее
      print('Error fetching data: $error');
      return {};
    }
  }

  final List<String> sentMails = [
    'Письмо 1',
    'Письмо 2',
    'Письмо 3',
    'Письмо 4',
    'Письмо 5',
  ];

  SentMailList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Отправленные'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity, // Растянуть на всю ширину
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Меню',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            // ListTile(
            //   title: const Text('Отправленные'),
            //   onTap: () {
            //     Navigator.pop(context); // Закрыть боковую панель
            //   },
            // ),
            // ListTile(
            //   title: const Text('Ожидают отправки'),
            //   onTap: () {
            //     Navigator.pop(context); // Закрыть боковую панель
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => PendingMailList(),
            //       ),
            //     );
            //   },
            // ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.blue, // Ваш цвет
                  child: ListTile(
                    title: const Text(
                      'Отправить скан',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Закрыть боковую панель
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: getActiveMail(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            Map<String, dynamic> activeMailData = snapshot.data!;
            List<dynamic> resultList = activeMailData['result'];

            return ListView.builder(
              itemCount: resultList.length,
              itemBuilder: (context, index) {
                String name = resultList[index]['name'];
                String text = resultList[index]['text'];
                String truncatedText =
                    text.length > 50 ? text.substring(0, 50) + ' ...' : text;

                return ListTile(
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Жирный шрифт
                          ),
                        ),
                        Text(truncatedText),
                      ],
                    ),
                  ),
                  onTap: () {
                    print(resultList[index]);
                    Navigator.of(context).push(
                      _buildPageRoute(resultList[index]),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Map<String, dynamic> emailContent) {
    print(emailContent);
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return _EmailContentDialog(
            name: emailContent['name'],
            text: emailContent['text']); //(emailContent: emailContent);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

class _EmailContentDialog extends StatelessWidget {
  final String name;
  final String text;

  const _EmailContentDialog({
    Key? key,
    required this.name,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Content'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold, // Жирный шрифт
                fontSize: 20, // Размер шрифта
              ),
            ),
            SizedBox(height: 8), // Расстояние между name и text
            Text(
              text,
              style: TextStyle(
                fontSize: 16, // Размер шрифта для text
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingMailList extends StatelessWidget {
  final dio = Dio();
  Future<Map<String, dynamic>> getPendingMail() async {
    final String url = 'http://127.0.0.1:5000/waiting';

    try {
      final Response response = await dio.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data;
        return data;
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      print('Error fetching data: $error');
      return {};
    }
  }

  final List<String> pendingMails = [
    'Письмо A',
    'Письмо B',
    'Письмо C',
    'Письмо D',
    'Письмо E',
  ];

  PendingMailList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ожидают отправки'),
      ),
      body: FutureBuilder(
        future: getPendingMail(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            // Здесь вы можете использовать данные из словаря
            Map<String, dynamic> activeMailData = snapshot.data!;
            List<dynamic> resultList = activeMailData['result'];

            return ListView.builder(
              itemCount: resultList.length,
              itemBuilder: (context, index) {
                String name = resultList[index]['name'];
                String text = resultList[index]['text'];
                String truncatedText =
                    text.length > 50 ? text.substring(0, 50) + ' ...' : text;

                return ListTile(
                  title: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Жирный шрифт
                          ),
                        ),
                        Text(truncatedText),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      // print('Выбрано письмо: ${pendingMails[index]}');
                      _buildPageRoute(resultList[index]),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Map<String, dynamic> emailContent) {
    print(emailContent);
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return _EmailContentDialog(
            name: emailContent['name'],
            text: emailContent['text']); //(emailContent: emailContent);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
