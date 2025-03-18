import 'package:flutter/material.dart';

class AdditionalInformationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const AdditionalInformationItem({
        super.key,
        required this.icon,
        required this.label,
        required this.value
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  label,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
