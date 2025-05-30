import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorHeaderSection extends ConsumerWidget{
  const DoctorHeaderSection({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 200,
      color: Colors.blueGrey[500],
    );
  }
}