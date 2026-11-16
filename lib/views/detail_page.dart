import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart'; 

class DetailPage extends StatefulWidget {
  final int id;         
  final String menu;    

  const DetailPage({
    Key? key,
    required this.id,
    required this.menu,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Category? item;
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    fetchDetail();
    checkFavoriteStatus();
  }

  Future<void> fetchDetail() async {
    final url =
        'https://api.spaceflightnewsapi.net/v4/${widget.menu}/${widget.id}/';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          item = Category.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data detail')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

 
  Future<void> checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_items') ?? [];

    final found = savedFavorites.any((itemStr) {
      final jsonItem = json.decode(itemStr);
      return jsonItem['id'] == widget.id && jsonItem['menu'] == widget.menu;
    });

    setState(() {
      isFavorite = found;
    });
  }

 
  Future<void> toggleFavorite() async {
    if (item == null) return;

    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorite_items') ?? [];

    if (isFavorite) {
   
      savedFavorites.removeWhere((itemStr) {
        final jsonItem = json.decode(itemStr);
        return jsonItem['id'] == widget.id && jsonItem['menu'] == widget.menu;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil menghapus dari favorit"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } else {

      final favMap = {
        'id': item!.id,
        'title': item!.title,
        'image_url': item!.imageUrl,
        'menu': widget.menu,
        'url': item!.url,
      };

      savedFavorites.add(json.encode(favMap));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil menambahkan ke favorit"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }

    await prefs.setStringList('favorite_items', savedFavorites);

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item?.title ?? "Detail"),
        actions: [
          IconButton(
            onPressed: () {
              if (item != null) toggleFavorite();
            },
            icon: Icon(
              isFavorite ? Icons.bookmark : Icons.bookmark_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),

      
      floatingActionButton: item == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (item!.url.isNotEmpty) {
                  _launchURL(item!.url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("URL tidak tersedia untuk item ini")),
                  );
                }
              },
              child: const Icon(Icons.open_in_browser),
            ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item!.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item!.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        item!.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(
                            label: Text(item!.newsSite),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item!.publishedAt,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item!.summary,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
