import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:since_together/core/constants/app_colors.dart';
import 'package:since_together/features/couple/providers/couple_provider.dart';

class InvitePage extends ConsumerStatefulWidget {
  const InvitePage({super.key});

  @override
  ConsumerState<InvitePage> createState() => _InvitePageState();
}

class _InvitePageState extends ConsumerState<InvitePage> {
  final _codeCtrl = TextEditingController();
  String? _myCode;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingCouple();
  }

  Future<void> _checkExistingCouple() async {
    final repo = ref.read(coupleRepositoryProvider);

    final couple = await repo.getMyCouple();
    if (couple != null && mounted) {
      context.go('/home');
      return;
    }

    final code = await repo.getMyInviteCode();
    if (code != null && mounted) {
      setState(() => _myCode = code);
    }
  }

  Future<void> _generateCode() async {
    setState(() => _loading = true);

    try {
      final code = await ref.read(coupleRepositoryProvider).createInviteCode();
      setState(() => _myCode = code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        debugPrint(e.toString());
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _joinWithCode() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      await ref
          .read(coupleRepositoryProvider)
          .joinWithCode(_codeCtrl.text.trim().toUpperCase());

      ref.invalidate(coupleProvider);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }

      debugPrint(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('💕', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),

              const Text(
                'Connect with your partner',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Share your code or enter your partner's code",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your Invite Code',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_myCode != null) ...[
                      Text(
                        _myCode!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _myCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Code copied!')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                      ),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _generateCode,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Generate My Code',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 28),

              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Enter Partner's Code",
                  prefixIcon: Icon(Icons.favorite_outline),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _joinWithCode,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Connect 💕',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
