import 'package:app_settings/app_settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationServices{
  FirebaseMessaging messaging=FirebaseMessaging.instance;
  void requestNotificationPrmission()async{
    NotificationSettings settings= await messaging.requestPermission(
      alert: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('User granted Permission');
    }
    else if (settings.authorizationStatus==AuthorizationStatus.provisional) {
      print('user granted provisional permission');
    } 
    else{
      AppSettings.openAppSettings();
      print('user denied permission');
    }
  }
  Future<void> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('Device Token: $token');
      } else {
        print('Failed to generate device token');
      }
    } catch (e) {
      print('Error while fetching device token: $e');
    }
  }
  Future<String>getServerKey()async{
    var scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client= await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "chatx-app-cb38f",
          "private_key_id": "0a7e25877748b501ae505bb12bd3b8ce532aae7d",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDN/oJAJoacz78T\nHLqjNeLuzsPmw7wpPk0z1jN/o5ZxZQikmp7wKZc32AoywIdvtKuZiIIO3ipyiEft\nuA80oGvvRPMCk8ViWMbTMF4jzInwi+zDHPpo8ilat+N2xXIiy4Vf602U7zz2/UJ/\npb+6ym4YQ8nBqb4UM0w7y28qTToXkvZAExMPNgh2gICFDXj4HNhIGGV/oYgL9XDm\n78XrTs6RW0jmJqdijPgFqiz29BypaGPci0fB4H3sBdMhzEPmZfNUY3HcmzQi1SnY\n9cbbtRD6ETyQAE2BdQvSIaFR3W1w2QG4YGS5AznRq87wCbUcOpwOyf5AELwWmGrL\nwDa75tB1AgMBAAECggEAVyvUR7xl67cYR0i5jHaxxVg3W5DKL/Pe7MhA+8soz2yv\ndyS9jKk1BltEmYyS48kjcvHrA8qtUNFuCuGAgcc/Vb4qThVlioRCAz3tIJ4eY257\nL2g0abPMn0jBF9JfRe01UE19g8Cn3md3PBhSpgOjCl6pYuxndRnuMUGaFd8fbbiu\n1Lh9MmnE8UnzwKI1/iSqbh6dEunwvXNT7sJhEAaMUhBp+X5v+L+jRKExFWr0eOCX\nORlawwclsbu/xstFpGt9mMDAq54k/D25/AkvMaU6Io3Hqk9m2x2IsF4lyAs5f2mP\n3uLYFwQsdvquiYdN7Z4WF+ntB/im4vLy3V53Mv9VcwKBgQD3vT1x1TDDkLFQKpFa\nlixVuJNcytW+KR/t/cjCwD6cm8rc42IKYBBiZ9Ba/zfdpAmerSGDiDJwouUDrxGk\ngbJ56wiJv7+Ag6W6zkB4ms7qVoQ1nUBPs/HDstZ3DQ0Jpm38GubRUEqweA9afwVi\nvZ+j9XCT19Lv1TcU3qQJf6svWwKBgQDU3OxdpRaDcJpy5ZnsadgZRJIK/GhlPp53\nD/SXW+W3ghcidOui8FCjCRy0N1NLQgGUpfsfs+jDBWObumL2uACeq0hBuccGHiWt\n7tDpoY33o1psHuLRPvfyJyQnnPsrToN9bPha82CpCaTlbGhYnpVSlnP1hjPd75ag\nU9OO3BJYbwKBgQDseHoaGgD96zMU7kzoRsfy2sfunr3/UYnkxYXIP3CEVEEDLxf6\nB1AcXjOHaG2O5nE4QNHolyxuT06Cga05dYNC1JHFyn2k0gRzl0P62un+zK5N7tfg\nPEbdIeuMn6x+NZpuNc90pEtmvnMJUo11fsLO4gyfUjdKLh7xkMLLPk3MWQKBgFac\nVah8xb5RkOZzOcASCRWu6uWBclDPu9aiLVlw0PVr/1HL1R0FPyo3SPCjGkci4lXD\ne3yYzXqctLzmh+HvWIE3HD1yA+MfXSF6bJLDY2qBkwcvQgb14hkrh/B+VUx3s9TT\nA/Kt2ISvIeMfyw1T6VojUadzJaOGGvm9YfVc4jINAoGAcAwzt1LBjKvjzMD9d78a\n+Wr4MVuXiYJgsqKYIVfu05YsRHqRtx73jv0xqzVGMU2MMKWyjQf4mdZ/WLu4wGkr\nd+80ffR/BCMm/61rn14XCmQsbfmhEjVMMx+ncjbSzZxZE9UilN9xI+6AL4af8jE7\n8BHxbwNuzR8cmniXTNDVIqg=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-610vw@chatx-app-cb38f.iam.gserviceaccount.com",
          "client_id": "105646919873212617220",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-610vw%40chatx-app-cb38f.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }
        ),scopes
    );
    final serverKey=client.credentials.accessToken.data;
    print("serverKey=$serverKey");
    return serverKey;
  }
  Future<void> storeDeviceToken(String uid) async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        DatabaseReference ref = FirebaseDatabase.instance.ref("user/$uid");
        await ref.update({"deviceToken": token});
        print('Device token stored successfully');
      }
    } catch (e) {
      print('Error storing device token: $e');
    }
  }

}

