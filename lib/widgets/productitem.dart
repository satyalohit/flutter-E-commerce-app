import 'package:fourthapp/providers/products.dart';

import 'package:fourthapp/screens/product_detailscreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class Productitem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // Productitem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);

    final cart = Provider.of<Cart>(context, listen: false);
    final authdata = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(Productdetailscreen.routename,
                arguments: product.id);
          },
          child: product.imageUrl != null
              ? Hero(tag: product.id,
                child: FadeInImage(
                    placeholder:
                        AssetImage('assets/images/product-placeholder.png'),
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.cover,
                  ),
              )
              : Container(),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                  product.isfavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () {
                product.togglefavoritestatus(authdata.token, authdata.userid);
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.additem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added Item to cart',
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removesingleitem(product.id);
                      }),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
