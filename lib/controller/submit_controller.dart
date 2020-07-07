import 'package:encuestdl/encuestdl.dart';
import 'package:encuestdl/model/poll.dart';
import 'package:encuestdl/model/submit.dart';
import 'package:encuestdl/model/question.dart';


class SubmitController extends ResourceController {
  final ManagedContext context;

  SubmitController(this.context){
    acceptedContentTypes = [ContentType("multipart", "form-data"), ContentType("application", "x-www-form-urlencoded")];
  }

  @Operation.get('pollId')
  Future<Response> getSubmitByPoll(@Bind.path('pollId') int pollId) async {
    final submitsQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(pollId)
      ..join(set: (p) => p.submits);   

    final poll = await submitsQuery.fetchOne();

    return Response.ok(poll.submits);
  }

  @Operation.post()  
  Future<Response> createSubmit() async {

    Map<String, dynamic> bodyMap = request.body.as();

    if(bodyMap['submitter']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'submitter'"});
    if(bodyMap['poll']?.isEmpty?? true)
      return Response.badRequest(body: {"error": "Missing required param 'poll' id"});
    final pollId = int.parse(bodyMap['poll'][0]);
    final pollQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(pollId);
    final poll = await pollQuery.fetchOne();
    if(poll == null)
      return Response.badRequest(body:{"error": "Poll with id ${pollId} not found."});

    final query = Query<Submit>(context)
      ..values.poll.id = pollId
      ..values.submitter = bodyMap['submitter'][0]
      ..values.responses = Document([])
      ..values.score = 0;

    final insertedSubmit = await query.insert();

    return Response.ok(insertedSubmit);
  }

  @Operation('PATCH','id')
  Future<Response> updateSubmit(@Bind.path('id') int id) async {
    Map<String, dynamic> bodyMap = request.body.as();
  
    if(bodyMap['response']?.isEmpty ?? true)
      return Response.badRequest(body: {"error": "Missing required parameter 'response'"});

    final response = int.parse(bodyMap['response'][0]);
    bool correct = false;

    final submit = await (Query<Submit>(context)
      ..where((s) => s.id).equalTo(id)
      ..join(object: (s) => s.poll)
      ).fetchOne();

    if(submit == null)
      return Response.notFound(body: {"error": "The submit id ${id} is invalid"});

    final questions = await (Query<Question>(context)
      ..where((q) => q.poll.id).equalTo(submit.poll.id)
    ).fetch();

    if(submit.responses.data.length >= questions.length)
      return Response.forbidden(body: {"error": "You have submitted all responses"});

    final question = questions[submit.responses.data.length];

    if(response < 1 || response > question.options.data.length)
      return Response.forbidden(body: {"error": "The response must be between 1 and ${question.options.data.length}"});
    if(question.correct == response){
      submit.score += 1;
      correct = true;
    }

    submit.responses.data.add(response);

    await (Query<Submit>(context)
      ..values.score = submit.score
      ..values.responses = submit.responses
      ..where((s) => s.id).equalTo(submit.id)
    ).update();

    return Response.ok({"correct": correct});
  }
}

class PollSubmitController extends ResourceController {

  final ManagedContext context;

  PollSubmitController(this.context){
    acceptedContentTypes = [ContentType("multipart", "form-data"), ContentType("application", "x-www-form-urlencoded")];
  }

  @Operation.get('pollId')
  Future<Response> getSubmitByPoll(@Bind.path('pollId') int pollId) async {
    final submitsQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(pollId)
      ..join(set: (p) => p.submits);   

    final poll = await submitsQuery.fetchOne();

    if(poll == null )
      return Response.badRequest(body: {"error": "The poll id ${pollId} is invalid"});

    return Response.ok(poll.submits);
  }
}

