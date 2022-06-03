import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfoto_flutter/pdf_builder/pdf_builder.dart';

class PdfBuilderView extends StatelessWidget {
  const PdfBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PdfBuilderCubit>();
    return Container(
      child: null,
    );
  }
}
