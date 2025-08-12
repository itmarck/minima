import 'package:flutter/material.dart';
import 'package:minima/specification.dart';

import 'bar.dart';

class DesktopSpecification extends Specification {
  @override
  PreferredSizeWidget? appBar(context) {
    return const Bar();
  }
}
