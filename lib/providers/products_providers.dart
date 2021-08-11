import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import './products.dart';
import 'package:http/http.dart' as http;
import '../modals/http.dart';

class Productprovider with ChangeNotifier {
  String authtoken;
  String userid;
  Productprovider(this.authtoken, this.userid, this._items);
  List<Product> _items = [
    // Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl: 'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg'),
    // Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl: "assets/images/trouser.jpg"),
    // Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl: "assets/images/yellow scarf.jpg"),
    // Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl: "assets/images/a pan.jpg"),
  ];

  // var _showfavoritesonly = false;
  List<Product> get items {
    // if (_showfavoritesonly) {
    //   return _items.where((element) => element.isfavorite).toList();
    // }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((e) => e.id == id);
  }

  // void showfavoritesonly() {
  //   _showfavoritesonly = true;
  // }

  // void showall() {
  //   _showfavoritesonly = false;
  // }
  List<Product> get favoriteitems {
    return _items.where((element) => element.isfavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopapp-887fc-default-rtdb.firebaseio.com/Productprovider.json?auth=$authtoken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'creatorid': userid
        }),
      );
      final newproduct = Product(
          title: product.title,
          price: product.price,
          description: product.description,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      _items.add(newproduct);
      // _items.add(value)
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  Future<void> updateproduct(String id, Product newproduct) async {
    final prodindex = _items.indexWhere((element) => element.id == id);
    if (prodindex >= 0) {
      final url =
          'https://shopapp-887fc-default-rtdb.firebaseio.com/Productprovider/$id.json?auth=$authtoken';
      await http.patch(url,
          body: json.encode({
            'title': newproduct.title,
            'price': newproduct.price,
            'description': newproduct.description,
            'imageUrl': newproduct.imageUrl,
          }));
      _items[prodindex] = newproduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteproducts(String id) async {
    final url =
        'https://shopapp-887fc-default-rtdb.firebaseio.com/Productprovider/$id.json?auth=$authtoken';
    final existingproductindex =
        _items.indexWhere((element) => element.id == id);
    var existingproduct = _items[existingproductindex];
    _items.removeAt(existingproductindex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingproductindex, existingproduct);
      notifyListeners();
      throw HttpException('Couldnot delete product');
    }
    existingproduct = null;
  }

  Future<void> fetchandsetproducts([bool filterbyuser = false]) async {
    String filterstring =
        filterbyuser ? 'orderBy="creatorid"&equalTo="$userid"' : '';
    var url =
        'https://shopapp-887fc-default-rtdb.firebaseio.com/Productprovider.json?auth=$authtoken&$filterstring';
    try {
      final response = await http.get(url);
      final extracteddata = json.decode(response.body) as Map<String, dynamic>;
      if (extracteddata == null) {
        return;
      }
      url =
          "https://shopapp-887fc-default-rtdb.firebaseio.com/userfavorite/$userid.json?auth=$authtoken";

      final favoriteresponse = await http.get(url);
      final favoritedata = json.decode(favoriteresponse.body);
      final List<Product> loadedproducts = [];
      extracteddata.forEach((prodid, proddata) {
        loadedproducts.add(Product(
            id: prodid,
            title: proddata['title'],
            price: proddata['price'],
            isfavorite:
                favoritedata == null ? false : favoritedata[prodid] ?? false,
            description: proddata['description'],
            imageUrl: proddata['imageUrl']));
      });
      _items = loadedproducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw (error);
    }
  }
}
