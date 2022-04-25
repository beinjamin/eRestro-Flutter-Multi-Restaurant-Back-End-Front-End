import 'package:erestro/features/helpAndSupport/helpAndSupportRepository.dart';
import 'package:erestro/features/helpAndSupport/ticketModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class EditTicketState {}

class EditTicketInitial extends EditTicketState {}

class EditTicketProgress extends EditTicketState {}

class EditTicketSuccess extends EditTicketState {
  final TicketModel ticketModel;

  EditTicketSuccess(this.ticketModel);
}

class EditTicketFailure extends EditTicketState {
  final String errorCode;

  EditTicketFailure(this.errorCode);
}

class EditTicketCubit extends Cubit<EditTicketState> {
  final HelpAndSupportRepository _helpAndSupportRepository;

  EditTicketCubit(this._helpAndSupportRepository) : super(EditTicketInitial());

  void fetchEditTicket(String? ticketId, String? ticketTypeId, String? subject, String? email, String? description, String? userId, String? status) {
    emit(EditTicketProgress());
    _helpAndSupportRepository.getEditTicket(ticketId, ticketTypeId, subject, email, description, userId, status).then((value) => emit(EditTicketSuccess(value))).catchError((e) {
      emit(EditTicketFailure(e.toString()));
    });
  }
}