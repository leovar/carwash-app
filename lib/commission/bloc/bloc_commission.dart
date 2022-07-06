import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/commission/repository/commission_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocCommission implements Bloc {

  final _commissionRepository = CommissionRepository();

  Stream<QuerySnapshot> get allCommissionStream => _commissionRepository.getListCommissionsStream();
  List<Commission> buildAllCommissions(List<DocumentSnapshot> commissionListSnapshot) => _commissionRepository.buildCommissions(commissionListSnapshot);

  void updateCommission(Commission commission) async {
    return _commissionRepository.updateCommission(commission);
  }

  Future<List<Commission>> getAllCommissions() async {
    return _commissionRepository.getAllCommissions();
  }

  @override
  void dispose() {
  }
}