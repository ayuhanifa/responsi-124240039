import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_model.dart';
import 'login_page.dart';
import 'detail_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  String username = "User";

  String currentMenu = "articles"; 
  String currentMenuLabel = "News";

  List<Category> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    fetchItems();
  }


  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? "User";
    });
  }

 
  Future<void> fetchItems() async {
    setState(() {
      isLoading = true;
    });

    final url = 'https://api.spaceflightnewsapi.net/v4/$currentMenu/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List results = body['results'] ?? [];

        setState(() {
          items = results.map((data) => Category.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat data")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()
    ));
  }

 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  void _changeMenu(String menu) {
    setState(() {
      currentMenu = menu;
      if (menu == 'articles') {
        currentMenuLabel = 'News';
      } else if (menu == 'blogs') {
        currentMenuLabel = 'Blogs';
      } else {
        currentMenuLabel = 'Reports';
      }
    });
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget homeContent = isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Selamat Datang, $username!",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text("News"),
                      selected: currentMenu == 'articles',
                      onSelected: (_) => _changeMenu('articles'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Blogs"),
                      selected: currentMenu == 'blogs',
                      onSelected: (_) => _changeMenu('blogs'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Reports"),
                      selected: currentMenu == 'reports',
                      onSelected: (_) => _changeMenu('reports'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final article = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailPage(
                                id: article.id,
                                menu: currentMenu,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article.imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    article.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                article.summary,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    article.newsSite,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    article.publishedAt,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );

  
    final List<Widget> widgetOptions = <Widget>[
      homeContent,
      FavoritePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "" : "Halaman Bookmart",
        ),
        centerTitle: true,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.bookmark),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritePage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                ),
              ]
            : [],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'BookMart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        onTap: _onItemTapped,
      ),
    );
  }
}
