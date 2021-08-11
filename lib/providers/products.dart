import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isfavorite;
  Product(
      {@required this.id,
      @required this.title,
      @required this.price,
      this.isfavorite = false,
      @required this.description,
      @required this.imageUrl});



  void _setFavValue(bool newValue) {
    isfavorite = newValue;
    notifyListeners();
  }

  Future<void> togglefavoritestatus(String token,String userid) async {
    final oldvalue = isfavorite;
    isfavorite = !isfavorite;
    notifyListeners();

    final url='https://shopapp-887fc-default-rtdb.firebaseio.com/userfavorite/$userid/$id.json?auth=$token';
    try{
      final response = await http.put(url,body: json.encode(isfavorite));
      if(response.statusCode>=400){
        _setFavValue(oldvalue);
        
      }
    }catch(error){
       _setFavValue(oldvalue);
    }
  }
}
