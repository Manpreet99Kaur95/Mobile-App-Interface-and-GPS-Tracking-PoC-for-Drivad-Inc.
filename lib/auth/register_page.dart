import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../language_provider.dart';
import 'auth_service.dart';
import 'login_page.dart';

enum UserRole { driver, advertiser, vendor }

class RegisterPage extends StatefulWidget {
  final AuthService auth;
  const RegisterPage({super.key, required this.auth});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserRole _role = UserRole.driver;

  // form state
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return 'driver';
      case UserRole.advertiser:
        return 'advertiser';
      case UserRole.vendor:
        return 'vendor';
    }
  }

  String? _validateEmail(String? v, LanguageProvider lp) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return lp.translate('email_required');
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) return lp.translate('invalid_email');
    return null;
  }

  String? _validatePassword(String? v, LanguageProvider lp) {
    final value = (v ?? "");
    if (value.isEmpty) return lp.translate('password_required');
    if (value.length < 6) return lp.translate('password_too_short');
    return null;
  }

  String? _validateConfirm(String? v, LanguageProvider lp) {
    final value = (v ?? "");
    if (value.isEmpty) return lp.translate('confirm_password_required');
    if (value != _password.text) return lp.translate('passwords_no_match');
    return null;
  }

  Future<void> _register(LanguageProvider lp) async {
    FocusScope.of(context).unfocus();
    setState(() => _emailError = null);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    try {
      await widget.auth.register(
        email: _email.text.trim(),
        password: _password.text,
        role: _roleToString(_role),
      );
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      if (msg.contains("email-already-in-use")) {
        setState(() => _emailError = lp.translate('email_in_use'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${lp.translate('signup_failed')}: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = Provider.of<LanguageProvider>(context);
    final isEn = lp.lang == "en";

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: isMobile ? double.infinity : 430,
                  child: _AuthCard(
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          const Icon(Icons.directions_car, size: 42),
                          const SizedBox(height: 10),
                          Text(
                            "DrivAd",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lp.translate('drive_advertise_earn'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Pill(
                                label: "English",
                                selected: isEn,
                                onTap: () => lp.setLanguage("en"),
                              ),
                              const SizedBox(width: 8),
                              _Pill(
                                label: "Français",
                                selected: !isEn,
                                onTap: () => lp.setLanguage("fr"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          _SegmentTabs(
                            leftLabel: lp.translate('login'),
                            rightLabel: lp.translate('signup'),
                            leftSelected: false,
                            onLeftTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginPage(auth: widget.auth),
                                ),
                              );
                            },
                            onRightTap: () {},
                          ),

                          const SizedBox(height: 14),

                          Text(
                            lp.translate('select_role'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: _RoleCard(
                                  icon: Icons.directions_car,
                                  label: lp.translate('driver'),
                                  selected: _role == UserRole.driver,
                                  onTap: () =>
                                      setState(() => _role = UserRole.driver),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RoleCard(
                                  icon: Icons.campaign,
                                  label: lp.translate('advertiser'),
                                  selected: _role == UserRole.advertiser,
                                  onTap: () => setState(
                                    () => _role = UserRole.advertiser,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RoleCard(
                                  icon: Icons.sell,
                                  label: lp.translate('vendor'),
                                  selected: _role == UserRole.vendor,
                                  onTap: () =>
                                      setState(() => _role = UserRole.vendor),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _LabeledField(
                                  label: lp.translate('email'),
                                  child: TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: "your@email.com",
                                      errorText: _emailError,
                                    ),
                                    validator: (v) => _validateEmail(v, lp),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: lp.translate('password'),
                                  child: TextFormField(
                                    controller: _password,
                                    obscureText: _obscurePass,
                                    decoration: InputDecoration(
                                      hintText: "•••••••",
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePass = !_obscurePass,
                                        ),
                                        icon: Icon(
                                          _obscurePass
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    validator: (v) => _validatePassword(v, lp),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _LabeledField(
                                  label: lp.translate('confirm_password'),
                                  child: TextFormField(
                                    controller: _confirm,
                                    obscureText: _obscureConfirm,
                                    onFieldSubmitted: (_) =>
                                        _loading ? null : _register(lp),
                                    decoration: InputDecoration(
                                      hintText: "•••••••",
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    validator: (v) => _validateConfirm(v, lp),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          _PrimaryButton(
                            label: lp.translate('signup'),
                            loading: _loading,
                            onTap: _loading ? null : () => _register(lp),
                          ),

                          const SizedBox(height: 14),
                          _OrDivider(label: lp.translate('or')),
                          const SizedBox(height: 12),

                          _SocialButton(
                            icon: Icons.g_mobiledata,
                            label: lp.translate('continue_google'),
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _SocialButton(
                            icon: Icons.apple,
                            label: lp.translate('continue_apple'),
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _SocialButton(
                            icon: Icons.facebook,
                            label: lp.translate('continue_facebook'),
                            onTap: () {},
                          ),
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
}

class _AuthCard extends StatelessWidget {
  final Widget child;
  const _AuthCard({required this.child});
  @override
  Widget build(BuildContext context) => Material(
    elevation: 0,
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    ),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(999),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: selected ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    ),
  );
}

class _SegmentTabs extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;
  const _SegmentTabs({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftSelected,
    required this.onLeftTap,
    required this.onRightTap,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: 38,
    decoration: BoxDecoration(
      color: const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.black12),
    ),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onLeftTap,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: leftSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                leftLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onRightTap,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: leftSelected ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                rightLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final border = selected ? Colors.blue : Colors.black12;
    final bg = selected ? Colors.blue.withValues(alpha: 0.08) : Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
          color: bg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF4F5F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            errorStyle: const TextStyle(height: 1.1, fontSize: 12),
          ),
        ),
        child: child,
      ),
    ],
  );
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF0B0F1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider(height: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const Expanded(child: Divider(height: 1)),
    ],
  );
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Colors.black12),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
    ),
  );
}
