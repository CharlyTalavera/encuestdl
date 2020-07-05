import 'package:encuestdl/encuestdl.dart';
import 'package:encuestdl/model/question.dart';

class QuestionController extends ResourceController {
  final ManagedContext context;

  QuestionController(this.context){
        acceptedContentTypes = [ContentType("multipart", "form-data"), ContentType("application", "x-www-form-urlencoded")];
  }
  @Operation.get()
  Future<Response> getAllQuestions() async {
    final questionQuery = Query<Question>(context);
    final questions = await questionQuery.fetch();

    return Response.ok(questions);
  }

  @Operation.get('id')
  Future<Response> getByID(@Bind.path('id') int id) async {
    final questionQuery = Query<Question>(context)
      ..where((q) => q.id).equalTo(id);    

    final question = await questionQuery.fetchOne();

    if (question == null) {
      return Response.notFound();
    }
    return Response.ok(question);
  }

  @Operation.post()
  Future<Response> createQuestion() async {
      final Map<String, dynamic> body = await request.body.decode();
      if(body['value']?.isEmpty?? true)
        Response.badRequest(body: {"error": "Missing required param 'value'"});
      if(body['correct']?.isEmpty?? true)
        Response.badRequest(body: {"error": "Missing required param 'correct'"});
      if(body['options']?.isEmpty?? true)
        Response.badRequest(body: {"error": "Missing required param 'options'"});

      final query = Query<Question>(context)
        ..values.value = body['value'][0]
        ..values.poll.id = int.parse(body['poll'][0])
        ..values.correct = int.parse(body['correct'][0])
        ..values.options = Document(body['options']);

      final insertedQuestion = await query.insert();

      return Response.ok(insertedQuestion);
  }
}