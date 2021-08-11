import '../widgets/userproductitem.dart';
import '../widgets/drawer.dart';

import 'package:flutter/material.dart';
import 'package:fourthapp/providers/products_providers.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import './editscreen.dart';

class Userproductscreen extends StatelessWidget {
  static const routename = '/user-products';
  Future<void> _refreshproducts(BuildContext context) async  {
     await Provider.of<Productprovider>(context, listen: false)
        .fetchandsetproducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsdata = Provider.of<Productprovider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Products'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditScreen.routename);
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _refreshproducts(context),
            builder: (ctx, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshproducts(context),
                    child: Consumer<Productprovider>(
                      builder: (ctx, productsdata, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsdata.items.length,
                            itemBuilder: (_, i) => Column(
                                  children: [
                                    Userproductitem(
                                      id: productsdata.items[i].id,
                                      imageUrl: productsdata.items[i].imageUrl,
                                      title: productsdata.items[i].title,
                                    ),
                                    Divider(),
                                  ],
                                )),
                      ),
                    ),
                  )));
  }
}
