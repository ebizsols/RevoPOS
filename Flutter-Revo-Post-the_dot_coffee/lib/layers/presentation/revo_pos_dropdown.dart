import 'package:flutter/material.dart';
import 'package:revo_pos/core/constant/constants.dart';

class RevoPosDropdown extends StatelessWidget {
  final String? hint;
  final Color? color;
  final Color? borderColor;
  final List items;
  final dynamic value;
  final DropdownMenuItem Function(dynamic) itemBuilder;
  final Function(dynamic) onChanged;

  const RevoPosDropdown({Key? key, this.hint, required this.items, this.value, required this.onChanged, required this.itemBuilder, this.color, this.borderColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color ?? colorWhite,
          border: Border.all(
            color: borderColor ?? colorDisabled,
          ),
        ),
        child: DropdownButton(
          isExpanded: true,
          hint: Text(
            hint ?? "",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: colorDisabled
            ),
          ),
          value: value,
          items: items.map(itemBuilder).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
