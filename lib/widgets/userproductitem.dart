import 'package:flutter/material.dart';
import '../screens/editscreen.dart';
import '../providers/products_providers.dart';
import 'package:provider/provider.dart';

class Userproductitem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  Userproductitem({this.id, this.imageUrl, this.title});
  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditScreen.routename, arguments: id);
              },
              icon: Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Productprovider>(context)
                      .deleteproducts(id);
                } catch (error) {
                  scaffold
                      .showSnackBar(SnackBar(content: Text('Deleting failed',textAlign: TextAlign.center,)));
                }
              },
              icon: Icon(Icons.delete),
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}
