class DocumentUploadStats {
  final List<String> monthNames;
  final List<int> monthlyDocumentUploads;

  DocumentUploadStats(this.monthNames, this.monthlyDocumentUploads);

  factory DocumentUploadStats.fromJson(Map<String, dynamic> json) {
    // Extract month names and monthly document uploads from the JSON data
    List<String> monthNames = List<String>.from(json['monthNames']);
    List<int> monthlyDocumentUploads = List<int>.from(json['monthlyDocumentUploadsTable']);

    return DocumentUploadStats(monthNames, monthlyDocumentUploads);
  }
}
