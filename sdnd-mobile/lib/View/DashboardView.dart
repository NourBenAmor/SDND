import 'package:flutter/material.dart';
import '../Controller/DashboardController.dart';
import '../Model/DashboardData.dart';
import '../Model/document_upload_stats.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardView extends StatefulWidget {
  final String token;

  const DashboardView({Key? key, required this.token}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Future<DashboardData> _fileDataFuture;
  late Future<DashboardData> _userDataFuture;
  late Future<DocumentUploadStats> _documentUploadStatsFuture;
  late Future<Map<String, dynamic>> _documentStatisticsFuture; // Add this line

  final DashboardController _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    _fileDataFuture = _controller.fetchFileData(widget.token);
    _userDataFuture = _controller.fetchUserData(widget.token);
    _documentUploadStatsFuture =
        _controller.fetchDocumentUploadStats(widget.token);
    _documentStatisticsFuture = _controller.fetchDocumentStatistics(
        widget.token); // Initialize _documentStatisticsFuture

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors
            .yellow[700], // Set app bar background color to yellow
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Adjust padding for better spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Align items to the start of the column
            children: [
              SizedBox(height: 20),
              // Add some space between the app bar and content
              Text(
                'Overview', // Add a section title for better organization
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[700], // Use yellow for emphasis
                ),
              ),
              SizedBox(height: 20),
              // Add space between section title and items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildDashboardItem('Total Files', _fileDataFuture),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDashboardItem('Total Users', _userDataFuture),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Add space between the rows
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTotalDocumentsItem(),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDocumentsByStateItem(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Add more space between the dashboard items and the chart
              Center(
                child: Text(
                  'Monthly Added Documents', // Add a title for the chart section
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[700], // Use yellow for emphasis
                  ),
                ),
              ),

              SizedBox(height: 10),
              // Add space between chart title and chart
              FutureBuilder<DocumentUploadStats>(
                future: _documentUploadStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return _buildLineChart(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(String title, Future<DashboardData> future) {
    IconData? iconData;
    Color? iconColor;

    if (title == 'Total Files') {
      iconData = Icons.insert_drive_file; // File icon
      iconColor = Colors.blue;
    } else if (title == 'Total Users') {
      iconData = Icons.person; // User profile icon
      iconColor = Colors.green;
    } else if (title == 'Total Documents') {
      iconData = Icons.folder; // Folder icon
      iconColor = Colors.orange;
    }

    return Expanded(
      child: Card(
        elevation: 4, // Add elevation for a raised effect
        color: Colors.yellow[100], // Set card background color to light yellow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<DashboardData>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                String dataText = '';
                if (title == 'Total Files') {
                  dataText = '${snapshot.data!.totalFiles}';
                } else if (title == 'Total Users') {
                  dataText = '${snapshot.data!.totalUsers}';
                } else if (title == 'Total Documents') {
                  dataText = '${snapshot.data!.totalDocuments}';
                }
                return Column(
                  children: [
                    if (iconData != null && iconColor !=
                        null) // Check if iconData and iconColor are not null
                      Icon(
                        iconData,
                        color: iconColor,
                        size: 40,
                      ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Use black for text color
                        ),
                      ),
                      subtitle: Text(
                        dataText,
                        style: TextStyle(
                          color: Colors.black87, // Use a darker color for text
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTotalDocumentsItem() {
    return Expanded(
      child: Card(
        elevation: 4,
        color: Colors.yellow[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder,
                size: 40,
                color: Colors.orange,
              ),
              SizedBox(height: 10),
              Text(
                'Total Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
                future: _documentStatisticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final totalDocuments = snapshot.data?['totalDocuments'];
                    return Text(
                      totalDocuments != null
                          ? ' $totalDocuments'
                          : 'No data available',
                      style: TextStyle(fontSize: 16),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildDocumentsByStateItem() {
    return Expanded(
      child: Card(
        elevation: 4,
        color: Colors.yellow[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              FutureBuilder<Map<String, dynamic>>(
                future: _documentStatisticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final documentsByState = snapshot.data?['documentsByState'];
                    return Column(
                      children: documentsByState != null
                          ? (documentsByState as List<dynamic>).map<Widget>((stateData) {
                        final state = (() {
                          int statusCode = stateData['state'];
                          switch (statusCode) {
                            case 0:
                              return 'Blank';
                            case 1:
                              return 'Filled';
                            case 2:
                              return 'Shared';
                            case 3:
                              return 'Archived';
                            default:
                              return 'Unknown';
                          }
                        })();
                        final count = stateData['count'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFAA33),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '$count', // Append 'Document' after state
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // Set fontWeight to bold
                                    color: Colors.black,
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      }).toList()
                          : [Text('No data available')],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(DocumentUploadStats documentUploadStats) {
    double maxYValue = 12; // Default maximum value

    if (documentUploadStats.monthlyDocumentUploads.isNotEmpty) {
      // Calculate the maximum value from valid data
      maxYValue = documentUploadStats.monthlyDocumentUploads.reduce((a, b) => a > b ? a : b).toDouble() + 10;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Set background color for the chart
        borderRadius: BorderRadius.circular(16), // Optional: Add border radius for a modern look
      ),
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(documentUploadStats.monthNames.length, (index) {
                  return FlSpot(index.toDouble(), documentUploadStats.monthlyDocumentUploads[index].toDouble());
                }),
                isCurved: true,
                colors: [Colors.blue],
                barWidth: 4,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(show: false), // Hide dots
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14),
                getTitles: (value) {
                  int intValue = value.toInt();
                  if (intValue >= 0 && intValue < documentUploadStats.monthNames.length) {
                    return documentUploadStats.monthNames[intValue].substring(0, 3); // Show abbreviated month names
                  }
                  return '';
                },
                margin: 16,
              ),
              leftTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 14),
                interval: 2,
                margin: 16,
              ),
            ),
            borderData: FlBorderData(show: false), // Hide border
            minX: 0,
            maxX: documentUploadStats.monthNames.length.toDouble() - 1,
            minY: 0,
            maxY: maxYValue,
          ),
        ),
      ),
    );
  }

}



