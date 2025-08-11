import 'package:dartz/dartz.dart';
import 'package:elqueue/administrator/core/errors/failures.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/domain/repositories/ad_repository.dart';

class GetAds {
  final AdRepository repository;
  GetAds(this.repository);
  Future<Either<Failure, List<AdEntity>>> call() => repository.getAds();
}

class GetAdById {
  final AdRepository repository;
  GetAdById(this.repository);
  Future<Either<Failure, AdEntity>> call(int id) => repository.getAdById(id);
}

class CreateAd {
  final AdRepository repository;
  CreateAd(this.repository);
  Future<Either<Failure, AdEntity>> call(AdEntity ad) => repository.createAd(ad);
}

class UpdateAd {
  final AdRepository repository;
  UpdateAd(this.repository);
  Future<Either<Failure, AdEntity>> call(AdEntity ad) => repository.updateAd(ad);
}

class DeleteAd {
  final AdRepository repository;
  DeleteAd(this.repository);
  Future<Either<Failure, void>> call(int id) => repository.deleteAd(id);
}