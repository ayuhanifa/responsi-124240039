import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'detail_page.dart';

class FavoriteItem {
  final int id;
  final String title;
  final String imageUrl;
  final String menu; 
  final String url;

  FavoriteItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.menu,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'menu': menu,
      'url': url,
    };
  }

  factory FavoriteItem.fromJsonString(String jsonStr) {
    final jsonItem = json.decode(jsonStr);
    return FavoriteItem(
      id: jsonItem['id'],
      title: jsonItem['title'],
      imageUrl: jsonItem['image_url'] ?? '',
      menu: jsonItem['menu'] ?? 'articles',
      url: jsonItem['url'] ?? '',
    );
  }

  String toJsonString() => json.encode(toJson());
}
class BeritaPage {
  final List<FavoriteItem> favoriteItems;
  final bool hasNext;

  BeritaPage({required this.favoriteItems, required this.hasNext});
}

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<FavoriteItem> favoriteItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }


  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_items') ?? [];

    setState(() {
      favoriteItems =
          savedFavorites.map((item) => FavoriteItem.fromJsonString(item)).toList();
    });
  }


  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        favoriteItems.map((fav) => fav.toJsonString()).toList();
    await prefs.setStringList('favorite_items', encoded);
  }


  Future<void> _removeFavoriteAt(int index) async {
    final removedItem = favoriteItems[index];

    setState(() {
      favoriteItems.removeAt(index);
    });

    await _saveFavorites();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Berhasil menghapus '${removedItem.title}' dari favorit"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookmark"),
      ),
      body: favoriteItems.isEmpty
          ? const Center(child: Text("Belum ada berita favorit"))
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final fav = favoriteItems[index];

                return Dismissible(
                  key: Key('${fav.menu}_${fav.id}'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    _removeFavoriteAt(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: fav.imageUrl.isNotEmpty
                          ? Image.network(
                              fav.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(
                        fav.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        fav.menu.toUpperCase(), 
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
              
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              id: fav.id,
                              menu: fav.menu,
                            ),
                          ),
                        );
                        _loadFavorites();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
