import 'package:dartz/dartz.dart';
import 'package:elqueue/administrator/core/errors/exceptions.dart';
import 'package:elqueue/administrator/core/errors/failures.dart';
import 'package:elqueue/administrator/data/datasource/ad_remote_data_source.dart';
import 'package:elqueue/administrator/domain/entities/ad_entity.dart';
import 'package:elqueue/administrator/domain/repositories/ad_repository.dart';

class AdRepositoryImpl implements AdRepository {
  final AdRemoteDataSource remoteDataSource;

  AdRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdEntity>>> getAds() async {
    try {
      final ads = await remoteDataSource.getAds();
      return Right(ads);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AdEntity>> createAd(AdEntity ad) async {
    try {
      final newAd = await remoteDataSource.createAd(ad);
      return Right(newAd);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AdEntity>> updateAd(AdEntity ad) async {
    try {
      final updatedAd = await remoteDataSource.updateAd(ad);
      return Right(updatedAd);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAd(int id) async {
    try {
      await remoteDataSource.deleteAd(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}