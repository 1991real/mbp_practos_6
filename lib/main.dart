import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewsFeedPage(),
    );
  }
}

class NewsFeedPage extends StatefulWidget {
  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final ScrollController _scrollController = ScrollController();

  List posts = [];
  bool isLoading = false;
  int currentPage = 1; // начинаем с первой страницы
  final int limit = 10; // по 10 постов

  @override
  void initState() {
    super.initState();
    loadNextPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        loadNextPage();
      }
    });
  }

  Future<void> loadNextPage() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final url = Uri.parse(
        "https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$currentPage");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List newData = json.decode(response.body);

      // если сервер вернул пусто — данных больше нет
      if (newData.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        posts.addAll(newData);
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Новости JSONPlaceholder")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: isLoading ? CircularProgressIndicator() : SizedBox(),
              ),
            );
          }

          final item = posts[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(item["title"], style: TextStyle(fontSize: 18)),
              subtitle: Text(item["body"]),
            ),
          );
        },
      ),
    );
  }
}
