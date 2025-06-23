import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/services.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSilentMode = false;
  bool _isHighContrast = false;
  late AnimationController _waveController;
  late AnimationController _iconController;
  late Animation<double> _waveAnimation;
  late Animation<double> _iconAnimation;

  // Wellness quotes for preloading
  final List<String> _wellnessQuotes = [
    "Every woman's journey is unique. You're doing amazing.",
    "Small steps lead to big changes. Be patient with yourself.",
    "Your feelings are valid. You're not alone in this.",
    "Self-care isn't selfish. It's essential.",
    "You have the strength within you to navigate this journey.",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAccessibilitySettings();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
  }

  void _checkAccessibilitySettings() {
    // Check system accessibility settings
    final mediaQuery = MediaQuery.of(context);
    final textScaleFactor = mediaQuery.textScaleFactor;
    final boldText = mediaQuery.boldText;

    if (textScaleFactor > 1.2 || boldText) {
      setState(() {
        _isHighContrast = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _waveController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Silent mode - show neutral screen
    if (_isSilentMode) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notes,
                size: 48,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 24 * textScaleFactor,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            _showEmpatheticError(state.message);
          } else if (state is AuthLoading) {
            setState(() => _isLoading = true);
          }
        },
        child: AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: _buildAnimatedGradient(),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isTablet ? 60 : 40),
                          _buildHeader()
                              .animate()
                              .fadeIn(duration: 800.ms)
                              .slideY(begin: -0.3, curve: Curves.easeOutCubic),
                          SizedBox(height: isTablet ? 32 : 24),
                          _buildWelcomeMessage()
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 800.ms)
                              .slideY(begin: -0.2, curve: Curves.easeOutCubic),
                          SizedBox(height: isTablet ? 48 : 32),
                          _buildLoginForm()
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 800.ms)
                              .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                          const SizedBox(height: 24),
                          _buildForgotPassword()
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 600.ms),
                          const SizedBox(height: 32),
                          _buildLoginButton()
                              .animate()
                              .fadeIn(delay: 1000.ms, duration: 600.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: 24),
                          _buildSignupLink()
                              .animate()
                              .fadeIn(delay: 1200.ms, duration: 600.ms),
                          const SizedBox(height: 16),
                          _buildSilentModeToggle()
                              .animate()
                              .fadeIn(delay: 1400.ms, duration: 600.ms),
                          if (_isLoading) ...[
                            const SizedBox(height: 24),
                            _buildPreloadingContent()
                                .animate()
                                .fadeIn(delay: 1600.ms, duration: 800.ms),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  LinearGradient _buildAnimatedGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.background,
        AppColors.background.withOpacity(0.8),
        AppColors.primary.withOpacity(0.1 * _waveAnimation.value),
        AppColors.secondary.withOpacity(0.05 * _waveAnimation.value),
        AppColors.background,
      ],
      stops: [
        0.0,
        0.3,
        0.5 + (0.1 * _waveAnimation.value),
        0.7 + (0.1 * _waveAnimation.value),
        1.0,
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.softPinkGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedBuilder(
              animation: _iconAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * _iconAnimation.value),
                  child: Image.asset(
                    'assets/logo-removebg-preview.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Welcome Back',
          style: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.psychology_rounded,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re not alone in this journey',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'re here to support you every step of the way',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters long';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/forgot-password');
        },
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                ),
              )
            : Text(
                'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSilentModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.visibility_off,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _isSilentMode = !_isSilentMode;
            });
            if (_isSilentMode) {
              HapticFeedback.lightImpact();
            }
          },
          child: Text(
            'Quick Hide',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreloadingContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            _wellnessQuotes[
                DateTime.now().millisecond % _wellnessQuotes.length],
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEmpatheticError(String originalError) {
    String empatheticMessage;

    if (originalError.contains('password')) {
      empatheticMessage =
          "Looks like something's off with your password. Let's try again together.";
    } else if (originalError.contains('email')) {
      empatheticMessage =
          "We couldn't find that email address. Double-check and let's try again.";
    } else if (originalError.contains('network')) {
      empatheticMessage =
          "Connection seems a bit slow right now. Let's try again in a moment.";
    } else {
      empatheticMessage =
          "Something unexpected happened. Don't worry, let's try again.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                empatheticMessage,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }
}
