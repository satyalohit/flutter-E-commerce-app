import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cartitem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  Cartitem(
      {@required this.id,
      @required this.price,
      @required this.title,
      @required this.quantity});
}

class Cart with ChangeNotifier {
  Map<String, Cartitem> _items = {};
  Map<String, Cartitem> get items {
    return {..._items};
  }

  int get itemcount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartitem) {
      total += cartitem.price * cartitem.quantity;
    });
    return total;
  }

  void additem(String id, double price, String title) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (value) => Cartitem(
                id: value.id,
                price: value.price,
                title: value.title,
                quantity: value.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          id,
          () => Cartitem(
              id: DateTime.now().toString(),
              price: price,
              title: title,
              quantity: 1));
    }

    notifyListeners();
  }

  void removeitems(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removesingleitem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (_items[id].quantity > 1) {
      _items.update(
          id,
          (existingitem) => Cartitem(
              id: existingitem.id,
              price: existingitem.price,
              title: existingitem.title,
              quantity: existingitem.quantity - 1));
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }
}
