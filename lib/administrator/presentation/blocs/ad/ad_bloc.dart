import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/domain/usecases/manage_ads.dart';
import 'package:equatable/equatable.dart';

part 'ad_event.dart';
part 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final GetAds getAds;
  final CreateAd createAd;
  final UpdateAd updateAd;
  final DeleteAd deleteAd;

  AdBloc({
    required this.getAds,
    required this.createAd,
    required this.updateAd,
    required this.deleteAd,
  }) : super(AdInitial()) {
    on<LoadAds>(_onLoadAds);
    on<AddAd>(_onAddAd);
    on<UpdateAdInfo>(_onUpdateAdInfo);
    on<DeleteAdById>(_onDeleteAdById);
  }

  Future<void> _onLoadAds(LoadAds event, Emitter<AdState> emit) async {
    emit(AdLoading());
    final result = await getAds();
    result.fold(
      (failure) => emit(AdError(failure.message)),
      (ads) => emit(AdLoaded(ads)),
    );
  }

  Future<void> _onAddAd(AddAd event, Emitter<AdState> emit) async {
    final currentState = state;
    if (currentState is AdLoaded) {
      // Отправляем запрос на создание
      final result = await createAd(event.ad);
      result.fold(
        (failure) => emit(AdError(failure.message)),
        (newAd) {
          // В случае успеха, добавляем новый элемент в существующий список
          final updatedList = List<AdEntity>.from(currentState.ads)..add(newAd);
          emit(AdLoaded(updatedList));
        },
      );
    } else {
      // Если по какой-то причине список еще не загружен, выполняем полную загрузку
      add(LoadAds());
    }
  }

  Future<void> _onUpdateAdInfo(UpdateAdInfo event, Emitter<AdState> emit) async {
    final currentState = state;
    if (currentState is AdLoaded) {
      // Отправляем запрос на обновление
      final result = await updateAd(event.ad);
      result.fold(
        (failure) => emit(AdError(failure.message)),
        (updatedAd) {
          // В случае успеха, находим и заменяем элемент в существующем списке
          final updatedList = currentState.ads.map((ad) {
            return ad.id == updatedAd.id ? updatedAd : ad;
          }).toList();
          emit(AdLoaded(updatedList));
        },
      );
    }
  }

  Future<void> _onDeleteAdById(DeleteAdById event, Emitter<AdState> emit) async {
    final currentState = state;
    if (currentState is AdLoaded) {
      // Отправляем запрос на удаление
      final result = await deleteAd(event.id);
      result.fold(
        (failure) => emit(AdError(failure.message)),
        (_) {
          // В случае успеха, удаляем элемент из существующего списка
          final updatedList = List<AdEntity>.from(currentState.ads)
            ..removeWhere((ad) => ad.id == event.id);
          emit(AdLoaded(updatedList));
        },
      );
    }
  }
}