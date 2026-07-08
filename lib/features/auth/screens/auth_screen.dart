import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/kid_card.dart';
import '../auth_controller.dart';
import '../google_sign_in_helper.dart';

/// Pantalla de autenticación (mirror móvil de AuthPage.jsx):
/// login estudiante/visitante, registro de visitante y Google Sign-In.
class AuthScreen extends ConsumerStatefulWidget {
  final String initialMode; // 'login' | 'register'
  const AuthScreen({super.key, this.initialMode = 'login'});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isRegister = widget.initialMode == 'register';
  String _userType = 'student'; // student | guest
  bool _loading = false;
  String? _error;
  bool _registerSuccess = false;

  // Login estudiante
  final _listNumber = TextEditingController();
  final _studentPassword = TextEditingController();
  String? _grade;

  // Login visitante
  final _guestUsername = TextEditingController();
  final _guestPassword = TextEditingController();

  // Registro visitante
  final _regFirstname = TextEditingController();
  final _regLastname = TextEditingController();
  final _regEmail = TextEditingController();
  final _regUsername = TextEditingController();
  final _regPassword = TextEditingController();

  static const _grades = [
    ('1', '1º Primero'),
    ('2', '2º Segundo'),
    ('3', '3º Tercero'),
    ('4', '4º Cuarto'),
    ('5', '5º Quinto'),
    ('6', '6º Sexto'),
  ];

