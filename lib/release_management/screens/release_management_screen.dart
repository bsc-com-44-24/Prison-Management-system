import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../Inmate_management/models/inmate_model.dart';
import '../services/release_database.dart';
import '../widgets/release_inmate_card.dart';
import '../screens/release_processing_screen.dart';


class ReleaseManagementScreen extends StatefulWidget {
  const ReleaseManagementScreen({super.key});

  @override
  State<ReleaseManagementScreen> createState() =>
      _ReleaseManagementScreenState();
}

class _ReleaseManagementScreenState
    extends State<ReleaseManagementScreen> {
  static const Color primaryColor = Color(0xFF344B3B);

  List<InmateModel> inmates = [];
  List<Map<String, Object?>> releases = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReleaseData();
  }

  Future<void> loadReleaseData() async {
    try {
      final box = Hive.box('inmates_box');

      final inmateList = box.values.map((item) {
        return InmateModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      // Register inmates with valid release dates.
      for (final inmate in inmateList) {
        if (inmate.releaseDate.isNotEmpty) {
          await ReleaseDatabase.instance.addRelease(
            inmateId: inmate.id,
            releaseDate: inmate.releaseDate,
          );
        }
      }

      final releaseList =
          await ReleaseDatabase.instance.getAllReleases();

      if (!mounted) return;

      setState(() {
        inmates = inmateList;
        releases = releaseList;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading releases: $e')),
      );
    }
  }

  List<Map<String, Object?>> get upcomingReleases {
    return releases.where((release) {
      return release['release_status'] != 'Released';
    }).toList();
  }

  List<Map<String, Object?>> get completedReleases {
    return releases.where((release) {
      return release['release_status'] == 'Released';
    }).toList();
  }

  InmateModel? findInmate(String inmateId) {
    try {
      return inmates.firstWhere(
        (inmate) => inmate.id == inmateId,
      );
    } catch (_) {
      return null;
    }
  }

  Widget buildReleaseList(
    List<Map<String, Object?>> releaseList,
    String status,
  ) {
    if (releaseList.isEmpty) {
      return const Center(
        child: Text(
          'No release records found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadReleaseData,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 20),
        itemCount: releaseList.length,
        itemBuilder: (context, index) {
          final release = releaseList[index];

          final inmate = findInmate(
            release['inmate_id'] as String,
          );

          if (inmate == null) {
            return const SizedBox.shrink();
          }

          return ReleaseInmateCard(
            inmate: inmate,
            status: status,
          onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReleaseProcessingScreen(
        inmate: inmate,
        release: release,
      ),
    ),
  ).then((_) => loadReleaseData());
},
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          title: const Text('Release Management'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Released'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                children: [
                  buildReleaseList(
                    upcomingReleases,
                    'Upcoming',
                  ),
                  buildReleaseList(
                    completedReleases,
                    'Released',
                  ),
                ],
              ),
      ),
    );
  }
}