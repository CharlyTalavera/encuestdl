import 'package:encuestdl/encuestdl.dart';
import 'poll.dart';
import 'submit.dart';

class Submit extends ManagedObject<_Submit> implements _Submit{}

class _Submit {
  @primaryKey
  int id;

  @Column()
  String submitter;

  Document responses;

  @Column()
  int score;

  @Relate(#submits)
  Poll poll;
}