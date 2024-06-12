import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/FormatDates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/edit_entry.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AuthenticationBloc? _authenticationBloc;
  HomeBloc? _homeBloc;
  String? _uid;
  MoodIcons? _moodIcons;
  final FormatDates _formatDates = FormatDates();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authenticationBloc =
        AuthenticationBlocProvider.of(context)?.authenticationBloc;
    _homeBloc = HomeBlocProvider.of(context)?.homeBloc;
    _uid = HomeBlocProvider.of(context)?.uid;
  }

  @override
  void dispose() {
    _homeBloc?.dispose();
    super.dispose();
  }

  _addEditJournal(add, journal) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => JournalEditBlocProvider(
                journalEditBloc:
                    JournalEditBloc(add, journal, DbFireStoreService()),
                child: const EditEntry(),
              ),
          fullscreenDialog: true),
    );
  }

  Future<bool> _confirmDeleteJournal() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Journal"),
            content: const Text("Are you sure you would like to Delete"),
            actions: [
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              TextButton(
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Journal",
          style: TextStyle(
            color: Colors.lightGreen.shade800,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _authenticationBloc?.logoutUser.add(true);
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.lightGreen.shade800,
              ))
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(),
        ),
      ),
      body: StreamBuilder(
        stream: _homeBloc?.listJournal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return _buildListViewSeperated(snapshot);
          } else {
            return const Center(child: Text('Add Journals'));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Journal',
        backgroundColor: Colors.lightGreen.shade300,
        child: const Icon(Icons.add),
        onPressed: () {
          _addEditJournal(true, Journal(uid: _uid));
        },
      ),
    );
  }

  _buildListViewSeperated(snapshot) {
    return ListView.separated(
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          String titleDate = _formatDates
              .dateFormatShortMonthDayYear(snapshot.data[index].date);
          String subtitle =
              snapshot.data[index].mood + "\n" + snapshot.data[index].note;
          return Dismissible(
            confirmDismiss: (direction) async {
              bool confirmDelete = await _confirmDeleteJournal();
              if (confirmDelete) {
                _homeBloc?.deleteJournal.add(snapshot.data[index]);
              }
              return null;
            },
            key: Key(snapshot.data[index].documentID),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: Column(
                children: [
                  Text(
                    _formatDates.dateFormatDayNumber(snapshot.data[index].date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.lightGreen),
                  ),
                  Text(_formatDates
                      .dateFormatShortDayName(snapshot.data[index].date)),
                ],
              ),
              title: Text(titleDate),
              subtitle: Text(subtitle),
              onTap: () {
                _addEditJournal(false, snapshot.data[index]);
              },
              trailing: Transform(
                transform: Matrix4.identity()
                  ..rotateZ(
                      _moodIcons?.getMoodRotation(snapshot.data[index].mood) ??
                          0),
                alignment: Alignment.center,
                child: Icon(
                  _moodIcons?.getMoodIcon(snapshot.data[index].mood),
                  color: _moodIcons?.getMoodColor(
                    snapshot.data[index].mood,
                  ),
                  size: 42,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (contex, index) {
          return const Divider(
            color: Colors.grey,
          );
        });
  }
}
