import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfoto/pdfoto.dart';
import 'package:pdfoto_flutter/pdf_builder/pdf_builder.dart';
import 'package:printing/printing.dart';

class PdfBuilderView extends StatelessWidget {
  const PdfBuilderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.read<PdfBuilderCubit>().savePdf();
      //   },
      //   child: const Icon(Icons.download),
      // ),
      body: Column(
        children: const [
          Expanded(
            flex: 4,
            child: _PdfPreview(),
          ),
          Divider(),
          Expanded(
            child: Center(
              child: _FileSelector(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPreview extends StatelessWidget {
  const _PdfPreview();

  @override
  Widget build(BuildContext context) {
    final files = context.select((PdfBuilderCubit cubit) => cubit.state.files);
    return PdfPreview(
      key: Key('pdfPreview_${files.map((f) => f.path).join('+')}'),
      maxPageWidth: 800,
      build: (pageFormat) => const Pdfoto().createPdfFromFiles(
        files: files,
        pageFormat: pageFormat,
      ),
    );
  }
}

class _FileSelector extends StatelessWidget {
  const _FileSelector();

  @override
  Widget build(BuildContext context) {
    final files = context.select((PdfBuilderCubit cubit) => cubit.state.files);

    return Row(
      children: [
        const SizedBox(width: 8),
        for (final file in files)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: _PhotoPreview(file: file),
          ),
        if (files.isEmpty) const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            context.read<PdfBuilderCubit>().openFile();
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: () {
        context.read<PdfBuilderCubit>().removeFile(file);
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: FutureBuilder<Uint8List>(
                    key: Key('photoPreview_${file.path}'),
                    future: file.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Icon(Icons.error);
                      }
                      if (!snapshot.hasData) {
                        return const Icon(Icons.hourglass_empty);
                      }

                      return Image.memory(snapshot.data!);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
