import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class MerchantMessagesScreen extends StatelessWidget {
  const MerchantMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Messages List
            Expanded(
              child: _buildMessagesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'المحادثات',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDarkColor,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '3 رسائل جديدة',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildMessageCard(index);
      },
    );
  }

  Widget _buildMessageCard(int index) {
    final messages = [
      {
        'name': 'أحمد محمد',
        'message': 'هل يمكن تغيير الطلب؟',
        'time': '10:30 ص',
        'unread': true,
        'avatar': 'A',
        'orderNumber': '#1234',
      },
      {
        'name': 'فاطمة علي',
        'message': 'شكراً لك، الطلب كان ممتاز',
        'time': '10:15 ص',
        'unread': false,
        'avatar': 'ف',
        'orderNumber': '#1233',
      },
      {
        'name': 'محمد أحمد',
        'message': 'متى سيكون الطلب جاهز؟',
        'time': '09:45 ص',
        'unread': true,
        'avatar': 'م',
        'orderNumber': '#1232',
      },
      {
        'name': 'سارة خالد',
        'message': 'هل يمكن إضافة المزيد من التوابل؟',
        'time': '09:30 ص',
        'unread': false,
        'avatar': 'س',
        'orderNumber': '#1231',
      },
      {
        'name': 'عبدالله سعد',
        'message': 'الطلب وصل، شكراً لكم',
        'time': '09:15 ص',
        'unread': false,
        'avatar': 'ع',
        'orderNumber': '#1230',
      },
      {
        'name': 'نورا أحمد',
        'message': 'هل يمكن تأجيل الطلب؟',
        'time': '09:00 ص',
        'unread': true,
        'avatar': 'ن',
        'orderNumber': '#1229',
      },
      {
        'name': 'خالد محمد',
        'message': 'الطعام كان لذيذ جداً',
        'time': '08:45 ص',
        'unread': false,
        'avatar': 'خ',
        'orderNumber': '#1228',
      },
      {
        'name': 'ريم سالم',
        'message': 'أين عنوان التوصيل؟',
        'time': '08:30 ص',
        'unread': false,
        'avatar': 'ر',
        'orderNumber': '#1227',
      },
      {
        'name': 'يوسف علي',
        'message': 'هل يمكن إلغاء الطلب؟',
        'time': '08:15 ص',
        'unread': false,
        'avatar': 'ي',
        'orderNumber': '#1226',
      },
      {
        'name': 'مريم أحمد',
        'message': 'الخدمة ممتازة، شكراً',
        'time': '08:00 ص',
        'unread': false,
        'avatar': 'م',
        'orderNumber': '#1225',
      },
    ];

    final message = messages[index % messages.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.primaryColor,
              child: Text(
                message['avatar'] as String,
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (message['unread'] as bool)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              message['name'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDarkColor,
              ),
            ),
            Text(
              message['time'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              'طلب ${message['orderNumber']}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message['message'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: (message['unread'] as bool) 
                    ? FontWeight.w600 
                    : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: () {
          Get.snackbar(
            'فتح المحادثة',
            'فتح محادثة مع ${message['name']} - ${message['orderNumber']}',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }
}
