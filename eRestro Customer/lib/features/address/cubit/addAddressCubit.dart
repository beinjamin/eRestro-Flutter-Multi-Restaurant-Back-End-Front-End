import 'package:erestro/features/address/addressRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../addressModel.dart';

abstract class AddAddressState {}

class AddAddressInitial extends AddAddressState {}

class AddAddressProgress extends AddAddressState {}

class AddAddressSuccess extends AddAddressState {
  final AddressModel addressModel;

  AddAddressSuccess(this.addressModel);
}

class AddAddressFailure extends AddAddressState {
  final String errorCode;

  AddAddressFailure(this.errorCode);
}

class AddAddressCubit extends Cubit<AddAddressState> {
  final AddressRepository _addAddressRepository;

  AddAddressCubit(this._addAddressRepository) : super(AddAddressInitial());

  void fetchAddAddress(String? userId, String? mobile, String? address, String? city, String? latitude, String? longitude,
      String? area, String? type, String? name, String? countryCode, String? alternateMobile, String? landmark, String? pincode, String? state, String? country, String? isDefault) {
    emit(AddAddressProgress());
    _addAddressRepository.getAddAddress(userId,  mobile,  address,  city,  latitude,  longitude,
        area, type,name,  countryCode,  alternateMobile,  landmark, pincode,  state,  country, isDefault).then((value) => emit(AddAddressSuccess(AddressModel(userId: userId,  mobile: mobile,  address: address,  city: city,  latitude: latitude,  longitude: longitude,
        area: area, type: type,name: name,  countryCode: countryCode,  alternateMobile: alternateMobile,  landmark:landmark, pincode: pincode,  state: state,  country: country, isDefault: isDefault)))).catchError((e) {
      emit(AddAddressFailure(e.toString()));
    });
  }

  String getCity() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.city!;
    }
    return "";
  }

  String getLatitude() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.latitude!;
    }
    return "";
  }

  String getLongitude() {
    if (state is AddAddressSuccess) {
      return (state as AddAddressSuccess).addressModel.longitude!;
    }
    return "";
  }

}