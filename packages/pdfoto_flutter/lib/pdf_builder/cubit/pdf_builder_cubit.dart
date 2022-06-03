import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_selector/file_selector.dart';
import 'package:pdfoto/pdfoto.dart';
import 'package:file_selector/file_selector.dart' as fs;

part 'pdf_builder_state.dart';

class PdfBuilderCubit extends Cubit<PdfBuilderState> {
  PdfBuilderCubit() : super(const PdfBuilderState());

  Future<void> openFile() async {
    final res = await fs.openFiles(
      acceptedTypeGroups: [
        fs.XTypeGroup(
          label: 'images',
          extensions: Pdfoto.validPhotoExtensions
              .map((e) => e.toLowerCase()..replaceAll('.', ''))
              .toList(),
        )
      ],
    );
    if (res.isEmpty) {
      return;
    }

    // final pdf = await const Pdfoto().createPdfFromFiles(files: res);
    // emit(state.copyWith(renderedPdf: pdf));
    emit(state.copyWith(files: [...state.files, ...res]));
  }

  void removeFile(XFile file) {
    emit(state.copyWith(files: state.files.where((f) => f != file).toList()));
  }

  // Future<void> savePdf() async {
  //   const mimeType = 'application/pdf';

  //   // May be empty, indicating the file should simply be saved.
  //   final savePath = await fs.getSavePath(
  //     suggestedName: 'photos.pdf',
  //     confirmButtonText: 'Save',
  //     acceptedTypeGroups: [
  //       fs.XTypeGroup(
  //         label: 'pdf',
  //         extensions: ['pdf'],
  //       )
  //     ],
  //   );
  // }
}
