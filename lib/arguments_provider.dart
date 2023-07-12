
import 'package:flutter/material.dart';

abstract class ArgumentsProvider extends Widget {
  const ArgumentsProvider({super.key});

  //做參數序列化，value只能是基本型別
  Map<String, dynamic> getArguments();
}

class ArgumentKey {
  static const String id = 'id';
}