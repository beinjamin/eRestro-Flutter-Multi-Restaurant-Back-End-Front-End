import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/address/addressRemoteDataSource.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/favourite/favouriteRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../addressLocalDataSource.dart';

abstract class CityDeliverableState {}

class CityDeliverableInitial extends CityDeliverableState {}

class CityDeliverableProgress extends CityDeliverableState {}

class CityDeliverableSuccess extends CityDeliverableState {
  final String? name, cityId;

  CityDeliverableSuccess(this.name, this.cityId);
}

class CityDeliverableFailure extends CityDeliverableState {
  final String errorCode;

  CityDeliverableFailure(this.errorCode);
}

class CityDeliverableCubit extends Cubit<CityDeliverableState> {
  final AddressRepository _addressRepository;
  final AddressLocalDataSource _addressLocalDataSource;
/*
  factory AddressRepository() {
    _addressRepository._addressRemoteDataSource = AddressRemoteDataSource();
    _addressRepository._addressLocalDataSource = AddressLocalDataSource();
    return _addressRepository;
  }*/
  CityDeliverableCubit(this._addressRepository, this._addressLocalDataSource) : super(CityDeliverableInitial());

  void fetchCityDeliverable(String? name) {
    emit(CityDeliverableProgress());
    _addressRepository.getCityDeliverable(name).then((value) => emit(CityDeliverableSuccess(name, value))).catchError((e) {
      emit(CityDeliverableFailure(e.toString()));
    });
  }

  String getCityId() {
    if (state is CityDeliverableSuccess) {
      //print("check City Id :"+(state as CityDeliverableSuccess).cityId!);
      return (state as CityDeliverableSuccess).cityId!;
    }else if(state is CityDeliverableFailure) {
      //print("city..!!");
    }
    return "";
  }

  /*String getCityId() {
    if (state is CityDeliverableSuccess) {
      print("check City Id :"+(state as CityDeliverableSuccess).cityId!);
      return (state as CityDeliverableSuccess).cityId!;
    }else if(state is CityDeliverableFailure) {
      print("city..!!");
    }
    return "";
  }

  String SetCityId() {
    if (state is CityDeliverableSuccess) {
      print("check City Id :"+(state as CityDeliverableSuccess).cityId!);
      return (state as CityDeliverableSuccess).cityId!;
    }else if(state is CityDeliverableFailure) {
      print("city..!!");
    }
    return "";
  }*/
}