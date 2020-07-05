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

    return Response.ok(polls);
  }

  @Operation.get('id')
  Future<Response> getByID(@Bind.path('id') int id) async {
    final pollQuery = Query<Poll>(context)
      ..where((p) => p.id).equalTo(id);    

    final poll = await pollQuery.fetchOne();

    if (poll == null) {
      return Response.notFound();
    }
    return Response.ok(poll);
  }

  @Operation.post()
    Future<Response> createPoll() async {
      final Map<String, dynamic> body = await request.body.decode();
      if(body['name']?.isEmpty?? true)
        Response.badRequest(body: {"error": "Missing required param 'name'"});

      final query = Query<Poll>(context)
        ..values.name = body['name'][0];

      final insertedPoll = await query.insert();

      return Response.ok(insertedPoll);
  }
}