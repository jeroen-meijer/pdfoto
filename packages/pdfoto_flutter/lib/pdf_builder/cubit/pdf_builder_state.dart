part of 'pdf_builder_cubit.dart';

enum PdfBuilderStatus { initial, loading, success, failure }

class PdfBuilderState extends Equatable {
  const PdfBuilderState({
    this.status = PdfBuilderStatus.initial,
    this.files = const [],
  });

  final PdfBuilderStatus status;
  final List<fs.XFile> files;

  @override
  List<Object?> get props => [status, files];

  PdfBuilderState copyWith({
    PdfBuilderStatus? status,
    List<fs.XFile>? files,
  }) {
    return PdfBuilderState(
      status: status ?? this.status,
      files: files ?? this.files,
    );
  }
}
