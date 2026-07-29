import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../shared/widgets/kid_card.dart';
import '../../../shared/widgets/states.dart';

/// Verificación de email dentro de la app (mirror de VerifyEmailPage.jsx).
/// Se abre desde el deep link `.../verify-email?token=...`.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

enum _Status { loading, success, error }

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  _Status _status = _Status.loading;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() {
        _status = _Status.error;
        _message = 'El enlace de verificación no es válido o está incompleto.';
      });
      return;
    }
    setState(() => _status = _Status.loading);
    try {
      await ref.read(authServiceProvider).verifyEmail(token);
      if (!mounted) return;
      setState(() {
        _status = _Status.success;
        _message =
            '¡Tu correo fue verificado! Ya puedes iniciar sesión con tu cuenta.';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.error;
        _message = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = _Status.error;
        _message = 'No se pudo verificar tu correo. Intenta más tarde.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Verificar correo')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: switch (_status) {
            _Status.loading =>
              const LoadingState(message: 'Verificando tu correo...'),
            _Status.success => _buildResult(
                icon: Icons.mark_email_read,
                color: AppColors.success,
                title: '¡Registro confirmado!',
              ),
            _Status.error => _buildResult(
                icon: Icons.error_outline,
                color: AppColors.error,
                title: 'No pudimos verificar',
                showRetry: true,
              ),
          },
        ),
      ),
    );
  }

  Widget _buildResult({
    required IconData icon,
    required Color color,
    required String title,
    bool showRetry = false,
  }) {
    return KidCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          KidButton(
            label: 'Ir a iniciar sesión',
            icon: Icons.login,
            expanded: true,
            onPressed: () => context.go('/auth?mode=login'),
          ),
          if (showRetry) ...[
            const SizedBox(height: 10),
            KidBackButton(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: _verify,
            ),
          ],
        ],
      ),
    );
  }
}
