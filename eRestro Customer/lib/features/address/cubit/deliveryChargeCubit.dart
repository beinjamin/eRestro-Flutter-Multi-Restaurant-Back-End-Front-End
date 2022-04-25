import 'package:erestro/features/address/addressRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../addressLocalDataSource.dart';

abstract class DeliveryChargeState {}

class DeliveryChargeInitial extends DeliveryChargeState {}

class DeliveryChargeProgress extends DeliveryChargeState {}

class DeliveryChargeSuccess extends DeliveryChargeState {
  final String? userId, addressId, delivaryCharge;

  DeliveryChargeSuccess(this.userId, this.addressId, this.delivaryCharge);
}

class DeliveryChargeFailure extends DeliveryChargeState {
  final String errorCode;

  DeliveryChargeFailure(this.errorCode);
}

class DeliveryChargeCubit extends Cubit<DeliveryChargeState> {
  final AddressRepository _addressRepository;

  DeliveryChargeCubit(this._addressRepository) : super(DeliveryChargeInitial());

  fetchDeliveryCharge(String? userId, String? addressId) {
    emit(DeliveryChargeProgress());
    _addressRepository.getDeliveryCharge(userId, addressId).then((value) => emit(DeliveryChargeSuccess(userId, addressId, value))).catchError((e) {
      emit(DeliveryChargeFailure(e.toString()));
    });
  }

  String getDeliveryCharge() {
    if (state is DeliveryChargeSuccess) {
      return (state as DeliveryChargeSuccess).delivaryCharge!;
    }
    return "";
  }
}
