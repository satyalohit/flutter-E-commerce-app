import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modals/http.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authtimer;

  String get userid {
    return _userId;
  }

  bool get isauth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authtimer != null) {
      _authtimer.cancel();
      _authtimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userdata');
    prefs.clear();
  }

  void _autologout() {
    if (_authtimer != null) {
      _authtimer.cancel();
    }
    final timetoexpiry = _expiryDate.difference(DateTime.now()).inSeconds;

    _authtimer = Timer(Duration(seconds: timetoexpiry), logout);
  }

  Future<void> _authenticate(
      String email, String password, String urlsegment) async {
    var url = "";

    if (urlsegment == "login") {
      url =
          "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyD9HaIOqknEeVEAEDYG5z7PRlEPNTGF3f8";
    }
    if (urlsegment == "signup") {
      url =
          "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyD9HaIOqknEeVEAEDYG5z7PRlEPNTGF3f8 ";
    }

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responsedata = json.decode(response.body);

      if (responsedata['error'] != null) {
        throw HttpException(responsedata['error']['message']);
      }

      _token = responsedata['idToken'];
      _userId = responsedata['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responsedata['expiresIn'],
          ),
        ),
      );
      _autologout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userdata = json.encode({
        'token': _token,
        'userid': _userId,
        'expirydate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userdata', userdata);
    } catch (error) {
      throw (error);
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signup');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'login');
  }

  Future<bool> tryautologin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userdata')) {
      return false;
    }
    final extracteduserdata =
        json.decode(prefs.getString('userdata')) as Map<String, Object>;
    final expirydate = DateTime.parse(extracteduserdata['expirydate']);

    if (expirydate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extracteduserdata['token'];
    _userId = extracteduserdata['userid'];
    _expiryDate = expirydate;
    notifyListeners();
    _autologout();
    return true;
  }
}
