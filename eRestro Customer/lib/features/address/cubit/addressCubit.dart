import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressProgress extends AddressState {}

class AddressSuccess extends AddressState {
  final List<AddressModel> addressList;

  AddressSuccess(this.addressList);
}

class AddressFailure extends AddressState {
  final String errorCode;

  AddressFailure(this.errorCode);
}

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _addressRepository;

  AddressCubit(this._addressRepository) : super(AddressInitial());

  void fetchAddress(String? userId) {
    emit(AddressProgress());
    _addressRepository.getAddress(userId).then((value) => emit(AddressSuccess(value))).catchError((e) {
      emit(AddressFailure(e.toString()));
    });
  }

  void deleteAddress(String? id)
  {
    if(state is AddressSuccess) {
      //
      List<AddressModel> currentAddress = (state as AddressSuccess).addressList;
      //AddressModel addressModel= (state as AddressSuccess).addressModel;
      currentAddress.removeWhere((element) => element.id == id);
      emit(AddressSuccess( List<AddressModel>.from(currentAddress)));
    }
  }

  void addAddress(AddressModel addressModel)
  {
    if(state is AddressSuccess) {
      //
      List<AddressModel> currentAddress = (state as AddressSuccess).addressList;
      currentAddress.insert(0, addressModel);
      emit(AddressSuccess( List<AddressModel>.from(currentAddress)));
    }
  }

  void editAddress(AddressModel addressModel)
  {
    if(state is AddressSuccess) {
      //
      List<AddressModel> currentAddress = (state as AddressSuccess).addressList;
      int i = currentAddress.indexWhere((element) => element.id == addressModel.id);
      currentAddress[i]=addressModel;

      emit(AddressSuccess(List<AddressModel>.from(currentAddress)));
    }
  }

  void updateAddress(AddressModel addressModel)
  {
    if(state is AddressSuccess) {
      //
      List<AddressModel> currentAddress = (state as AddressSuccess).addressList;
      int curntSelectedIndex = currentAddress.indexWhere((element) => element.isDefault! == "1");
      //print("curent Index:"+curntSelectedIndex.toString());

      int i = currentAddress.indexWhere((element) => element.id == addressModel.id);
      if(i == curntSelectedIndex) {
        //print(currentAddress[i].id.toString()+""+currentAddress[curntSelectedIndex].id.toString());
        return;
      }
      currentAddress[curntSelectedIndex]= currentAddress[curntSelectedIndex].copyWith(isDefault: "0");

        currentAddress[i]=addressModel;

      emit(AddressSuccess(List<AddressModel>.from(currentAddress)));
    }
  }

  AddressModel gerCurrentAddress() {
    if (state is AddressSuccess) {
      final addresses = (state as AddressSuccess).addressList;
      final currentAddressIndex = addresses.indexWhere((element) => element.isDefault == "1");
      return  addresses[currentAddressIndex];
    }
    return AddressModel.fromJson({});
  }

}