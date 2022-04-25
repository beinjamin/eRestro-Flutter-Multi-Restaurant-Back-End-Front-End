import 'package:erestro/features/helpAndSupport/helpAndSupportException.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportModel.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportRemoteDataSource.dart';

class HelpAndSupportRepository {
  static final HelpAndSupportRepository _helpAndSupportRepository = HelpAndSupportRepository._internal();
  late HelpAndSupportRemoteDataSource _helpAndSupportRemoteDataSource;

  factory HelpAndSupportRepository() {
    _helpAndSupportRepository._helpAndSupportRemoteDataSource = HelpAndSupportRemoteDataSource();
    return _helpAndSupportRepository;
  }

  HelpAndSupportRepository._internal();

  Future<List<HelpAndSupportModel>> getHelpAndSupport() async {
    try {
      List<HelpAndSupportModel> result = await _helpAndSupportRemoteDataSource.getHelpAndSupport();
      return result;
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

  Future getAddTicket(String? ticketTypeId, String? subject, String? email, String? description, String? userId) async {
    try {
      final result = await _helpAndSupportRemoteDataSource.getAddTicket(ticketTypeId, subject, email, description, userId);
      return result;
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

  Future getEditTicket(String? ticketId, String? ticketTypeId, String? subject, String? email, String? description, String? userId, String? status) async {
    try {
      final result = await _helpAndSupportRemoteDataSource.getEditTicket(ticketId, ticketTypeId, subject, email, description, userId, status);
      return result;
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

}
