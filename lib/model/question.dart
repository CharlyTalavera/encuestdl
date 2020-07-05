import 'package:encuestdl/encuestdl.dart';
import 'poll.dart';

class Question extends ManagedObject<_Question> implements _Question{}

class _Question {
  @primaryKey
  int id;

  @Column()
  String value;

  @Column()
  List<String> options;

  @Column()
  int correct;
  
  @Relate(#questions)
  Poll poll;
}