import 'package:flutter/material.dart';
import 'package:soluciona/data/models/report_model.dart';
import 'package:soluciona/map/view/components/info_popup.dart';

void ModalBottomSheet(BuildContext context, List<Report> _reports) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(32.0),
        child:
            _reports.isEmpty
                ? const Text(
                  "Não há problemas disponíveis no momento em sua região",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
                : ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.report_problem),
                        title: Text(_reports[index].name.toString()),
                        subtitle: Text(_reports[index].address.toString()),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(width: 2),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            InfoPopup(context, _reports[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
      );
    },
  );
}
