import 'package:flutter/material.dart';

import '../data/history_repository.dart';
import '../l10n/app_l.dart';
import '../models/abg_input.dart';

class HistoryScreen extends StatefulWidget {
  final HistoryRepository repo;
  final void Function(AbgInput input, bool pediatric, bool venous) onSelect;

  const HistoryScreen({
    super.key,
    required this.repo,
    required this.onSelect,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await widget.repo.load();
    if (mounted) {
      setState(() {
        _entries = list;
        _loading = false;
      });
    }
  }

  String _fmtDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL.ofContext(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: l.historyDeleteAll,
              icon: const Icon(Icons.delete_sweep),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.historyDeleteAllTitle),
                    content: Text(l.historyDeleteAllBody),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l.cancel)),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l.delete)),
                    ],
                  ),
                );
                if (ok == true) {
                  await widget.repo.clear();
                  _reload();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(child: Text(l.historyEmpty))
              : ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = _entries[i];
                    return Dismissible(
                      key: ValueKey('${e.timestamp.toIso8601String()}_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Theme.of(context).colorScheme.errorContainer,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (_) async {
                        await widget.repo.delete(i);
                        setState(() => _entries.removeAt(i));
                      },
                      child: ListTile(
                        title: Text(e.primaryDiagnosis.isEmpty
                            ? l.resultLabel
                            : e.primaryDiagnosis),
                        subtitle: Text(
                          '${_fmtDate(e.timestamp)}'
                          ' ・${e.venous ? l.tagVenous : l.tagArterial}'
                          '${e.pediatric ? ' ・${l.tagPediatric}' : ''}\n'
                          'pH ${e.input.ph}  ${e.venous ? 'PvCO2' : 'PaCO2'} ${e.input.paco2}  HCO3- ${e.input.hco3}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          widget.onSelect(e.input, e.pediatric, e.venous);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
