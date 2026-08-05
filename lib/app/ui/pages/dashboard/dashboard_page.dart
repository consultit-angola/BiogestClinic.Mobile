import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/index.dart';
import '../../index.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      drawer: customDrawer(),
      body: Column(
        children: [
          customAppbar(),
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                onRefresh: () => controller.load(controller.period.value),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 92),
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: CustomColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _periodSelector(),
                    const SizedBox(height: 18),
                    if (controller.loading.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (controller.data.isEmpty)
                      _empty()
                    else ...[
                      _title('Resumo operacional'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.55,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          _kpi(
                            'Novos clientes',
                            controller.nestedInt(
                              'ClientTotal',
                              'NewClientsCount',
                            ),
                            Icons.person_add_alt,
                            CustomColors.primaryColor,
                          ),
                          _kpi(
                            'Clientes regulares',
                            controller.nestedInt(
                              'ClientTotal',
                              'RegularClientsCount',
                            ),
                            Icons.people_outline,
                            CustomColors.secondaryColor,
                          ),
                          _kpi(
                            'Facturadas',
                            controller.nestedInt(
                              'FinancialTotal',
                              'BilledCount',
                            ),
                            Icons.receipt_long_outlined,
                            CustomColors.primaryDarkerColor,
                          ),
                          _kpi(
                            'Não facturadas',
                            controller.nestedInt(
                              'FinancialTotal',
                              'UnbilledCount',
                            ),
                            Icons.pending_actions_outlined,
                            CustomColors.warningColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _title('Consultas por estado'),
                      const SizedBox(height: 10),
                      _listCard(
                        controller.items('DashboardAppointmentByState'),
                        'Name',
                        'ApptCount',
                      ),
                      const SizedBox(height: 24),
                      _title('Consultas por especialidade'),
                      const SizedBox(height: 10),
                      _specialtyCard(),
                      const SizedBox(height: 24),
                      _title('Serviços mais facturados'),
                      const SizedBox(height: 10),
                      _listCard(
                        controller.items(
                          'DashboardBilledServicesSortedByTotalAmount',
                        ),
                        'Name',
                        'TotalAmount',
                        money: true,
                      ),
                      const SizedBox(height: 24),
                      _title('Produtos mais facturados'),
                      const SizedBox(height: 10),
                      _listCard(
                        controller.items(
                          'DashboardBilledProductsSortedByTotalAmount',
                        ),
                        'Name',
                        'TotalAmount',
                        money: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: customMenu(alignBottom: false),
    );
  }

  Widget _periodSelector() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: CustomColors.borderColor),
    ),
    child: Row(
      children: [
        _period('Hoje', 'today'),
        _period('Semana', 'week'),
        _period('Mês', 'month'),
      ],
    ),
  );

  Widget _period(String label, String value) => Expanded(
    child: InkWell(
      onTap: () => controller.load(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: controller.period.value == value
              ? CustomColors.primaryDarkerColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: controller.period.value == value
                ? Colors.white
                : CustomColors.mutedTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: CustomColors.textColor,
    ),
  );

  Widget _kpi(String label, int value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomColors.borderColor),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CustomColors.mutedTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _listCard(
    List<Map<String, dynamic>> items,
    String labelKey,
    String valueKey, {
    bool money = false,
  }) {
    final visibleItems = items.take(6).toList();
    if (visibleItems.isEmpty) return _empty();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: Column(
        children: visibleItems.map((item) {
          final rawValue = item[valueKey] as num? ?? 0;
          final value = money
              ? '${rawValue.toStringAsFixed(2)} Kz'
              : rawValue.toInt().toString();
          return ListTile(
            dense: true,
            title: Text(item[labelKey]?.toString() ?? '-'),
            trailing: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: CustomColors.primaryColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _specialtyCard() {
    final items = controller
        .items('DashboardAppointmentBySpeciality')
        .take(6)
        .toList();
    if (items.isEmpty) return _empty();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColors.borderColor),
      ),
      child: Column(
        children: items
            .map(
              (item) => ExpansionTile(
                title: Text(item['Name']?.toString() ?? '-'),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _smallStat('Agendadas', item['ScheduledCount']),
                      _smallStat('Em curso', item['InExecutionCount']),
                      _smallStat('Concluídas', item['FinishedCount']),
                      _smallStat('Canceladas', item['CanceledCount']),
                    ],
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _smallStat(String label, dynamic value) => Column(
    children: [
      Text(
        '${value ?? 0}',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: CustomColors.primaryDarkerColor,
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 9, color: CustomColors.mutedTextColor),
      ),
    ],
  );
  Widget _empty() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomColors.borderColor),
    ),
    child: const Center(
      child: Text(
        'Sem dados disponíveis para o período.',
        style: TextStyle(color: CustomColors.mutedTextColor),
      ),
    ),
  );
}
