import 'package:encuestdl/encuestdl.dart';
import 'question.dart';
import 'submit.dart';

class Poll extends ManagedObject<_Poll> implements _Poll{}

class _Poll {
  @primaryKey
  int id;

  @Column()
  String name;

  ManagedSet<Question> questions;

  ManagedSet<Submit> submits;

}