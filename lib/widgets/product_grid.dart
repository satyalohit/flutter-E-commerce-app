import 'package:flutter/material.dart';

import './productitem.dart';
import '../providers/products_providers.dart';
import 'package:provider/provider.dart';

class Productgrid extends StatelessWidget {
  final bool showfavs;
  Productgrid(this.showfavs);
  @override
  Widget build(BuildContext context) {
    final productsdata = Provider.of<Productprovider>(context, listen: false);
   
    final products = showfavs ? productsdata.favoriteitems : productsdata.items;
    return GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              value: products[i],
              child: Productitem(
                  // products[i].id,
                  // products[i].title,
                  // products[i].imageUrl,
                  ),
            ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 2,
          crossAxisCount: 2,
        ));
  }
}
