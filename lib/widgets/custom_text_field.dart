import 'package:flutter/material.dart';
import 'package:multiinventario/models/unidad.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Unidad? unidad;
  final bool isPrice;
  final bool isRequired;
  final bool readOnly;
  final Function(String)? onChanged;
  final Function()? onTap;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.unidad,
    this.isPrice = false,
    this.isRequired = false,
    this.readOnly = false,
    this.onChanged,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            onTap: onTap,
            onChanged: onChanged,
            readOnly: readOnly,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              hintText: isPrice ? '0.00' : null,
              prefixText: isPrice ? 'S/ ' : null,
              suffixText: isPrice ? '' : (unidad?.tipoUnidad ?? ''),
              suffixStyle: TextStyle(color: Colors.grey.shade600),
              border: const OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior
                  .auto, // No queremos que se levante por defecto
              labelText: isRequired ? '$label *' : label,
            ),
          ),
        ],
      ),
    );
  }
}
