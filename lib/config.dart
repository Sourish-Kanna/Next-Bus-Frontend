import 'package:nextbus/firebase_options_dev.dart'; // Import Dev
import 'package:nextbus/firebase_options_prod.dart'; // Import Prod
import 'package:firebase_core/firebase_core.dart';

// Get the environment for Netlify builds (defaults to 'dev')
const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

// Get the API link for local IDE builds
const String _localApiUrl = String.fromEnvironment('API_LINK');

class Config {
  
  static String get apiUrl {
    return _localApiUrl;
  }

  static FirebaseOptions get firebaseOptions {
    
    if (_environment == 'prod') {
      return ProdFirebaseOptions.currentPlatform;
    }

    // Default to dev
    return DevFirebaseOptions.currentPlatform;
  }
}