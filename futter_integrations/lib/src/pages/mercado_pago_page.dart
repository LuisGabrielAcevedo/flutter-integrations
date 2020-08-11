import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mercadopago_sdk/mercadopago_sdk.dart';
import 'package:futter_integrations/src/utils/globals.dart' as globals;

class MercadoPagoPage extends StatefulWidget {
  @override
  _MercadoPagoPageState createState() => _MercadoPagoPageState();
}

class _MercadoPagoPageState extends State<MercadoPagoPage> {
  @override
  initState() {
    const channelMercadoPagoResp =
        const MethodChannel("futter_integrations/mercado_pago_resp");
    channelMercadoPagoResp.setMethodCallHandler((MethodCall call) async {
      print(call);
      // switch(call.method) {
      //   case 'mercadoPagoOk':
      //   case 'mercadoPagoCancel':
      //   case 'mercadoPagoError':
      // }
    });
    super.initState();
  }

  Future<Map<String, dynamic>> buildPreferences() async {
    var mp = MP(globals.clientId, globals.clientSecret);
    var preference = {
      "items": [
        {
          "title": "Test",
          "quantity": 1,
          "currency_id": "USD",
          "unit_price": 100.4
        }
      ],
      "payer": {"name": "Luis Acevedo", "email": "luisgabriel.ace@gmail.com"},
      "payment_methods": {
        "excluded_payment_types": [
          {"id": "ticket"},
          {"id": "atm"}
        ]
      }
    };
    // 4055 1678 0230 2037 visa débito, 123 11/25 APRO
    var result = await mp.createPreference(preference);
    return result;
  }

  Future<void> buyWithPaidMarket() async {
    var result = await buildPreferences();
    if (result != null) {
      var preferenceId = result['response']['id'];
      try {
        const channelMercadoPago =
            const MethodChannel("futter_integrations/mercado_pago");
        final resp = channelMercadoPago.invokeMethod(
            'mercadoPago', <String, dynamic>{
          'publicKey': globals.mpPublicKeyTest,
          'preferenceId': preferenceId
        });

        print(resp);
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mercado pago'),
      ),
      body: Center(
        child: MaterialButton(
          child: Text(
            'Comprar con mercado pado',
            style: TextStyle(color: Colors.white),
          ),
          color: Colors.blue,
          onPressed: buyWithPaidMarket,
        ),
      ),
    );
  }
}
