import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PMU Dammam',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  String? selectedFileName;

  List<List<String>> excelData = [];

  final List<String> categories = [
    'Upload Data',
    'View All',
    'Unscheduled Order',
    'Monthly Production',
    'Inventory Management',
    'Purchase Order Requisition (POR)',
  ];

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null) return;

      Uint8List? bytes = result.files.single.bytes;

      if (bytes == null) return;

      Excel excel = Excel.decodeBytes(bytes);

      List<List<String>> tempData = [];

      for (var sheetName in excel.tables.keys) {
        var table = excel.tables[sheetName];

        if (table != null) {
          for (var row in table.rows) {
            tempData.add(
              row
                  .map(
                    (cell) =>
                        cell?.value?.toString() ?? '',
                  )
                  .toList(),
            );
          }
        }

        break;
      }

      setState(() {
        selectedFileName = result.files.single.name;
        excelData = tempData;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Uploaded: $selectedFileName'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Widget buildExcelTable() {
    if (excelData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No Excel file uploaded.',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: TableBorder.all(
          color: Colors.grey,
        ),
        columns: excelData.first
            .map(
              (header) => DataColumn(
                label: Text(
                  header,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        rows: excelData
            .skip(1)
            .map(
              (row) => DataRow(
                cells: row
                    .map(
                      (cell) => DataCell(
                        Text(cell),
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildComingSoon(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            '$title - Coming Soon',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hello, Afal 👋',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder:
                      (context, index) {
                    final isSelected =
                        selectedCategory == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });

                        // Open file picker immediately
                        if (index == 0) {
                          _pickExcelFile();
                        }
                      },
                      child: Container(
                        margin:
                            const EdgeInsets.only(
                          right: 10,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            25,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              if (selectedCategory == 1)
                buildComingSoon('View All'),

              if (selectedCategory == 2)
                buildComingSoon(
                  'Unscheduled Order',
                ),

              if (selectedCategory == 3)
                buildComingSoon(
                  'Monthly Production',
                ),

              if (selectedCategory == 4)
                buildComingSoon(
                  'Inventory Management',
                ),

              if (selectedCategory == 5)
                buildComingSoon(
                  'Purchase Order Requisition (POR)',
                ),

              const SizedBox(height: 20),

              if (selectedFileName != null)
                Text(
                  'File: $selectedFileName',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

              const SizedBox(height: 20),

              if (selectedCategory == 0)
                buildExcelTable(),
            ],
          ),
        ),
      ),
    );
  }
}