import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/ad_entity.dart';

abstract class AdRepository {
  Future<Either<Failure, List<AdEntity>>> getAds();
  Future<Either<Failure, AdEntity>> getAdById(int id);
  Future<Either<Failure, AdEntity>> createAd(AdEntity ad);
  Future<Either<Failure, AdEntity>> updateAd(AdEntity ad);
  Future<Either<Failure, void>> deleteAd(int id);
}