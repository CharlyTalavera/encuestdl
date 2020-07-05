import 'package:encuestdl/encuestdl.dart';
import 'package:encuestdl/model/poll.dart';
import 'package:encuestdl/model/submit.dart';

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

    final polls = await submitsQuery.fetch();

    return Response.ok(polls[0].submits);
  }

  @Operation.post('pollId')  
  Future<Response> createSubmit(@Bind.path('pollId') int pollId) async {

      Map<String, dynamic> bodyMap = request.body.as();

    if(bodyMap['submitter']?.isEmpty?? true)
        return Response.badRequest(body: {"error": "Missing required param 'submitter'"});

    final query = Query<Submit>(context)
      ..values.poll.id = pollId
      ..values.submitter = bodyMap['submitter'][0]
      ..values.responses = Document([])
      ..values.score = 0;

    final insertedSubmit = await query.insert();

    return Response.ok(insertedSubmit);
  }
}

