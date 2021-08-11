import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/products.dart';
import '../providers/products_providers.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  static const routename = '/EditScreen';
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  var isloading = false;
  final _pricefocusnode = FocusNode();
  final _descriptionnode = FocusNode();
  final _imageurlcontroller = TextEditingController();
  final _imagefocusnode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedproduct = Product(
    id: null,
    title: "",
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initstate = true;
  var _initvalues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  @override
  void didChangeDependencies() {
    if (_initstate) {
      final productid = ModalRoute.of(context).settings.arguments as String;
      if (productid != null) {
        _editedproduct = Provider.of<Productprovider>(context, listen: false)
            .findById(productid);
        _initvalues = {
          'title': _editedproduct.title,
          'description': _editedproduct.description,
          'price': _editedproduct.price.toString(),
          'imageUrl': '',
        };
        _imageurlcontroller.text = _editedproduct.imageUrl;
      }
    }

    
    _initstate = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }


  

  @override
  void initState() {
    // TODO: implement initState
    _imagefocusnode.addListener(_updateimageurl);
    super.initState();
  }

  void dispose() {
    _imagefocusnode.removeListener(_updateimageurl);
    _pricefocusnode.dispose();
    _descriptionnode.dispose();
    _imageurlcontroller.dispose();
    _imagefocusnode.dispose();
    super.dispose();
  }

  void _updateimageurl() {
    if (!_imagefocusnode.hasFocus) {
      if ((!!_imageurlcontroller.text.startsWith('http') &&
              !_imageurlcontroller.text.startsWith('https')) ||
          !_imageurlcontroller.text.endsWith('.png') &&
              !_imageurlcontroller.text.endsWith('.jpg') &&
              !_imageurlcontroller.text.endsWith('.jpeg')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final isvalid = _form.currentState.validate();
    if (!isvalid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isloading = true;
    });
    if (_editedproduct.id != null) {
      await Provider.of<Productprovider>(context, listen: false)
          .updateproduct(_editedproduct.id, _editedproduct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Productprovider>(context, listen: false)
            .addProduct(_editedproduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occured'),
                  content: Text('Something wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('okay'))
                  ],
                ));
      }
      //  finally {
      //   setState(() {
      //     isloading = true;
      //   });

      // }
      setState(() {
        isloading = false;
      });
      Navigator.of(context).pop();

      // Navigator.of(context).pop();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
        actions: [IconButton(onPressed: _saveform, icon: Icon(Icons.save))],
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initvalues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_pricefocusnode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please provide a value';
                          }
                        },
                        onSaved: (value) {
                          _editedproduct = Product(
                              id: _editedproduct.id,
                              isfavorite: _editedproduct.isfavorite,
                              title: value,
                              price: _editedproduct.price,
                              description: _editedproduct.description,
                              imageUrl: _editedproduct.imageUrl);
                        },
                      ),
                      TextFormField(
                          initialValue: _initvalues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _pricefocusnode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionnode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a price.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a  valid number.';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter a number greater than zero.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedproduct = Product(
                                id: _editedproduct.id,
                                isfavorite: _editedproduct.isfavorite,
                                title: _editedproduct.title,
                                price: double.parse(value),
                                description: _editedproduct.description,
                                imageUrl: _editedproduct.imageUrl);
                          }),
                      TextFormField(
                          initialValue: _initvalues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          textInputAction: TextInputAction.next,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionnode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a description.';
                            }
                            if (value.length < 10) {
                              return 'It should be at least 10 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedproduct = Product(
                                id: _editedproduct.id,
                                isfavorite: _editedproduct.isfavorite,
                                title: _editedproduct.title,
                                price: _editedproduct.price,
                                description: value,
                                imageUrl: _editedproduct.imageUrl);
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                            ),
                            child: _imageurlcontroller.text.isEmpty
                                ? Text('Enter the Url')
                                : FittedBox(
                                    child:
                                        Image.network(_imageurlcontroller.text),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                decoration:
                                    InputDecoration(labelText: 'ImageUrl'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageurlcontroller,
                                focusNode: _imagefocusnode,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an imageurl';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Please enter a valid url';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    return 'Please enter a valid image url';
                                  }
                                },
                                onSaved: (value) {
                                  _editedproduct = Product(
                                      id: _editedproduct.id,
                                      isfavorite: _editedproduct.isfavorite,
                                      title: _editedproduct.title,
                                      price: _editedproduct.price,
                                      description: _editedproduct.description,
                                      imageUrl: value);
                                }),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
