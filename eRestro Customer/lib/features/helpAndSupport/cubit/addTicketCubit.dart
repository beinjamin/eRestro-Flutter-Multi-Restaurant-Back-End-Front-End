import 'package:erestro/features/helpAndSupport/helpAndSupportRepository.dart';
import 'package:erestro/features/helpAndSupport/ticketModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddTicketState {}

class AddTicketInitial extends AddTicketState {}

class AddTicketProgress extends AddTicketState {}

class AddTicketSuccess extends AddTicketState {
  final TicketModel ticketModel;

  AddTicketSuccess(this.ticketModel);
}

class AddTicketFailure extends AddTicketState {
  final String errorCode;

  AddTicketFailure(this.errorCode);
}

class AddTicketCubit extends Cubit<AddTicketState> {
  final HelpAndSupportRepository _helpAndSupportRepository;

  AddTicketCubit(this._helpAndSupportRepository) : super(AddTicketInitial());

  void fetchAddTicket(String? ticketTypeId, String? subject, String? email, String? description, String? userId) {
    emit(AddTicketProgress());
    _helpAndSupportRepository.getAddTicket(ticketTypeId, subject, email, description, userId).then((value) => emit(AddTicketSuccess(TicketModel()))).catchError((e) {
      emit(AddTicketFailure(e.toString()));
    });
  }
}