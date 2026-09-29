import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PaymentOptionCard extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const PaymentOptionCard({super.key, required this.label, required this.onTap});

  @override
  State<PaymentOptionCard> createState() => _PaymentOptionCardState();
}

class _PaymentOptionCardState extends State<PaymentOptionCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 110,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.basil : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _pressed ? AppColors.matcha : AppColors.border,
            width: 1.4,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: AppColors.matcha.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 120),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _pressed ? Colors.white : AppColors.dark,
          ),
          textAlign: TextAlign.center,
          child: Text(widget.label),
        ),
      ),
    );
  }
}
