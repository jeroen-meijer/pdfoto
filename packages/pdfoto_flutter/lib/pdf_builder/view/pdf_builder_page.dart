import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfoto_flutter/pdf_builder/pdf_builder.dart';

class PdfBuilderPage extends StatelessWidget {
  const PdfBuilderPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PdfBuilderCubit(),
      child: const PdfBuilderView(),
    );
  }
}
