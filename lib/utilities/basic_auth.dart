import 'dart:convert';
String username = 'admin';
String password = 'p@btvp#5';
String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));