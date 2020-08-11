import 'package:flutter/material.dart';
import 'package:futter_integrations/src/pages/mercado_pago_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter integrations',
        debugShowCheckedModeBanner: false,
        home: MercadoPagoPage());
  }
}
