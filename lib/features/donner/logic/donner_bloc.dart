import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'donner_event.dart';
part 'donner_state.dart';

class DonnerBloc extends Bloc<DonnerEvent, DonnerState> {
  DonnerBloc() : super(DonnerInitial()) {
    on<DonnerEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
