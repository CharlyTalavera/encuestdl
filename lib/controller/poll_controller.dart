import 'package:encuestdl/encuestdl.dart';
import 'package:encuestdl/model/poll.dart';

class PollController extends ResourceController {
  final ManagedContext context;

  PollController(this.context){
        acceptedContentTypes = [ContentType("multipart", "form-data"), ContentType("application", "x-www-form-urlencoded")];
  }

  @Operation.get()
  Future<Response> getAllPolls() async {
    final pollQuery = Query<Poll>(context)
      ..join(set: (p) => p.questions);

    final polls = await pollQuery.fetch();

    for(final poll in polls)
      for(final question in poll.questions)
        question.correct = -1; //Don't return correct response to client
    return Response.ok(polls);
  }

  @Operation.get('id')
  Future<Response> getByID(@Bind.path('id') int id) async {
    final pollQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(id)
      ..join(set: (p) => p.questions);    

    final poll = await pollQuery.fetchOne();
    
    if(poll == null)
      return Response.notFound(body: {"error": "The poll id ${id} is invalid"});

    for(final question in poll.questions)
      question.correct = -1; //Don't response correct response to client

    if (poll == null) {
      return Response.notFound();
    }
    return Response.ok(poll);
  }

  @Operation.post()
    Future<Response> createPoll() async {
      final Map<String, dynamic> body = await request.body.as();

      if(body == null || body['name']?.isEmpty?? true)
        return Response.badRequest(body: {"error": "Missing required param 'name'"});

      final query = Query<Poll>(context)
        ..values.name = body['name'][0];

      final insertedPoll = await query.insert();

      return Response.ok(insertedPoll);
  }
}