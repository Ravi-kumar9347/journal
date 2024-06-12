import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class DbFireStoreService implements DbApi {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final String _collectionJournal = 'journals';

  @override
  Stream<List<Journal>> getJournalList(String? uid) {
    return _fireStore
        .collection(_collectionJournal)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      List<Journal> journalDocs = snapshot.docs
          .map((doc) => Journal.fromDoc(doc.data(), doc.id))
          .toList();
      journalDocs.sort((comp1, comp2) => comp2.date!.compareTo(comp1.date!));
      return journalDocs;
    });
  }

  @override
  Future<Journal> getJournal(String? documentID) async {
    DocumentReference documentReference =
        _fireStore.collection(_collectionJournal).doc(documentID);
    return Journal.fromDoc(
        await documentReference.get().then((doc) => doc.data()), documentID);
  }

  @override
  Future<bool> addJournal(Journal journal) async {
    DocumentReference documentReference =
        await _fireStore.collection(_collectionJournal).add({
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
      'uid': journal.uid,
    });
    return documentReference.id != null;
  }

  @override
  void updateJournal(Journal journal) async {
    await _fireStore
        .collection(_collectionJournal)
        .doc(journal.documentID)
        .update({
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
    }).catchError((error) => print('Error updating: $error'));
  }

  @override
  void deleteJournal(Journal journal) async {
    await _fireStore
        .collection(_collectionJournal)
        .doc(journal.documentID)
        .delete()
        .catchError((error) => print('Error deleting: $error'));
  }
}
