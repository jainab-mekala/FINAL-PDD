package com.implantguard.ai

import io.flutter.embedding.android.FlutterFragmentActivity

// Using FlutterFragmentActivity instead of FlutterActivity
// to support biometric authentication (local_auth plugin requires this)
class MainActivity : FlutterFragmentActivity()
