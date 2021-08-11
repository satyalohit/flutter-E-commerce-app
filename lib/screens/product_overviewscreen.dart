import 'package:flutter/material.dart';
import 'package:fourthapp/widgets/badge.dart';

import '../widgets/product_grid.dart';
import 'cartscreen.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../widgets/drawer.dart';
import '../providers/products_providers.dart';

enum Filteroptions {
  Favorites,
  All,
}

class Productsoverviewscreen extends StatefulWidget {
  @override
  _ProductsoverviewscreenState createState() => _ProductsoverviewscreenState();
}

class _ProductsoverviewscreenState extends State<Productsoverviewscreen> {
  var _showonlyfavorites = false;
  
  var _isloading = false;
 @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isloading = true;
      });
      await Provider.of<Productprovider>(context, listen: false).fetchandsetproducts();
      setState(() {
        _isloading = false;
      });
    });
     // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('shop'),
        actions: [
          PopupMenuButton(
            onSelected: (Filteroptions selectedvalue) {
              setState(() {
                if (selectedvalue == Filteroptions.Favorites) {
                  _showonlyfavorites = true;
                } else {
                  _showonlyfavorites = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Filters'),
                value: Filteroptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('All'),
                value: Filteroptions.All,
              )
            ],
            icon: Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cart, _2) => Badge(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(Cartscreen.routename);
                },
              ),
              value: cart.itemcount.toString(),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Productgrid(_showonlyfavorites),
    );
  }
}
