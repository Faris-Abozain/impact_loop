import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:impact_loop/core/api/base_api_consumer.dart';
import 'package:impact_loop/core/api/end_points.dart';
import 'package:impact_loop/core/config/app_config.dart';
import 'package:impact_loop/core/data/mock_impact_data.dart';
import 'package:impact_loop/core/error/failures.dart';
import 'package:impact_loop/core/models/impact_enums.dart';
import 'package:impact_loop/core/models/wallet_models.dart';
import 'package:impact_loop/core/network/api_envelope.dart';
import 'package:impact_loop/core/utils/uuid_utils.dart';

class WalletRepository {
  WalletRepository(this._api);

  final BaseApiConsumer _api;

  Future<Either<Failure, WalletSummary>> getWallet() async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return Right(MockImpactData.wallet);
    }

    try {
      final raw = await _api.get(EndPoints.wallet);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(WalletSummary.fromJson(envelope.data!));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> requestWithdrawal({
    required int points,
    required String method,
    required String destination,
    String? idempotencyKey,
  }) async {
    if (AppConfig.useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final w = MockImpactData.wallet;
      if (points > w.balancePoints) {
        return Left(ServerFailure(message: 'Insufficient balance'));
      }
      MockImpactData.wallet = WalletSummary(
        balancePoints: w.balancePoints - points,
        transactions: [
          WalletTransaction(
            id: 'w${DateTime.now().millisecondsSinceEpoch}',
            type: WalletTransactionType.withdrawal,
            amountPoints: -points,
            reason: 'Withdrawal • $method',
            createdAt: DateTime.now(),
          ),
          ...w.transactions,
        ],
      );
      return const Right(unit);
    }

    try {
      final key = idempotencyKey ?? UuidUtils.generateV4();
      final raw = await _api.post(
        EndPoints.walletWithdraw,
        body: {
          'amountPoints': points,
          'payoutMethod': method,
          'note': destination,
        },
        options: Options(
          headers: {
            'Idempotency-Key': key,
          },
        ),
      );
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<WalletTransaction>>> getLedger() async {
    if (AppConfig.useMockApi) {
      return Right(MockImpactData.wallet.transactions);
    }
    try {
      final raw = await _api.get(EndPoints.walletLedger);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      final txList = (envelope.data!['transactions'] as List<dynamic>)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(txList);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }


  Future<Either<Failure, ImpactSummary>> getImpact() async {
    if (AppConfig.useMockApi) {
      return Right(MockImpactData.impact);
    }

    try {
      final raw = await _api.get(EndPoints.usersMeImpact);
      final envelope = ApiEnvelope.parseMap(raw as Map<String, dynamic>);
      if (!envelope.success || envelope.data == null) {
        return Left(ServerFailure(message: envelope.error?.message ?? 'Error'));
      }
      return Right(ImpactSummary.fromJson(envelope.data!));
    } catch (e) {
      // Auto-fallback: If local server is not running or unreachable, fallback seamlessly to mock data
      return Right(MockImpactData.impact);
    }
  }
}
