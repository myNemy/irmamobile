import 'dart:async';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/irma_repository.dart';
import '../../models/credentials.dart';
import '../../models/log_entry.dart';

class LogEntries extends UnmodifiableListView<LogEntry> {
  LogEntries(super.list);
}

class HistoryState {
  final UnmodifiableListView<LogEntry> logEntries;
  final bool loading;
  final bool moreLogsAvailable;

  HistoryState({
    List<LogEntry> logEntries = const [],
    this.loading = false,
    this.moreLogsAvailable = false,
  }) : logEntries = UnmodifiableListView(logEntries);

  HistoryState copyWith({
    List<LogEntry>? logEntries,
    bool? loading,
    bool? moreLogsAvailable,
  }) {
    return HistoryState(
      logEntries: logEntries ?? this.logEntries,
      loading: loading ?? this.loading,
      moreLogsAvailable: moreLogsAvailable ?? this.moreLogsAvailable,
    );
  }
}

class HistoryRepository {
  static const _serverNameOptional = [LogEntryType.issuing, LogEntryType.removal];

  IrmaRepository repo;

  final _historyStateSubject = BehaviorSubject<HistoryState>();
  late StreamSubscription _historyStateSubscription;

  HistoryRepository(this.repo) {
    _historyStateSubscription = repo.getEvents().scan<HistoryState>((prevState, event, _) {
      if (event is LoadLogsEvent) {
        return prevState.copyWith(
          loading: true,
          logEntries: event.before == null ? [] : prevState.logEntries,
        );
      } else if (event is LogsEvent) {
        // Some legacy log formats don't specify a serverName. For disclosing and signing logs this is an issue,
        // because the serverName has a prominent place in the UX there. For now we skip those as temporary solution.
        // TODO: Remove filtering when legacy logs are converted to the right format in irmago
        final supportedLogEntries =
            event.logEntries.where((entry) => _serverNameOptional.contains(entry.type) || entry.serverName != null);

        bool containsKeyshareCredential(LogEntry e) => e.issuedCredentials.any((c) =>
            Credential.fromRaw(irmaConfiguration: repo.irmaConfiguration, rawCredential: c).isKeyshareCredential);

        // FIXME: We assume that when the activityLogEntries list is empty, then all log entries are loaded.
        // If an user adds multiple keyshare servers one after another, this assumption will break.
        final activityLogEntries = supportedLogEntries.where((entry) => !containsKeyshareCredential(entry));

        return prevState.copyWith(
          loading: false,
          logEntries: [...prevState.logEntries, ...activityLogEntries],
          moreLogsAvailable: activityLogEntries.isNotEmpty,
        );
      }

      return prevState;
    }, HistoryState()).listen((historyState) {
      _historyStateSubject.add(historyState);
    });
  }

  Future<void> dispose() async {
    _historyStateSubscription.cancel();
    _historyStateSubject.close();
  }

  Stream<HistoryState> getHistoryState() {
    return _historyStateSubject.stream;
  }
}
