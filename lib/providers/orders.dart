import 'package:flutter/material.dart';
import 'package:fourthapp/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Orderitem {
  final String id;
  final double amount;
  final List<Cartitem> products;
  final DateTime datetime;
  Orderitem({
    @required this.amount,
    @required this.id,
    @required this.products,
    @required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<Orderitem> _orders = [];

  final String userid;
  final String authtoken;
  Orders(this._orders,this.userid, this.authtoken);
  List<Orderitem> get orders {
    return [..._orders];
  }

  Future<void> fetchandsetorders() async {
    final url =
        'https://shopapp-887fc-default-rtdb.firebaseio.com/Orders/$userid.json?auth=$authtoken';
    final response = await http.get(url);
    final extracteddata = json.decode(response.body) as Map<String, dynamic>;
    if (extracteddata == null) {
      return;
    }
    final List<Orderitem> loadedorders = [];
    extracteddata.forEach((orderid, orderdata) {
      loadedorders.add(Orderitem(
        id: orderid,
        amount: orderdata['amount'],
        datetime: DateTime.parse(orderdata['datetime']),
        products: (orderdata['product'] as List<dynamic>)
            .map((e) => Cartitem(
                id: e['id'],
                price: e['price'],
                title: e['title'],
                quantity: e['quantity']))
            .toList(),
      ));
    });
    _orders = loadedorders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<Cartitem> cartproducts, double total) async {
    final url =
        'https://shopapp-887fc-default-rtdb.firebaseio.com/Orders/$userid.json?auth=$authtoken';
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'datetime': timestamp.toIso8601String(),
          'product': cartproducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        }));

    _orders.insert(
        0,
        Orderitem(
            amount: total,
            id: json.decode(response.body)['name'],
            products: cartproducts,
            datetime: timestamp));
    notifyListeners();
  }
}
