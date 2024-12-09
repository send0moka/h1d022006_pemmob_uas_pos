import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:h1d022006_pemmob_uas_pos/controllers/cashier_controller.dart';

class PaymentDialog extends StatelessWidget {
  final double totalAmount;
  final Function(double) onConfirm;
  final CashierController controller;

  PaymentDialog({super.key, 
    required this.totalAmount,
    required this.onConfirm,
    required this.controller,
  });

  final TextEditingController paymentController = TextEditingController();
  final RxDouble paymentAmount = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: paymentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Payment Amount',
              prefixText: 'Rp ',
            ),
            autofocus: true,
            onChanged: (value) {
              paymentAmount.value = double.tryParse(value) ?? 0;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Total: ${controller.formatPrice(totalAmount)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _PaymentStatus(
            paymentAmount: paymentAmount,
            totalAmount: totalAmount,
            controller: controller,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (paymentAmount.value >= totalAmount) {
              onConfirm(paymentAmount.value);
              Get.back(result: true);
            } else {
              Get.snackbar(
                'Error',
                'Insufficient payment amount',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class _PaymentStatus extends StatelessWidget {
  final Rx<double> paymentAmount;
  final double totalAmount;
  final CashierController controller;

  const _PaymentStatus({
    required this.paymentAmount,
    required this.totalAmount,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      double change = paymentAmount.value - totalAmount;
      
      if (paymentAmount.value == 0) {
        return const Text('Please enter payment amount');
      } else if (change < 0) {
        return Text(
          'Insufficient amount: ${controller.formatPrice(change.abs())} more needed',
          style: const TextStyle(color: Colors.red),
        );
      } else if (change == 0) {
        return const Text(
          'Exact amount',
          style: TextStyle(color: Colors.green),
        );
      } else {
        return Text(
          'Change: ${controller.formatPrice(change)}',
          style: const TextStyle(color: Colors.green),
        );
      }
    });
  }
}