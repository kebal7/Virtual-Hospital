import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Ensure Firebase is initialized before the app starts
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          const LabReportsPage(), // Setting the home page to the Lab Reports page
    );
  }
}

class LabReportsPage extends StatelessWidget {
  const LabReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Assume the logged-in patient ID is "1shishir"
    const String patientId = "1shishir";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Reports'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('Lab Reports')
            .where('patientId', isEqualTo: patientId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading reports'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reports available'));
          }

          // Extract the list of reports
          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ListTile(
                title: Text('Report ID: ${report['reportId']}'),
                onTap: () {
                  // Navigate to the report view page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportViewPage(
                        reportFileUrl: report['reportFileUrl'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ReportViewPage extends StatelessWidget {
  final String reportFileUrl;

  const ReportViewPage({super.key, required this.reportFileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Report'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Image.network(
          reportFileUrl,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return const Icon(
              Icons.error,
              color: Colors.red,
              size: 50.0,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
