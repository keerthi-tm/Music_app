import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:landingpage/src/ui/screens/dashboard.dart';
import 'package:landingpage/src/ui/widgets/music_wave.dart';
import 'package:landingpage/src/utils/colors.dart';
// import 'package:landingpage/util/colors.dart';

// import '../../../appbar/widgets/music_wave.dart';
// import '../../../ui/dashboard/dashboard.dart';

// ---------------------------------------------------------------------------
// PASSWORD STRENGTH HELPERS
// A "strong" password here means: 8+ characters, at least one uppercase
// letter, one lowercase letter, one number, and one special character.
// ---------------------------------------------------------------------------

final RegExp _specialCharacterPattern = RegExp(
  r'[!@#$%^&*()_+\-={}\[\]|:;<>,.?~]',
);

/// Returns the list of unmet requirements, in human-readable form.
/// An empty list means the password satisfies every requirement.
List<String> passwordRequirementsUnmet(String password) {
  final List<String> missing = [];

  if (password.length < 8) missing.add("at least 8 characters");
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    missing.add("an uppercase letter");
  }
  if (!RegExp(r'[a-z]').hasMatch(password)) {
    missing.add("a lowercase letter");
  }
  if (!RegExp(r'[0-9]').hasMatch(password)) {
    missing.add("a number");
  }
  if (!_specialCharacterPattern.hasMatch(password)) {
    missing.add("a special character (e.g. ! @ # \$ %)");
  }

  return missing;
}

enum PasswordStrength { weak, fair, good, strong }

PasswordStrength passwordStrengthOf(String password) {
  final metCount = 5 - passwordRequirementsUnmet(password).length;
  if (metCount <= 2) return PasswordStrength.weak;
  if (metCount == 3) return PasswordStrength.fair;
  if (metCount == 4) return PasswordStrength.good;
  return PasswordStrength.strong;
}

