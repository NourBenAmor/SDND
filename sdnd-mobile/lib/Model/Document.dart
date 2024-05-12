import 'package:flutter/cupertino.dart';

class Document {
  final String id;
  final String documentId;
  final String name;
  final String description;
  final String ownerId;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String documentState;
  final List<String> files;

  Document({
    required this.id,
    required this.documentId,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.addedDate,
    required this.updatedDate,
    required this.documentState,
    required this.files,
  });
}

class DocumentQueryObject {
  final String? name;
  final String? description;
  final State? documentState;
  final DateTime? addedDateBefore;
  final DateTime? addedDateAfter;
  final DateTime? updatedDateBefore;
  final DateTime? updatedDateAfter;

  DocumentQueryObject({
    this.name,
    this.description,
    this.documentState,
    this.addedDateBefore,
    this.addedDateAfter,
    this.updatedDateBefore,
    this.updatedDateAfter,
  });
}

enum DocumentState {
  Blank,
  Filled,
  Shared,
  Archived,
}
