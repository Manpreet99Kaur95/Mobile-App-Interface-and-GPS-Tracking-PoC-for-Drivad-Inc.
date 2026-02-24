import 'package:flutter/material.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("My Campaigns", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Create Campaign"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Manage your advertising campaigns", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _campaignCard(
            title: "Downtown Coffee Shop Promo",
            description: "Promote our new coffee blend in downtown areas",
            budget: "\$5,000",
            duration: "30 days",
            impressions: "125,000",
            reach: "45,000",
            location: "Downtown, City Center",
            applicants: "15",
            approvedDrivers: "5",
            isActive: true,
          ),
          const SizedBox(height: 16),
          _campaignCard(
            title: "Tech Startup Launch",
            description: "Brand awareness campaign for new mobile app",
            budget: "\$10,000",
            duration: "60 days",
            impressions: "250,000",
            reach: "85,000",
            location: "Tech District, University Area",
            applicants: "25",
            approvedDrivers: "10",
            isActive: true,
          ),
           const SizedBox(height: 16),
          _campaignCard(
            title: "Fitness Center Grand Opening",
            description: "Promote our new fitness center location",
            budget: "\$7,500",
            duration: "45 days",
            impressions: "180,000",
            reach: "60,000",
            location: "Suburban Mall",
            applicants: "20",
            approvedDrivers: "8",
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _campaignCard({
    required String title,
    required String description,
    required String budget,
    required String duration,
    required String impressions,
    required String reach,
    required String location,
    required String applicants,
    required String approvedDrivers,
    required bool isActive,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade100 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(isActive ? "Active" : "Pending", style: TextStyle(color: isActive ? Colors.green.shade800 : Colors.grey.shade700, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Budget", budget),
                _infoColumn("Duration", duration),
                _infoColumn("Applicants", applicants),
                _infoColumn("Approved Drivers", approvedDrivers),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.track_changes, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("$impressions Impressions"),
                const SizedBox(width: 16),
                const Icon(Icons.person_pin_circle_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("$reach Reach"),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("View Applicants"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
