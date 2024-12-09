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


  Future<void> initialize() async {
    _user = supabase.auth.currentUser;
    supabase.auth.onAuthStateChange.listen((event) {
      _user = event.session?.user;
    });
  }

  User? getUser() {
    return supabase.auth.currentUser;
  }

  String? getJwt() {
    return supabase.auth.currentSession?.accessToken;
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
}