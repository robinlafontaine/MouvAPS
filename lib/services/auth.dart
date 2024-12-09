import 'dart:ffi';

import 'package:supabase_flutter/supabase_flutter.dart';

class Auth {
  final SupabaseClient supabase = Supabase.instance.client;

  static final Auth _instance = Auth._internal();

  factory Auth() {
    return _instance;
  }

  Auth._internal();

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
      final res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );

      return res.session == null;
    } catch (e) {
      return false;
    }
  }
}