import 'package:encuestdl/encuestdl.dart';
import 'package:encuestdl/model/question.dart';
import 'package:encuestdl/model/poll.dart';

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
    if(body == null)
      return Response.badRequest(body: {"error": "Missing body"});
    if(body['value']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'value'"});
    if(body['correct']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'correct'"});
    if(body['options']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'options'"});
    if(body['poll']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'poll' id"});
    
    final pollId = int.parse(body['poll'][0]);
    final pollQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(pollId);

    final poll = await pollQuery.fetchOne();

    if(poll == null)
      return Response.badRequest(body: {"error": "The poll id ${pollId} is invalid"});
    final correct = int.parse(body['correct'][0]);
    if(correct < 1 && correct > body['options'].length)
      return Response.forbidden(body: {"error": "Correct option must be between 1 and ${body['options'].length}"});
    
    final query = Query<Question>(context)
      ..values.value = body['value'][0]
      ..values.poll.id = int.parse(body['poll'][0])
      ..values.correct = int.parse(body['correct'][0])
      ..values.options = Document(body['options']);
    
    final insertedQuestion = await query.insert();
    return Response.ok(insertedQuestion);
  }
}