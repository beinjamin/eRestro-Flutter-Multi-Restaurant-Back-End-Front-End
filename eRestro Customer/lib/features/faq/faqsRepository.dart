import 'package:erestro/features/faq/faqsException.dart';
import 'package:erestro/features/faq/faqsModel.dart';
import 'package:erestro/features/faq/faqsRemoteDataSource.dart';

class FaqsRepository {
  static final FaqsRepository _faqsRepository = FaqsRepository._internal();
  late FaqsRemoteDataSource _faqsRemoteDataSource;

  factory FaqsRepository() {
    _faqsRepository._faqsRemoteDataSource = FaqsRemoteDataSource();
    return _faqsRepository;
  }

  FaqsRepository._internal();

  Future<List<FaqsModel>> getFaqs() async {
    try {
      List<FaqsModel> result = await _faqsRemoteDataSource.getFaqs();
      return result/*.map((e) => FaqsModel.fromJson(Map.from(e))).toList()*/;
    } catch (e) {
      throw FaqsException(errorMessageCode: e.toString());
    }
  }

}
