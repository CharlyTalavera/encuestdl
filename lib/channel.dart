import 'encuestdl.dart';
import 'controller/question_controller.dart';
import 'controller/poll_controller.dart';
import 'controller/submit_controller.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class EncuestdlChannel extends ApplicationChannel {
  
  ManagedContext context;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
      "root", "password", "159.89.138.97", 5432, "encuestdl");
    CORSPolicy.defaultPolicy.allowedOrigins = ["*"];
    CORSPolicy.defaultPolicy.allowedMethods = ["GET", "POST", "PUT", "PATCH", "OPTIONS"];

    context = ManagedContext(dataModel, persistentStore);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
      .route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      });

    router
      .route("questions")
      .link(() => QuestionController(context));

    router
      .route("/question/:id")
      .link(() => QuestionController(context));
      
    router
      .route("/polls")
      .link(() => PollController(context));

    router
      .route("/poll/:id")
      .link(() => PollController(context));

    router
      .route('/submits')
      .link(() => SubmitController(context));

    router
      .route('/submit/:id')
      .link(() => SubmitController(context));


    router
      .route('/poll/:pollId/submits')
      .link(() => PollSubmitController(context));

    return router;
  }
}