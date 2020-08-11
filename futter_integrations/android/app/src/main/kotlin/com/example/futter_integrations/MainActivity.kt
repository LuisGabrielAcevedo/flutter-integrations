package com.example.futter_integrations

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.mercadopago.android.px.core.MercadoPagoCheckout
import com.mercadopago.android.px.model.Payment
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val REQUEST_CODE = 1;
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        initFlutterChannels()
    }

    private fun initFlutterChannels() {
        val channelMercadoPago = MethodChannel(flutterView, "futter_integrations/mercado_pago")
        channelMercadoPago.setMethodCallHandler { methodCall, result ->
            val args = methodCall.arguments as HashMap<String, Any>;
            val publicKey = args["publicKey"] as String;
            val preferenceId = args["preferenceId"] as String;

            when(methodCall.method) {
                "mercadoPago" -> mercadoPago(publicKey, preferenceId, result)
                else -> return@setMethodCallHandler
            }
        }
    }

    private fun mercadoPago(publicKey: String, preferenceId: String, result: MethodChannel.Result) {
        MercadoPagoCheckout.Builder(publicKey, preferenceId)
                .build()
                .startPayment(this@MainActivity, REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val channelMercadoPagoResp = MethodChannel(flutterView, "futter_integrations/mercado_pago_resp")
        if (resultCode == MercadoPagoCheckout.PAYMENT_RESULT_CODE) {
            val payment = data!!.getSerializableExtra(MercadoPagoCheckout.EXTRA_PAYMENT_RESULT) as Payment;
            val paymentStatus = payment.paymentStatus;
            val paymentStatusDetails = payment.paymentStatusDetail;
            val paymentId = payment.id;

            val arrayList = ArrayList<String>()
            arrayList.add(paymentId.toString())
            arrayList.add(paymentStatus)
            arrayList.add(paymentStatusDetails)

            channelMercadoPagoResp.invokeMethod("mercadoPagoOk", arrayList);

        } else if (resultCode == Activity.RESULT_CANCELED) {
            val arrayList = ArrayList<String>()
            arrayList.add("Pago Cancelado")
            channelMercadoPagoResp.invokeMethod("mercadoPagoCancel", arrayList);
        }
        else {
            val arrayList = ArrayList<String>()
            arrayList.add("Pago Error")
            channelMercadoPagoResp.invokeMethod("mercadoPagoError", arrayList);
        }
    }
}
