import 'package:material_ui/material_ui.dart';

import '../domain/document_models.dart';
import 'documents_view_model.dart';

class _PaymentFields {
  _PaymentFields([PaymentDraft? value])
    : id = value?.id,
      due = TextEditingController(
        text: value == null ? '' : displayDate(value.due),
      ),
      amount = TextEditingController(
        text: value == null ? '' : money(value.cents).replaceAll(' €', ''),
      ),
      paid = value?.paid ?? false;
  final int? id;
  final TextEditingController due, amount;
  bool paid;
  void dispose() {
    due.dispose();
    amount.dispose();
  }
}

class DocumentForm extends StatefulWidget {
  const DocumentForm({
    super.key,
    required this.model,
    required this.vehicleId,
    required this.vehicleName,
    this.record,
    this.renew = false,
  });
  final DocumentsViewModel model;
  final int vehicleId;
  final String vehicleName;
  final DocumentRecord? record;
  final bool renew;
  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final form = GlobalKey<FormState>();
  late DocumentKind kind;
  final start = TextEditingController(), end = TextEditingController();
  final fields = <_PaymentFields>[];
  String? error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final d = widget.record?.draft;
    kind = d?.kind ?? DocumentKind.liability;
    if (d != null && !widget.renew) {
      start.text = d.start == null ? '' : displayDate(d.start!);
      end.text = d.end == null ? '' : displayDate(d.end!);
      fields.addAll(d.payments.map(_PaymentFields.new));
    }
    if (kind == DocumentKind.tax && fields.isEmpty) {
      fields.add(_PaymentFields());
    }
  }

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    for (final p in fields) {
      p.dispose();
    }
    super.dispose();
  }

  String? dateError(String? s, {bool optional = false}) =>
      optional && (s ?? '').trim().isEmpty
      ? null
      : parseDate(s ?? '') == null
      ? 'Въведи дата ДД.ММ.ГГГГ'
      : null;
  Widget dateField(
    TextEditingController c,
    String label, {
    bool optional = false,
  }) => TextFormField(
    controller: c,
    decoration: InputDecoration(labelText: label, hintText: 'ДД.ММ.ГГГГ'),
    keyboardType: TextInputType.text,
    validator: (s) => dateError(s, optional: optional),
  );
  Future<void> save() async {
    if (busy || !form.currentState!.validate()) return;
    final draft = DocumentDraft(
      kind: kind,
      start:
          (kind != DocumentKind.liability && kind != DocumentKind.casco) ||
              start.text.trim().isEmpty
          ? null
          : dateKey(parseDate(start.text)!),
      end: kind == DocumentKind.tax ? null : dateKey(parseDate(end.text)!),
      payments: kind.permitsPayments
          ? [
              for (final p in fields)
                PaymentDraft(
                  id: p.id,
                  due: dateKey(parseDate(p.due.text)!),
                  cents: parseCents(p.amount.text)!,
                  paid: p.paid,
                ),
            ]
          : [],
    );
    try {
      draft.validate();
    } on DocumentValidation catch (e) {
      setState(() => error = e.message);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    final ok = await widget.model.run(
      () => widget.model.repository.save(
        widget.vehicleId,
        draft,
        id: widget.renew ? null : widget.record?.id,
        renewId: widget.renew ? widget.record?.id : null,
      ),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      busy = false;
      error = widget.model.error ?? 'Записът не е запазен.';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.renew
            ? 'Подновяване'
            : widget.record == null
            ? 'Нов документ'
            : 'Редакция',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(widget.vehicleName),
            const SizedBox(height: 12),
            if (widget.record == null)
              DropdownButtonFormField<DocumentKind>(
                initialValue: kind,
                isExpanded: true,
                itemHeight: null,
                decoration: const InputDecoration(labelText: 'Вид документ'),
                items: [
                  for (final k in DocumentKind.values)
                    DropdownMenuItem(
                      value: k,
                      child: Text(
                        k.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: busy
                    ? null
                    : (k) {
                        if (k == null) return;
                        setState(() {
                          kind = k;
                          if (kind == DocumentKind.tax && fields.isEmpty) {
                            fields.add(_PaymentFields());
                          }
                        });
                      },
              )
            else
              Text(kind.label, style: Theme.of(context).textTheme.titleLarge),
            if (kind != DocumentKind.tax) ...[
              const SizedBox(height: 12),
              if (kind == DocumentKind.liability || kind == DocumentKind.casco)
                dateField(start, 'Валидна от (незадължително)', optional: true),
              dateField(end, 'Валидна до'),
            ],
            if (kind.permitsPayments) ...[
              const SizedBox(height: 16),
              Text(
                kind == DocumentKind.tax
                    ? 'Плащания'
                    : 'Вноски (незадължителни)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              for (var i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Вноска ${i + 1}'),
                      dateField(fields[i].due, 'Падеж'),
                      TextFormField(
                        controller: fields[i].amount,
                        decoration: const InputDecoration(
                          labelText: 'Сума (€)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (s) => parseCents(s ?? '') == null
                            ? 'Въведи валидна сума'
                            : null,
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Платена'),
                        value: fields[i].paid,
                        onChanged: busy
                            ? null
                            : (v) =>
                                  setState(() => fields[i].paid = v ?? false),
                      ),
                      if (kind != DocumentKind.tax || fields.length > 1)
                        TextButton(
                          onPressed: busy
                              ? null
                              : () {
                                  final p = fields[i];
                                  setState(() => fields.removeAt(i));
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => p.dispose(),
                                  );
                                },
                          child: const Text('Премахни вноската'),
                        ),
                      const Divider(),
                    ],
                  ),
                ),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => setState(() => fields.add(_PaymentFields())),
                child: const Text('Добави вноска'),
              ),
            ],
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('document-save'),
              onPressed: busy ? null : save,
              child: Text(busy ? 'Записване…' : 'Запази'),
            ),
          ],
        ),
      ),
    ),
  );
}
