import 'package:erestro/utils/constants.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class ApiUtils {
  static Map<String, String> getHeaders() => {
        "Authorization": 'Bearer ' + _getJwtToken(),
      };

  static String _getJwtToken() {
    final claimSet =
        JwtClaim(issuer: 'erestro', expiry: DateTime.now().add(const Duration(/*days: 365*/ minutes: 1)), issuedAt: DateTime.now().toUtc());
    String token = issueJwtHS256(claimSet, jwtKey);
    return token;
  }
}
