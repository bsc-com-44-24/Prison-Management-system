import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../Inmate_management/models/inmate_model.dart';
import '../services/release_database.dart';
import '../widgets/release_inmate_card.dart';
import '../widgets/release_bottom_nav.dart';
import 'release_processing_screen.dart';

class ReleaseManagementScreen extends StatefulWidget {
  const ReleaseManagementScreen({super.key});

  @override
  State<ReleaseManagementScreen> createState() =>
      _ReleaseManagementScreenState();
}

class _ReleaseManagementScreenState
    extends State<ReleaseManagementScreen> {
  static const Color primaryColor = Color(0xFF344B3B);
  static const Color burgundy = Color(0xFF801F32);

  List<InmateModel> inmates = [];
  List<Map<String, Object?>> releases = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReleaseData();
  }

  // Load inmate information from Hive and release records from SQLite.
  Future<void> loadReleaseData() async {
    try {
      final box = Hive.box('inmates_box');

      final inmateList = box.values.map((item) {
        return InmateModel.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      // Create release records for inmates with release dates.
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
        SnackBar(
          content: Text('Error loading releases: $e'),
        ),
      );
    }
  }

  // Upcoming release records.
  List<Map<String, Object?>> get upcomingReleases {
    return releases.where((release) {
      return release['release_status'] != 'Released';
    }).toList();
  }

  // Completed release records.
  List<Map<String, Object?>> get completedReleases {
    return releases.where((release) {
      return release['release_status'] == 'Released';
    }).toList();
  }

  // Find the corresponding inmate using their ID.
  InmateModel? findInmate(String inmateId) {
    try {
      return inmates.firstWhere(
        (inmate) => inmate.id == inmateId,
      );
    } catch (_) {
      return null;
    }
  }

  // Display release cards.
  Widget buildReleaseList(
    List<Map<String, Object?>> releaseList,
    String status,
  ) {
    if (releaseList.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadReleaseData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 220),
            Center(
              child: Text(
                'No release records found.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadReleaseData,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 20,
        ),
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
                  builder: (context) =>
                      ReleaseProcessingScreen(
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
        backgroundColor: const Color(0xFFF4F6F5),

        // Header and tabs.
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 75,

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(22),
            ),
          ),

          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 23,
            ),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),

          title: const Text(
            'Release Management',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(58),
            child: Container(
              color: const Color(0xFFF4F6F5),
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                12,
              ),

              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,

                  indicator: BoxDecoration(
                    color: burgundy,
                    borderRadius: BorderRadius.circular(9),
                  ),

                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,

                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),

                  dividerColor: Colors.transparent,

                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Released'),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Upcoming and Released lists.
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

        // Bottom navigation.
        bottomNavigationBar: const ReleaseBottomNav(),
      ),
    );
  }
}