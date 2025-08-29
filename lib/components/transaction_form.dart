import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/models/transaction_model.dart';
import 'package:transly_api_app/utils/date_helper.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final Future<void> Function(Transaction) onSubmit;
  final bool isLoading;

  const TransactionForm({
    this.transaction,
    required this.onSubmit,
    this.isLoading = false,
    super.key,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController amountController;
  late final TextEditingController descController;

  late final Rx<int?> selectedType;
  late final Rx<DateTime> selectedDate;

  final RxBool _typeHasError = false.obs;

  @override
  void initState() {
    super.initState();
    selectedType = (widget.transaction?.type).obs;
    selectedDate = (widget.transaction?.date ?? DateTime.now().toUtc()).obs;
    nameController = TextEditingController(
      text: widget.transaction?.name ?? '',
    );
    amountController = TextEditingController(
      text:
          widget.transaction?.amount == null || widget.transaction?.amount == 0
          ? ''
          : widget.transaction!.amount.toStringAsFixed(2).replaceAll('.00', ''),
    );
    descController = TextEditingController(
      text: widget.transaction?.desc ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final localDate = toLocalDateForPicker(selectedDate.value);
    final date = await showDatePicker(
      context: context,
      initialDate: localDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      selectedDate.value = toUtcFromPicker(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children:
            [
                  _buildTypeSelector(context),
                  const SizedBox(height: 24),
                  _buildFormFieldsContainer(context),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ]
                .animate(interval: 80.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text('ประเภทรายการ', style: theme.textTheme.titleLarge),
        ),
        Obx(() {
          return Row(
            children: [
              Expanded(
                child: _TypeSelectionCard(
                  label: 'รายรับ',
                  icon: Icons.download_rounded,
                  color: theme.colorScheme.tertiary,
                  isSelected: selectedType.value == 1,
                  onTap: () {
                    selectedType.value = 1;
                    _typeHasError.value = false;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TypeSelectionCard(
                  label: 'รายจ่าย',
                  icon: Icons.upload_rounded,
                  color: theme.colorScheme.error,
                  isSelected: selectedType.value == -1,
                  onTap: () {
                    selectedType.value = -1;
                    _typeHasError.value = false;
                  },
                ),
              ),
            ],
          );
        }),
        Obx(() {
          if (!_typeHasError.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              'กรุณาเลือกประเภทรายการ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormFieldsContainer(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('รายละเอียด'),
            _buildNameField(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 20),
            _buildDateField(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'ชื่อรายการ',
        prefixIcon: Icon(Icons.drive_file_rename_outline_rounded),
        hintText: 'เช่น ค่าอาหาร, เงินเดือน',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'กรุณากรอกชื่อรายการ';
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'จำนวนเงิน',
        prefixIcon: Icon(Icons.paid_outlined),
        suffixText: 'บาท',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'กรุณากรอกจำนวนเงิน';
        final number = double.tryParse(value);
        if (number == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
        if (number <= 0) return 'จำนวนเงินต้องมากกว่า 0';
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descController,
      decoration: const InputDecoration(
        labelText: 'คำอธิบาย (ไม่บังคับ)',
        prefixIcon: Icon(Icons.notes_rounded),
      ),
      maxLines: 3,
      minLines: 1,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: TextEditingController(
          text: formatThaiDateShort(selectedDate.value),
        ),
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'วันที่',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading
            ? null
            : () async {
                final isFormValid = formKey.currentState!.validate();
                if (selectedType.value == null) {
                  _typeHasError.value = true;
                  return;
                }
                if (isFormValid) {
                  final now = DateTime.now().toUtc();
                  final transaction = Transaction(
                    uuid: widget.transaction?.uuid,
                    name: nameController.text.trim(),
                    amount: double.parse(amountController.text),
                    type: selectedType.value!,
                    desc: descController.text.trim().isEmpty
                        ? null
                        : descController.text.trim(),
                    date: selectedDate.value,
                    createdAt: widget.transaction?.createdAt ?? now,
                    updatedAt: now,
                  );
                  await widget.onSubmit(transaction);
                }
              },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.isLoading
              ? SizedBox(
                  key: const ValueKey('indicator'),
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white.withOpacity(0.9),
                  ),
                )
              : Text(
                  key: const ValueKey('text'),
                  widget.transaction != null ? 'บันทึกการแก้ไข' : 'เพิ่มรายการ',
                ),
        ),
      ),
    );
  }
}

class _TypeSelectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
