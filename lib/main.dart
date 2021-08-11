import 'package:flutter/material.dart';
import './screens/splashscreen.dart';
import '../providers/cart.dart';
import 'package:fourthapp/screens/product_overviewscreen.dart';
import './screens/product_overviewscreen.dart';
import './screens/product_detailscreen.dart';
import './providers/products_providers.dart';
import 'package:provider/provider.dart';
import './screens/cartscreen.dart';
import './providers/orders.dart';
import './screens/order_screen.dart';
import './screens/usersproductscreen.dart';
import './screens/editscreen.dart';
import './screens/auth_screen.dart';
import './providers/auth.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Productprovider>(
              update: (ctx, auth, previousproducts) => Productprovider(
                    auth.token,
                    auth.userid,
                    previousproducts == null ? [] : previousproducts.items,
                  )),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              update: (ctx, auth, previousorders) => Orders(
                  previousorders == null ? [] : previousorders.orders,
                  auth.userid,
                  auth.token)),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'shopapp',
            theme: ThemeData(
                primarySwatch: Colors.blue,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android:Custompagetransitionbuilder(),
                  TargetPlatform.iOS:Custompagetransitionbuilder(),
                })),
            home: auth.isauth
                ? Productsoverviewscreen()
                : FutureBuilder(
                    builder: (ctx, authresultsnapshot) =>
                        authresultsnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                    future: auth.tryautologin(),
                  ),
            routes: {
              Productdetailscreen.routename: (ctx) => Productdetailscreen(),
              Cartscreen.routename: (ctx) => Cartscreen(),
              Orderscreen.routename: (ctx) => Orderscreen(),
              Userproductscreen.routename: (ctx) => Userproductscreen(),
              EditScreen.routename: (ctx) => EditScreen(),
            },
          ),
        ));
  }
}
