import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/FormatDates.dart';
import 'package:journal/classes/mood_icons.dart';

class EditEntry extends StatefulWidget {
  const EditEntry({super.key});

  @override
  State<EditEntry> createState() => _EditEntryState();
}

class _EditEntryState extends State<EditEntry> {
  JournalEditBloc? _journalEditBloc;
  FormatDates? _formatDates;
  MoodIcons? _moodIcons;
  TextEditingController? _noteController;

  @override
  void initState() {
    super.initState();
    _formatDates = FormatDates();
    _moodIcons = const MoodIcons();
    _noteController = TextEditingController();
    _noteController?.text = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _journalEditBloc = JournalEditBlocProvider.of(context)?.journalEditBloc;
  }

  @override
  dispose() {
    _noteController?.dispose();
    _journalEditBloc?.dispose();
    super.dispose();
  }

  Future<String> _selectDate(String selectedDate) async {
    DateTime initialDate = DateTime.parse(selectedDate);
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (pickedDate != null) {
      selectedDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              initialDate.hour,
              initialDate.minute,
              initialDate.second,
              initialDate.millisecond,
              initialDate.microsecond)
          .toString();
    }
    return selectedDate;
  }

  void _addorUpdateJournal() {
    _journalEditBloc?.saveJournalChanged.add('save');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Entry',
          style: TextStyle(color: Colors.lightGreen.shade800),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.lightGreen, Colors.lightGreen.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder(
                  stream: _journalEditBloc?.dateEdit,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return TextButton(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 22,
                            color: Colors.black54,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            _formatDates?.dateFormatShortMonthDayYear(
                                    snapshot.data!) ??
                                '',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        String pickerDate = await _selectDate(snapshot.data!);
                        _journalEditBloc?.dateEditChanged.add(pickerDate);
                      },
                    );
                  }),
              StreamBuilder(
                  stream: _journalEditBloc?.moodEdit,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return DropdownButtonHideUnderline(
                        child: DropdownButton<MoodIcons>(
                      value: _moodIcons?.getMoodIconsList()[_moodIcons!
                          .getMoodIconsList()
                          .indexWhere((icon) => icon.title == snapshot.data)],
                      onChanged: (selected) {
                        _journalEditBloc?.moodEditChanged.add(selected!.title!);
                      },
                      items: _moodIcons
                          ?.getMoodIconsList()
                          .map((MoodIcons selected) {
                        return DropdownMenuItem<MoodIcons>(
                          value: selected,
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Transform(
                                transform: Matrix4.identity()
                                  ..rotateZ(_moodIcons?.getMoodRotation(
                                          selected.title ?? '') ??
                                      0),
                                alignment: Alignment.center,
                                child: Icon(
                                  _moodIcons?.getMoodIcon(selected.title!),
                                  color:
                                      _moodIcons?.getMoodColor(selected.title!),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                selected.title!,
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ));
                  }),
              StreamBuilder(
                stream: _journalEditBloc?.noteEdit,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  _noteController?.value =
                      _noteController?.value.copyWith(text: snapshot.data) ??
                          const TextEditingValue();
                  return TextField(
                    controller: _noteController,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      icon: SizedBox(
                        width: 40.0,
                        child: Icon(Icons.subject),
                      ),
                    ),
                    maxLines: null,
                    onChanged: (note) =>
                        _journalEditBloc?.noteEditChanged.add(note),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.lightGreen.shade100),
                    ),
                    onPressed: () {
                      _addorUpdateJournal();
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
