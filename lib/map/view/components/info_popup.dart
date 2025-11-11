import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:soluciona/data/models/report_model.dart';
import 'package:soluciona/main.dart';

void InfoPopup(BuildContext context, Report report) {
  showPopupCard(
    context: context,
    alignment: Alignment.center,
    useSafeArea: true,
    dimBackground: true,
    builder: (context) {
      return PopupCard(
        elevation: 12,
        color: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          width: 320,
          // height: 480, // <-- REMOVA O HEIGHT FIXO
          constraints: const BoxConstraints(
            maxHeight: 480, // <-- ADICIONE UMA ALTURA MÁXIMA
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            // <-- ENVOLVA A COLUNA COM ESTE WIDGET
            child: Column(
              mainAxisSize:
                  MainAxisSize
                      .min, // <-- IMPORTANTE: Para a coluna encolher se o conteúdo for pequeno
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(
                        Icons.report_problem,
                        color: Colors.redAccent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Divider(),

                const SizedBox(height: 12),

                const Text(
                  "Descrição:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  report.description,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Endereço:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        report.address,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (report.images.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        report.images[0],
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: mediumBlue,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
