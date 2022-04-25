import 'package:erestro/features/address/addressRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteAddressState {}

class DeleteAddressInitial extends DeleteAddressState {}

class DeleteAddressProgress extends DeleteAddressState {}

class DeleteAddressSuccess extends DeleteAddressState {
  final String id;

  DeleteAddressSuccess(this.id);
}

class DeleteAddressFailure extends DeleteAddressState {
  final String errorCode;

  DeleteAddressFailure(this.errorCode);
}

class DeleteAddressCubit extends Cubit<DeleteAddressState> {
  final AddressRepository _addressRepository;

  DeleteAddressCubit(this._addressRepository) : super(DeleteAddressInitial());

  void fetchDeleteAddress(String? id) {
    emit(DeleteAddressProgress());
    _addressRepository.getDeleteAddress(id).then((value)  {
      emit(DeleteAddressSuccess(id!));
    }).catchError((e) {
      emit(DeleteAddressFailure(e.toString()));
    });
  }
}