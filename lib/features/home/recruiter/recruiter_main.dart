// lib/screens/recruiter/recruiter_main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_finder_app/features/home/recruiter/create_job.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_dashboard.dart';
import 'package:job_finder_app/features/home/recruiter/recruiter_applications_screen.dart';
import 'package:job_finder_app/models/job_opening.dart';
import 'package:job_finder_app/core/providers/recruiter_jobs_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class RecruiterMainScreen extends ConsumerStatefulWidget {
  // ignore: use_super_parameters
  const RecruiterMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterMainScreen> createState() =>
      _RecruiterMainScreenState();
}

class _RecruiterMainScreenState extends ConsumerState<RecruiterMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const RecruiterDashboard(),
    const RecruiterJobsScreen(), // <-- Replace CreateJobScreen
    const RecruiterApplicationsScreen(),
    // const ProfileTab(),      // You'll create this later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4A90E2),
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), // Changed icon
              activeIcon: Icon(Icons.work), // Changed icon
              label: 'Jobs', // Changed label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox),
              label: 'Applications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class RecruiterJobsScreen extends ConsumerStatefulWidget {
  const RecruiterJobsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecruiterJobsScreen> createState() =>
      _RecruiterJobsScreenState();
}

class _RecruiterJobsScreenState extends ConsumerState<RecruiterJobsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(recruiterJobsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search jobs...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                ],
              )
            : const Text(
                'Jobs',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
        actions: !_isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create-job');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Job',
      ),
      body: jobsAsync.when(
        data: (jobs) {
          final filteredJobs = _searchQuery.isEmpty
              ? jobs
              : jobs.where((job) {
                  final query = _searchQuery.toLowerCase();
                  return job.title.toLowerCase().contains(query) ||
                      job.companyName.toLowerCase().contains(query) ||
                      job.location.toLowerCase().contains(query);
                }).toList();
          if (filteredJobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No jobs found.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first job!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredJobs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final job = filteredJobs[index];
              Color statusColor;
              String statusLabel;
              switch (job.status) {
                case 'active':
                  statusColor = Colors.green;
                  statusLabel = 'Active';
                  break;
                case 'paused':
                  statusColor = Colors.orange;
                  statusLabel = 'Paused';
                  break;
                case 'closed':
                  statusColor = Colors.grey;
                  statusLabel = 'Closed';
                  break;
                default:
                  statusColor = Colors.blueGrey;
                  statusLabel = job.status;
              }
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              job.companyName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '·',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              job.location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black45,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      const SizedBox(height: 10),
                      Text(
                        job.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            tooltip: 'Edit',
                            onPressed: () async {
                              await context.push(
                                '/edit-job/${job.id}',
                                extra: job,
                              );
                              ref.refresh(recruiterJobsProvider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete',
                            onPressed: () async {
                              final supabase = Supabase.instance.client;
                              await supabase
                                  .from('job_openings')
                                  .delete()
                                  .eq('id', job.id);
                              ref.refresh(recruiterJobsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Job deleted successfully!'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                          ),
                          const Spacer(),
                          Text(
                            'Posted: '
                            '${job.createdAt.day.toString().padLeft(2, '0')}-'
                            '${job.createdAt.month.toString().padLeft(2, '0')}-'
                            '${job.createdAt.year}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: ' + e.toString())),
      ),
    );
  }
}
