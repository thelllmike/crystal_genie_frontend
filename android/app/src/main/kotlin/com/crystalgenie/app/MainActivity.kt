package com.crystalgenie.app

import io.flutter.embedding.android.FlutterFragmentActivity

// flutter_stripe requires the host activity to be a FlutterFragmentActivity
// (the Stripe Android SDK uses fragments for the payment sheet).
class MainActivity : FlutterFragmentActivity()
