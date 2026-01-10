import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';
import 'package:mrsheaf/features/support/controllers/support_tickets_controller.dart';

class SupportTicketsScreen extends GetView<SupportTicketsController> {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('support_tickets'.tr),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF262626),
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _showCreateTicketDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.tickets.isEmpty) {
          return Center(
            child: Text(
              'no_tickets'.tr,
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTickets,
          color: AppColors.primaryColor,
          child: ListView.separated(
            itemCount: controller.tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = controller.tickets[index];
              final id = (t['id'] as num?)?.toInt() ?? 0;
              final subject = (t['subject'] ?? '').toString();
              final status = (t['status'] ?? '').toString();
              return ListTile(
                title: Text(subject.isEmpty ? 'no_subject'.tr : subject),
                subtitle: Text('${'status_prefix'.tr}$status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => controller.openTicket(id),
              );
            },
          ),
        );
      }),
    );
  }

  void _showCreateTicketDialog() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('new_ticket'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'ticket_subject'.tr,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'ticket_description'.tr,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () async {
              final subject = subjectController.text.trim();
              final desc = descriptionController.text.trim();
              if (subject.isEmpty) return;
              Get.back();
              await controller.createTicket(
                subject: subject,
                description: desc.isEmpty ? null : desc,
              );
            },
            child: Text('submit'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).whenComplete(() {
      subjectController.dispose();
      descriptionController.dispose();
    });
  }
}
