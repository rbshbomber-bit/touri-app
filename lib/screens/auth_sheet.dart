import 'package:flutter/material.dart';
import '../theme/touri_colors.dart';

/// 로그인/회원가입 진입점. MVP에서는 소셜 로그인 준비 중 안내만 제공.
class AuthSheet extends StatelessWidget {
  const AuthSheet({super.key});

  void _soon(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인은 Touri+에서 곧 열릴게 ♡'),
        backgroundColor: TouriColors.cocoaDark,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TouriColors.warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        10,
        22,
        22 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: TouriColors.softPink,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: TouriColors.cloudPink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('♡', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '토우리 계정',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: TouriColors.cocoaDark,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '다이어리와 수집함을 안전하게 보관할 준비 중이야.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TouriColors.cocoa,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SocialButton(
            label: 'Google로 계속하기',
            mark: 'G',
            color: Colors.white,
            textColor: TouriColors.cocoaDark,
            borderColor: TouriColors.cloudPink,
            onTap: () => _soon(context, 'Google'),
          ),
          const SizedBox(height: 10),
          _SocialButton(
            label: '네이버로 계속하기',
            mark: 'N',
            color: const Color(0xFF03C75A),
            textColor: Colors.white,
            onTap: () => _soon(context, '네이버'),
          ),
          const SizedBox(height: 10),
          _SocialButton(
            label: '카카오로 계속하기',
            mark: 'K',
            color: const Color(0xFFFFE812),
            textColor: const Color(0xFF3C1E1E),
            onTap: () => _soon(context, '카카오'),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => _soon(context, '이메일 회원가입'),
            child: const Text(
              '이메일로 회원가입',
              style: TextStyle(
                color: TouriColors.touriPink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '지금은 이 기기 안에만 저장돼. 정식 로그인은 백업·동기화와 함께 열릴 예정이야.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TouriColors.dim,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String mark;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.mark,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor ?? Colors.transparent),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  mark,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: textColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
