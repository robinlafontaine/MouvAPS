import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth {

  Auth._();

  static final Auth instance = Auth._();

  factory Auth() => instance;

  final SupabaseClient supabase = Supabase.instance.client;

  final Logger logger = Logger();

  User? _user;

  User? get currentUser => _user;

  User? getUser() {
    return supabase.auth.currentUser;
  }

  String? getJwt() {
    return supabase.auth.currentSession?.accessToken;
  }

  String? getUUID() {
    return supabase.auth.currentUser?.id;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  String? getUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  Future<void> signInWithOtp({required String email}) {
    return supabase.auth.signInWithOtp(email: email);
  }

  Future<bool> verifyOtp({required String email, required String token}) async {
    try {
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      return res.session != null && res.user != null;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  Future<List<String>> getRoles() async {
    final String? uuid = getUUID();

    if (uuid == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('roles')
          .select('name, user_role!inner()')
          .eq('user_role.user_uuid', uuid);

      return (response as List).map((role) => role['name'] as String).toList();
    } catch (e) {
      logger.e('Error fetching roles: $e');
      return [];
    }
  }

  Future<bool> hasRole(String role) async {
    final roles = await getRoles();
    return roles.contains(role);
  }

  Future<bool> hasCertificate() async {
    final response = await supabase.storage.from('user-data').list(path: getUUID(), searchOptions: const SearchOptions(search: 'certificat'));
    if (response.isEmpty) {
      return false;
    }
    return true;
  }

}