  @override
  void dispose() {
    for (final c in [
      _listNumber,
      _studentPassword,
      _guestUsername,
      _guestPassword,
      _regFirstname,
      _regLastname,
      _regEmail,
      _regUsername,
      _regPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitLogin() async {
    if (_userType == 'student') {
      final listNumber = int.tryParse(_listNumber.text.trim());
      if (listNumber == null) {
        setState(() => _error = 'Por favor ingresa tu número de lista');
        return;
      }
      if (_studentPassword.text.isEmpty) {
        setState(() => _error = 'Por favor ingresa tu contraseña');
        return;
      }
      if (_grade == null) {
        setState(() => _error = 'Por favor selecciona tu grado');
        return;
      }
      await _run(() => ref.read(authControllerProvider.notifier).loginStudent(
            listNumber: listNumber,
            password: _studentPassword.text,
            grade: int.parse(_grade!),
          ));
    } else {
      if (_guestUsername.text.trim().isEmpty || _guestPassword.text.isEmpty) {
        setState(() => _error = 'Por favor completa todos los campos');
        return;
      }
      await _run(() => ref.read(authControllerProvider.notifier).loginVisitor(
            username: _guestUsername.text.trim(),
            password: _guestPassword.text,
          ));
    }
  }

  Future<void> _submitRegister() async {
    final email = _regEmail.text.trim();
    final emailOk = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (_regFirstname.text.trim().isEmpty ||
        _regLastname.text.trim().isEmpty ||
        _regUsername.text.trim().isEmpty ||
        _regPassword.text.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos');
      return;
    }
    if (!emailOk) {
      setState(() => _error = 'Ingresa un correo electrónico válido');
      return;
    }
    await _run(() async {
      await ref.read(authServiceProvider).registerVisitor(
            firstname: _regFirstname.text.trim(),
            lastname: _regLastname.text.trim(),
            email: email,
            password: _regPassword.text,
            username: _regUsername.text.trim(),
          );
      setState(() => _registerSuccess = true);
    });
  }

  Future<void> _googleSignIn() async {
    final account = await GoogleSignInHelper.signIn();
    if (account == null) return;

    await _run(() async {
      try {
        await ref
            .read(authControllerProvider.notifier)
            .loginWithGoogle(account.idToken);
      } on ApiException catch (e) {
        // 409: el email no está registrado → completar registro
        if (e.status == 409) {
          if (!mounted) return;
          await _showGoogleRegisterDialog(account, e.responseData);
        } else {
          rethrow;
        }
      }
    });
  }

  Future<void> _showGoogleRegisterDialog(
      GoogleAccountInfo account, Map<String, dynamic>? data) async {
    final names = account.displayName.split(' ');
    final firstname = TextEditingController(
        text: (data?['firstName'] ?? data?['firstname'] ?? names.firstOrNull) as String? ?? '');
    final lastname = TextEditingController(
        text: (data?['lastName'] ?? data?['lastname']) as String? ??
            (names.length > 1 ? names.sublist(1).join(' ') : ''));
    final username = TextEditingController();
    final password = TextEditingController();
    final email = (data?['email'] as String?) ?? account.email;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.kidCard)),
        title: const Text('Completa tu registro',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(email,
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                  controller: firstname,
                  decoration: const InputDecoration(hintText: 'Nombre')),
              const SizedBox(height: 10),
              TextField(
                  controller: lastname,
                  decoration: const InputDecoration(hintText: 'Apellido')),
              const SizedBox(height: 10),
              TextField(
                  controller: username,
                  decoration:
                      const InputDecoration(hintText: 'Nombre de usuario')),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Contraseña'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Registrarme'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).registerWithGoogle(
            idToken: account.idToken,
            firstname: firstname.text.trim(),
            lastname: lastname.text.trim(),
            email: email,
            password: password.text,
            username: username.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/welcome')),
        title: Text(_isRegister ? 'Crear cuenta' : '¡Hola de nuevo!'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: KidCard(
            padding: const EdgeInsets.all(20),
            child: _registerSuccess
                ? _buildRegisterSuccess()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModeSwitch(),
                      const SizedBox(height: 20),
                      if (!_isRegister) ...[
                        _buildRoleSelector(),
                        const SizedBox(height: 20),
                        if (_userType == 'student')
                          _buildStudentLogin()
                        else
                          _buildGuestLogin(),
                      ] else
                        _buildRegisterForm(),
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        _buildError(),
                      ],
                      const SizedBox(height: 20),
                      KidButton(
                        label: _isRegister ? 'Crear mi cuenta' : 'Entrar',
                        icon: _isRegister ? Icons.person_add : Icons.login,
                        expanded: true,
                        loading: _loading,
                        onPressed:
                            _isRegister ? _submitRegister : _submitLogin,
                      ),
                      if (!_isRegister && _userType == 'guest') ...[
                        const SizedBox(height: 16),
                        _buildGoogleButton(),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (isRegister, label) in [(false, 'Entrar'), (true, 'Registro')])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(label),
              selected: _isRegister == isRegister,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: _isRegister == isRegister
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
              onSelected: (_) => setState(() {
                _isRegister = isRegister;
                _error = null;
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        for (final (type, icon, label) in [
          ('student', Icons.face, 'Niño'),
          ('guest', Icons.person, 'Visitante'),
        ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => setState(() {
                  _userType = type;
                  _error = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _userType == type
                        ? const Color(0xFFFFF3E9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: _userType == type
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(icon,
                          size: 34,
                          color: _userType == type
                              ? AppColors.primary
                              : AppColors.textLight),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _userType == type
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStudentLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Tu número de lista'),
        TextField(
          controller: _listNumber,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Ej. 12',
            prefixIcon: Icon(Icons.tag),
          ),
        ),
        const SizedBox(height: 14),
        _label('Tu grado escolar'),
        DropdownButtonFormField<String>(
          initialValue: _grade,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.school)),
          hint: const Text('Selecciona tu grado'),
          items: [
            for (final (value, label) in _grades)
              DropdownMenuItem(value: value, child: Text(label)),
          ],
          onChanged: (v) => setState(() => _grade = v),
        ),
        const SizedBox(height: 14),
        _label('Contraseña'),
        TextField(
          controller: _studentPassword,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Tu contraseña secreta',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nombre de usuario'),
        TextField(
          controller: _guestUsername,
          decoration: const InputDecoration(
            hintText: 'Ej. visitante123',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 14),
        _label('Contraseña'),
        TextField(
          controller: _guestPassword,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Tu contraseña',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nombre'),
        TextField(
            controller: _regFirstname,
            decoration: const InputDecoration(
                hintText: 'Tu nombre', prefixIcon: Icon(Icons.badge))),
        const SizedBox(height: 14),
        _label('Apellido'),
        TextField(
            controller: _regLastname,
            decoration: const InputDecoration(
                hintText: 'Tu apellido', prefixIcon: Icon(Icons.badge))),
        const SizedBox(height: 14),
        _label('Correo electrónico'),
        TextField(
            controller: _regEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
                hintText: 'correo@ejemplo.com',
                prefixIcon: Icon(Icons.mail))),
        const SizedBox(height: 14),
        _label('Nombre de usuario'),
        TextField(
            controller: _regUsername,
            decoration: const InputDecoration(
                hintText: 'Ej. visitante123',
                prefixIcon: Icon(Icons.person))),
        const SizedBox(height: 14),
        _label('Contraseña'),
        TextField(
            controller: _regPassword,
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'Crea una contraseña',
                prefixIcon: Icon(Icons.lock))),
      ],
    );
  }

  Widget _buildRegisterSuccess() {
    return Column(
      children: [
        Image.asset('assets/coyote/celebracion.webp', height: 140),
        const SizedBox(height: 12),
        const Text(
          '¡Cuenta creada!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Te enviamos un correo de verificación.\nAbre el enlace para activar tu cuenta y después inicia sesión.',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        KidButton(
          label: 'Ir a iniciar sesión',
          icon: Icons.login,
          expanded: true,
          onPressed: () => setState(() {
            _registerSuccess = false;
            _isRegister = false;
            _userType = 'guest';
          }),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _googleSignIn,
      icon: const Text('G',
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF4285F4))),
      label: const Text(
        'Continuar con Google',
        style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: AppColors.textMain),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.input),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 2),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.primaryBlue,
          ),
        ),
      );
}