/// Returns null if [password] meets every strength requirement, otherwise
/// a single user-facing message listing what's still missing.
String? validatePasswordStrength(String password) {
  final missing = passwordRequirementsUnmet(password);
  if (missing.isEmpty) return null;
  if (missing.length == 1) return "Password needs ${missing.first}.";
  final last = missing.removeLast();
  return "Password needs ${missing.join(", ")} and $last.";
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isGoogleHovered = false;
  bool isAppleHovered = false;

  bool obscureLoginPassword = true;
  bool rememberMe = false;

  bool isDarkMode = true;

  Future<void> signInWithEmail() async {
    if (emailController.text.trim().isEmpty) {
      showMessage("Please enter your email.");
      return;
    }

    if (!emailController.text.contains("@gmail.com")) {
      showMessage("Please enter a valid email.");
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      showMessage("Please enter your password.");
      return;
    }

    if (passwordController.text.trim().length < 6) {
      showMessage("Password must contain minimum 6 characters.");
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      showMessage("Welcome back!", success: true);

      emailController.clear();
      passwordController.clear();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "user-not-found":
          message = "No account found for that email.";
          break;

        case "wrong-password":
          message = "Incorrect password.";
          break;

        case "invalid-credential":
          message = "Incorrect email or password.";
          break;

        case "invalid-email":
          message = "Invalid email address.";
          break;

        case "too-many-requests":
          message = "Too many attempts. Try again later.";
          break;

        case "network-request-failed":
          message = "Check your internet connection.";
          break;

        default:
          message = e.message ?? "Sign in failed.";
      }

      showMessage(message);
    }
  }

  Future<void> registerUser() async {
    if (emailController.text.trim().isEmpty) {
      showMessage("Please enter your email.");
      return;
    }

    if (!emailController.text.contains("@gmail.com")) {
      showMessage("Please enter a valid email.");
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      showMessage("Please enter your password.");
      return;
    }

    final passwordError = validatePasswordStrength(
      passwordController.text.trim(),
    );
    if (passwordError != null) {
      showMessage(passwordError);
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      showMessage("Account created successfully!", success: true);

      emailController.clear();
      passwordController.clear();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "email-already-in-use":
          message = "This email is already registered.";
          break;

        case "weak-password":
          message = "Password is too weak.";
          break;

        case "invalid-email":
          message = "Invalid email address.";
          break;

        case "network-request-failed":
          message = "Check your internet connection.";
          break;

        default:
          message = e.message ?? "Registration failed.";
      }

      showMessage(message);
    }
  }

  // FORGOT PASSWORD

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      showMessage("Please enter your email.");
      return;
    }

    if (!email.contains("@gmail.com")) {
      showMessage("Please enter a valid email.");
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email: email.trim());
      showMessage("Password reset link sent to $email", success: true);
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "user-not-found":
          message = "No account found for that email.";
          break;

        case "invalid-email":
          message = "Invalid email address.";
          break;

        case "network-request-failed":
          message = "Check your internet connection.";
          break;

        default:
          message = e.message ?? "Could not send reset link.";
      }

      showMessage(message);
    }
  }

  // GOOGLE SIGN IN

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithPopup(googleProvider);

      if (!mounted) return;

      showMessage(
        "Welcome ${userCredential.user?.displayName ?? "User"}",
        success: true,
      );

      // Wait so the popup is visible before navigating away
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      showMessage("${e.code}\n${e.message}");
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      showMessage(e.toString());
    }
  }

  void showMessage(String message, {bool success = false}) {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ThemedPopup(
          message: message,
          success: success,
          isDarkMode: isDarkMode,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            child: child,
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  // REGISTER POPUP — opened when "Create Account" is tapped

  void _showRegisterDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _RegisterPopup(
          emailController: emailController,
          passwordController: passwordController,
          isDarkMode: isDarkMode,
          onRegister: () {
            Navigator.of(context, rootNavigator: true).pop();
            registerUser();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            child: child,
          ),
        );
      },
    );
  }

  // FORGOT PASSWORD POPUP — opened when "Forgot password?" is tapped

  void _showForgotPasswordDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ForgotPasswordPopup(
          isDarkMode: isDarkMode,
          onSend: (email) {
            Navigator.of(context, rootNavigator: true).pop();
            resetPassword(email);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);
    final Color dividerColor = AppColors.glassBorder(
      isDarkMode,
      darkAlpha: 0.25,
      lightAlpha: 0.25,
    );
    final Color fieldFill = AppColors.glassSurface(
      isDarkMode,
      lightAlpha: 0.05,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "loginThemeButton",
        mini: true,
        backgroundColor: isDarkMode ? Colors.white : AppColors.deepPurple,
        foregroundColor: isDarkMode ? AppColors.deepPurple : Colors.white,
        elevation: 8,
        onPressed: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDarkMode ? 'images/login_bg.jpg' : 'images/login1_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.65)
                  : Colors.white.withOpacity(0.55),
            ),
          ),

          Row(
            children: [
              Expanded(
                flex: 4,
                child: Center(
                  child: Image.asset(
                    "images/headphone.png",
                    width: size.width * 0.58,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // --- Music wave animation — stays fixed in place, never scrolls ---
              const SizedBox(width: 290, height: 220, child: MusicWave()),

              // --- Login card — only THIS scrolls internally when content
              // overflows (e.g. on shorter screens). ---
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            0,
                            0,
                            0,
                          ).withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            124,
                            126,
                            126,
                          ).withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                      ],
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: size.width * 0.30,
                          height: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.transparent
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // LINE 1 — Welcome to Lizzen
                                AnimatedTextKit(
                                  repeatForever: true,
                                  pause: const Duration(seconds: 1),
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      "Welcome to Lizzen",
                                      speed: const Duration(milliseconds: 80),
                                      textStyle: GoogleFonts.spaceGrotesk(
                                        color: textColor,
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      cursor: "|",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                                // LINE 4 — Email
                                TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: GoogleFonts.spaceGrotesk(
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                    floatingLabelStyle:
                                        GoogleFonts.spaceGrotesk(
                                          color: AppColors.purpleAccent,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        "images/email.svg",
                                        colorFilter: ColorFilter.mode(
                                          textColor,
                                          BlendMode.srcIn,
                                        ),
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: fieldFill,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: AppColors.lavenderAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // LINE 5 — Password
                                TextField(
                                  controller: passwordController,
                                  obscureText: obscureLoginPassword,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    labelStyle: GoogleFonts.spaceGrotesk(
                                      color: textColor,
                                      fontSize: 15,
                                    ),
                                    floatingLabelStyle:
                                        GoogleFonts.spaceGrotesk(
                                          color: AppColors.lavenderAccent,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        CupertinoIcons.lock_rotation_open,
                                        color: textColor,
                                        size: 22,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureLoginPassword
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded,
                                        color: textColor.withOpacity(0.7),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => obscureLoginPassword =
                                            !obscureLoginPassword,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: fieldFill,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        color: AppColors.purpleAccent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // SIGN IN BUTTON — submits the fields above
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: AppColors.loginButtonGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: signInWithEmail,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Sign In",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // LINE 6 — Remember me (left) / Forgot password (right)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: rememberMe,
                                            activeColor: isDarkMode
                                                ? AppColors.lavenderAccent
                                                : AppColors.deepPurple,
                                            side: BorderSide(
                                              color: subTextColor,
                                            ),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            onChanged: (value) => setState(
                                              () => rememberMe = value ?? false,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Remember me",
                                          style: GoogleFonts.spaceGrotesk(
                                            color: subTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        "Forgot password?",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: isDarkMode
                                              ? AppColors.lavenderAccent
                                              : AppColors.deepPurple,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // LINE 7 — OR divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: dividerColor,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        "OR",
                                        style: GoogleFonts.spaceGrotesk(
                                          color: subTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: dividerColor,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // LINE 8 — Sign in with Google
                                MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => isGoogleHovered = true),
                                  onExit: (_) =>
                                      setState(() => isGoogleHovered = false),
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    scale: isGoogleHovered ? 1.03 : 1,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: double.infinity,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDarkMode
                                              ? (isGoogleHovered
                                                    ? AppColors
                                                          .loginButtonGradientDarkHover
                                                    : AppColors
                                                          .loginButtonGradient)
                                              : (isGoogleHovered
                                                    ? AppColors
                                                          .loginButtonGradientLightHover
                                                    : AppColors
                                                          .loginButtonGradientLight),
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          if (isGoogleHovered)
                                            BoxShadow(
                                              color: isDarkMode
                                                  ? AppColors.purpleAccent
                                                        .withOpacity(0.45)
                                                  : AppColors.deepPurple
                                                        .withOpacity(0.30),
                                              blurRadius: isDarkMode ? 25 : 16,
                                              spreadRadius: isDarkMode ? 2 : 1,
                                            ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: signInWithGoogle,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'images/google.svg',
                                              height: 22,
                                              width: 22,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Sign in with Google",
                                              style: GoogleFonts.spaceGrotesk(
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // LINE 9 — Sign in with Apple
                                MouseRegion(
                                  onEnter: (_) =>
                                      setState(() => isAppleHovered = true),
                                  onExit: (_) =>
                                      setState(() => isAppleHovered = false),
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 250),
                                    scale: isAppleHovered ? 1.03 : 1,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: double.infinity,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDarkMode
                                              ? (isAppleHovered
                                                    ? AppColors
                                                          .loginButtonGradientDarkHover
                                                    : AppColors
                                                          .loginButtonGradient)
                                              : (isAppleHovered
                                                    ? AppColors
                                                          .loginButtonGradientLightHover
                                                    : AppColors
                                                          .loginButtonGradientLight),
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          if (isAppleHovered)
                                            BoxShadow(
                                              color: isDarkMode
                                                  ? AppColors.appleGlowDark
                                                        .withOpacity(0.45)
                                                  : AppColors.appleGlowLight
                                                        .withOpacity(0.30),
                                              blurRadius: isDarkMode ? 25 : 16,
                                              spreadRadius: isDarkMode ? 2 : 1,
                                            ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: signInWithGoogle,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.apple,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          size: 30,
                                        ),
                                        label: Text(
                                          "Sign in with Apple",
                                          style: GoogleFonts.spaceGrotesk(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // LINE 10 — Note: don't have an account?
                                Text(
                                  "Note: Don't have an account?",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: subTextColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // LINE 11 — Create Account (right aligned)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showRegisterDialog,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Create Account",
                                      style: GoogleFonts.spaceGrotesk(
                                        color: isDarkMode
                                            ? AppColors.lavenderAccent
                                            : AppColors.deepPurple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterPopup extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isDarkMode;
  final VoidCallback onRegister;

  const _RegisterPopup({
    required this.emailController,
    required this.passwordController,
    required this.isDarkMode,
    required this.onRegister,
  });

  @override
  State<_RegisterPopup> createState() => _RegisterPopupState();
}

class _RegisterPopupState extends State<_RegisterPopup> {
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.isDarkMode;
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color fieldFill = AppColors.glassSurface(
      isDarkMode,
      lightAlpha: 0.05,
    );

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.18)
                          : Colors.black.withOpacity(0.08),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: textColor.withOpacity(0.7),
                            size: 22,
                          ),
                        ),
                      ),
                      Text(
                        "Create your account",
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: widget.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: GoogleFonts.spaceGrotesk(
                            color: textColor,
                            fontSize: 15,
                          ),
                          floatingLabelStyle: GoogleFonts.spaceGrotesk(
                            color: AppColors.purpleAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              "images/email.svg",
                              colorFilter: ColorFilter.mode(
                                textColor,
                                BlendMode.srcIn,
                              ),
                              height: 20,
                              width: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: fieldFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.lavenderAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: widget.passwordController,
                        obscureText: obscurePassword,
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: "Password",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: GoogleFonts.spaceGrotesk(
                            color: textColor,
                            fontSize: 15,
                          ),
                          floatingLabelStyle: GoogleFonts.spaceGrotesk(
                            color: AppColors.lavenderAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              CupertinoIcons.lock_rotation_open,
                              color: textColor,
                              size: 22,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: textColor.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => obscurePassword = !obscurePassword,
                            ),
                          ),
                          filled: true,
                          fillColor: fieldFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.purpleAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PasswordStrengthMeter(
                        password: widget.passwordController.text,
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.loginButtonGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            onPressed: widget.onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Register",
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// PASSWORD STRENGTH METER — 5 segments (one per requirement) plus a
// short label telling the user what's still missing.

class _PasswordStrengthMeter extends StatelessWidget {
  final String password;
  final bool isDarkMode;

  const _PasswordStrengthMeter({
    required this.password,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final missing = passwordRequirementsUnmet(password);
    final metCount = 5 - missing.length;
    final strength = passwordStrengthOf(password);

    late final Color barColor;
    late final String label;
    switch (strength) {
      case PasswordStrength.weak:
        barColor = const Color(0xFFE05656);
        label = "Weak";
        break;
      case PasswordStrength.fair:
        barColor = const Color(0xFFE0A756);
        label = "Fair";
        break;
      case PasswordStrength.good:
        barColor = const Color(0xFFD9C94E);
        label = "Good";
        break;
      case PasswordStrength.strong:
        barColor = const Color(0xFF56C97D);
        label = "Strong";
        break;
    }

    final Color trackColor = isDarkMode
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.08);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final bool filled = index < metCount;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                height: 4,
                decoration: BoxDecoration(
                  color: filled ? barColor : trackColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        if (password.isEmpty)
          Text(
            "Use 8+ characters with upper & lower case, a number and a symbol.",
            style: GoogleFonts.spaceGrotesk(color: subTextColor, fontSize: 12),
          )
        else
          Text(
            missing.isEmpty
                ? "Strong password"
                : "$label · needs ${missing.join(", ")}",
            style: GoogleFonts.spaceGrotesk(
              color: missing.isEmpty ? barColor : subTextColor,
              fontSize: 12,
              fontWeight: missing.isEmpty ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

// FORGOT PASSWORD POPUP WIDGET — single email field + send button.

class _ForgotPasswordPopup extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<String> onSend;

  const _ForgotPasswordPopup({required this.isDarkMode, required this.onSend});

  @override
  State<_ForgotPasswordPopup> createState() => _ForgotPasswordPopupState();
}

class _ForgotPasswordPopupState extends State<_ForgotPasswordPopup> {
  final TextEditingController resetEmailController = TextEditingController();

  @override
  void dispose() {
    resetEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.isDarkMode;
    final Color textColor = AppColors.textPrimary(isDarkMode);
    final Color subTextColor = AppColors.textSecondary(isDarkMode);
    final Color fieldFill = AppColors.glassSurface(
      isDarkMode,
      lightAlpha: 0.05,
    );

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.18)
                          : Colors.black.withOpacity(0.08),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: Icon(
                            Icons.close_rounded,
                            color: textColor.withOpacity(0.7),
                            size: 22,
                          ),
                        ),
                      ),
                      Text(
                        "Reset your password",
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your email and we'll send you a reset link.",
                        style: GoogleFonts.spaceGrotesk(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: resetEmailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.spaceGrotesk(
                          color: textColor,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelStyle: GoogleFonts.spaceGrotesk(
                            color: textColor,
                            fontSize: 15,
                          ),
                          floatingLabelStyle: GoogleFonts.spaceGrotesk(
                            color: AppColors.purpleAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(
                              "images/email.svg",
                              colorFilter: ColorFilter.mode(
                                textColor,
                                BlendMode.srcIn,
                              ),
                              height: 20,
                              width: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: fieldFill,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: AppColors.lavenderAccent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.loginButtonGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                widget.onSend(resetEmailController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Send reset link",
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemedPopup extends StatelessWidget {
  final String message;
  final bool success;
  final bool isDarkMode;

  const _ThemedPopup({
    required this.message,
    required this.success,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = success
        ? (isDarkMode ? AppColors.successDark : AppColors.successLight)
        : (isDarkMode ? AppColors.lavenderAccent : AppColors.deepPurple);

    final Color cardColor = isDarkMode
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.85);

    final Color borderColor = isDarkMode
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: GestureDetector(
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      margin: const EdgeInsets.only(top: 26),
                      padding: const EdgeInsets.fromLTRB(28, 34, 28, 26),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            success ? "Success" : "Heads up",
                            style: GoogleFonts.spaceGrotesk(
                              color: accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              height: 3,
                              width: 46,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: success
                          ? [accent, accent.withOpacity(0.6)]
                          : [accent, accent.withOpacity(0.55)],
                    ),
                    border: Border.all(
                      color: isDarkMode ? Colors.black : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.55),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    success ? Icons.check_rounded : Icons.priority_high_rounded,
                    color: isDarkMode ? Colors.black : Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
