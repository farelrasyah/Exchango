import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/Theme.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const AmountInput({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Text(
              'Amount',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
            decoration: InputDecoration(
              hintText: '0.00',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixIcon: Icon(
                Icons.pending_outlined,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
            ),
            onChanged: onChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        ],
      ),
    );
  }
}
