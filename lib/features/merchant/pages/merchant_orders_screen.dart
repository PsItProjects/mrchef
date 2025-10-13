import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrsheaf/core/theme/app_theme.dart';

class MerchantOrdersScreen extends StatelessWidget {
  const MerchantOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filter Tabs
            _buildFilterTabs(),
            
            // Orders List
            Expanded(
              child: _buildOrdersList(),
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
            'الطلبات',
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
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '5 طلبات جديدة',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterTab('الكل', true),
          const SizedBox(width: 15),
          _buildFilterTab('جديد', false),
          const SizedBox(width: 15),
          _buildFilterTab('قيد التحضير', false),
          const SizedBox(width: 15),
          _buildFilterTab('مكتمل', false),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isSelected ? AppColors.secondaryColor : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildOrderCard(index);
      },
    );
  }

  Widget _buildOrderCard(int index) {
    final orders = [
      {
        'id': '#1234',
        'customer': 'أحمد محمد',
        'items': '3 عناصر',
        'amount': '150 ر.س',
        'time': '10:30 ص',
        'status': 'جديد',
        'statusColor': Colors.orange,
      },
      {
        'id': '#1233',
        'customer': 'فاطمة علي',
        'items': '2 عناصر',
        'amount': '89 ر.س',
        'time': '10:15 ص',
        'status': 'قيد التحضير',
        'statusColor': Colors.blue,
      },
      {
        'id': '#1232',
        'customer': 'محمد أحمد',
        'items': '5 عناصر',
        'amount': '200 ر.س',
        'time': '09:45 ص',
        'status': 'مكتمل',
        'statusColor': Colors.green,
      },
      {
        'id': '#1231',
        'customer': 'سارة خالد',
        'items': '1 عنصر',
        'amount': '45 ر.س',
        'time': '09:30 ص',
        'status': 'جديد',
        'statusColor': Colors.orange,
      },
      {
        'id': '#1230',
        'customer': 'عبدالله سعد',
        'items': '4 عناصر',
        'amount': '180 ر.س',
        'time': '09:15 ص',
        'status': 'قيد التحضير',
        'statusColor': Colors.blue,
      },
      {
        'id': '#1229',
        'customer': 'نورا أحمد',
        'items': '2 عناصر',
        'amount': '95 ر.س',
        'time': '09:00 ص',
        'status': 'مكتمل',
        'statusColor': Colors.green,
      },
      {
        'id': '#1228',
        'customer': 'خالد محمد',
        'items': '3 عناصر',
        'amount': '120 ر.س',
        'time': '08:45 ص',
        'status': 'جديد',
        'statusColor': Colors.orange,
      },
      {
        'id': '#1227',
        'customer': 'ريم سالم',
        'items': '6 عناصر',
        'amount': '250 ر.س',
        'time': '08:30 ص',
        'status': 'مكتمل',
        'statusColor': Colors.green,
      },
    ];

    final order = orders[index % orders.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب ${order['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order['customer'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (order['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: order['statusColor'] as Color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    order['items'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    order['time'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                order['amount'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.snackbar(
                      'تفاصيل الطلب',
                      'عرض تفاصيل الطلب ${order['id']}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'تحديث الحالة',
                      'تم تحديث حالة الطلب ${order['id']}',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'تحديث الحالة',
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
