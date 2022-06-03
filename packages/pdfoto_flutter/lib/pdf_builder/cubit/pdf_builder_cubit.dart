import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'pdf_builder_state.dart';

class PdfBuilderCubit extends Cubit<PdfBuilderState> {
  PdfBuilderCubit() : super(PdfBuilderInitial());
}
