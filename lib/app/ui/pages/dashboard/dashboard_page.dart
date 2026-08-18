import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
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
                onRefresh: () => Future.wait([
                  controller.load(controller.period.value),
                  controller.loadClientStatistics(),
                  controller.loadRealTimeStatistics(),
                ]),
                child: ListView(
                  primary: false,
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
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
                    if (controller.data.isEmpty)
                      _empty()
                    else
                      ..._dashboardSections(),
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

  List<Widget> _dashboardSections() => [
    _title('Status de cancelamentos de consultas'),
    const SizedBox(height: 10),
    Row(
      children: [
        Expanded(
          child: _statusCard(
            'Canceladas',
            controller.appointmentStateCount('Canceled'),
            const Color(0xffF4434B),
            Icons.event_busy_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statusCard(
            'Desmarcadas',
            controller.appointmentStateCount('DeScheduled'),
            const Color(0xffF45B00),
            Icons.event_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statusCard(
            'Não comparecidas',
            controller.appointmentStateCount('DidNotAttend'),
            const Color(0xffBD2026),
            Icons.person_off_outlined,
          ),
        ),
      ],
    ),
    const SizedBox(height: 14),
    _pieCard(
      'Status de agendamento de pacientes',
      ['Novos', 'Recorrentes'],
      [
        controller.nestedInt('ClientTotal', 'NewClientsCount'),
        controller.nestedInt('ClientTotal', 'RegularClientsCount'),
      ],
      const [CustomColors.dashBoardGray, CustomColors.dashBoardYellow],
    ),
    const SizedBox(height: 14),
    _pieCard(
      'Status de facturação das consultas',
      ['Facturadas', 'Não facturadas'],
      [
        controller.nestedInt('FinancialTotal', 'BilledCount'),
        controller.nestedInt('FinancialTotal', 'UnbilledCount'),
      ],
      const [CustomColors.dashBoardGreen, CustomColors.dashBoardBlue],
    ),
    const SizedBox(height: 14),
    _specialtyChart(),
    const SizedBox(height: 14),
    _clientTrendChart(),
    const SizedBox(height: 14),
    _stackedChart(
      'Pacientes em atendimentos por faixa etária',
      controller.items('DashboardClientsByAge'),
      const [
        ('Infantil', 'InfantCount', Color(0xff4AD9FF)),
        ('Criança', 'ToddlerCount', Color(0xff0292B7)),
        ('Jovem', 'PreschoolerCount', Color(0xff006885)),
        ('Adulto', 'AdultCount', Color(0xff00394E)),
        ('Não definido', 'UndefinedCount', Color(0xff808080)),
      ],
    ),
    const SizedBox(height: 14),
    _stackedChart(
      'Pacientes em atendimentos por género',
      controller.items('DashboardClientsByGender'),
      const [
        ('Masculino', 'MaleCount', Color(0xff022719)),
        ('Feminino', 'FemaleCount', Color(0xff1F7A5A)),
        ('Não definido', 'UndefinedCount', Color(0xff808080)),
      ],
    ),
    const SizedBox(height: 14),
    _rankingCard(
      'Top serviços facturados',
      controller.items('DashboardBilledServicesSortedByTotalAmount'),
    ),
    const SizedBox(height: 14),
    _rankingCard(
      'Top produtos facturados',
      controller.items('DashboardBilledProductsSortedByTotalAmount'),
    ),
    const SizedBox(height: 14),
    _emergencyCard(),
  ];

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

  Widget _statusCard(String label, int value, Color color, IconData icon) =>
      Container(
        height: 105,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.white, size: 19),
              ],
            ),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  Widget _pieCard(
    String title,
    List<String> labels,
    List<int> values,
    List<Color> colors,
  ) {
    final visibleIndexes = List.generate(labels.length, (index) => index)
        .where((index) => controller.isChartSeriesVisible(title, labels[index]))
        .toList();
    final total = visibleIndexes.fold<int>(
      0,
      (sum, index) => sum + values[index],
    );
    return _card(
      title,
      Column(
        children: [
          SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 48,
                sectionsSpace: 1,
                sections: total == 0
                    ? [
                        PieChartSectionData(
                          value: 1,
                          color: CustomColors.borderColor,
                          radius: 34,
                          showTitle: false,
                        ),
                      ]
                    : visibleIndexes
                          .map(
                            (index) => PieChartSectionData(
                              value: values[index].toDouble(),
                              color: colors[index],
                              radius: 34,
                              title: '${values[index]}',
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                          .toList(),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: List.generate(
              labels.length,
              (index) => _legend(title, labels[index], colors[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialtyChart() {
    const chart = 'Consultas por especialidade';
    final items = [...controller.items('DashboardAppointmentBySpeciality')]
      ..sort(
        (a, b) => ((a['ID'] as num?) ?? 0).compareTo((b['ID'] as num?) ?? 0),
      );
    if (items.isEmpty) return _card('Consultas por especialidade', _empty());
    final chartWidth = math.max(620.0, items.length * 75.0);
    return _card(
      'Consultas por especialidade',
      Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: [
              _legend(chart, 'Marcadas', CustomColors.dashBoardYellow),
              _legend(chart, 'Em execução', CustomColors.dashBoardBlue),
              _legend(chart, 'Concluídas', CustomColors.dashBoardGreen),
              _legend(chart, 'Canceladas', CustomColors.dashBoardRed),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            primary: false,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartWidth,
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 62,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= items.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            meta: meta,
                            space: 6,
                            child: Transform.rotate(
                              angle: -0.55,
                              child: SizedBox(
                                width: 72,
                                child: Text(
                                  items[index]['Name']?.toString() ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 9),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(items.length, (index) {
                    final item = items[index];
                    return BarChartGroupData(
                      x: index,
                      barsSpace: 2,
                      barRods: [
                        if (controller.isChartSeriesVisible(chart, 'Marcadas'))
                          _rod(
                            item['ScheduledCount'],
                            CustomColors.dashBoardYellow,
                          ),
                        if (controller.isChartSeriesVisible(
                          chart,
                          'Em execução',
                        ))
                          _rod(
                            item['InExecutionCount'],
                            CustomColors.dashBoardBlue,
                          ),
                        if (controller.isChartSeriesVisible(
                          chart,
                          'Concluídas',
                        ))
                          _rod(
                            item['FinishedCount'],
                            CustomColors.dashBoardGreen,
                          ),
                        if (controller.isChartSeriesVisible(
                          chart,
                          'Canceladas',
                        ))
                          _rod(
                            item['CanceledCount'],
                            CustomColors.dashBoardRed,
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartRodData _rod(dynamic value, Color color) => BarChartRodData(
    toY: ((value as num?) ?? 0).toDouble(),
    color: color,
    width: 8,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
  );

  Widget _clientTrendChart() {
    const chart = 'Tendência de agendamento de pacientes';
    final items = controller.clientItems('ClientsByMonth');
    final newClients = List<double>.filled(12, 0);
    final regularClients = List<double>.filled(12, 0);
    for (final item in items) {
      final index = (((item['Month'] as num?) ?? 0).toInt()) - 1;
      if (index >= 0 && index < 12) {
        newClients[index] = ((item['NewClientsCount'] as num?) ?? 0).toDouble();
        regularClients[index] = ((item['RegularClientsCount'] as num?) ?? 0)
            .toDouble();
      }
    }
    return _card(
      'Tendência de agendamento de pacientes (${DateTime.now().year})',
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(chart, 'Novos', CustomColors.dashBoardGray),
              const SizedBox(width: 14),
              _legend(chart, 'Recorrentes', CustomColors.dashBoardYellow),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Fev',
                          'Mar',
                          'Abr',
                          'Mai',
                          'Jun',
                          'Jul',
                          'Ago',
                          'Set',
                          'Out',
                          'Nov',
                          'Dez',
                        ];
                        final index = value.toInt();
                        return index >= 0 && index < months.length
                            ? Text(
                                months[index],
                                style: const TextStyle(fontSize: 8),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  if (controller.isChartSeriesVisible(chart, 'Novos'))
                    _line(newClients, CustomColors.dashBoardGray),
                  if (controller.isChartSeriesVisible(chart, 'Recorrentes'))
                    _line(regularClients, CustomColors.dashBoardYellow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> values, Color color) => LineChartBarData(
    spots: List.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index]),
    ),
    color: color,
    barWidth: 2,
    isCurved: true,
    dotData: FlDotData(
      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
        radius: 3,
        color: Colors.white,
        strokeWidth: 2,
        strokeColor: color,
      ),
    ),
    belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.10)),
  );

  Widget _stackedChart(
    String title,
    List<Map<String, dynamic>> items,
    List<(String, String, Color)> groups,
  ) {
    final visibleGroups = groups
        .where((group) => controller.isChartSeriesVisible(title, group.$1))
        .toList();
    final maxTotal = items.fold<int>(0, (currentMax, item) {
      final total = visibleGroups.fold<int>(
        0,
        (sum, group) => sum + ((item[group.$2] as num?) ?? 0).toInt(),
      );
      return math.max(currentMax, total);
    });
    return _card(
      title,
      Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 5,
            children: groups
                .map((group) => _legend(title, group.$1, group.$3))
                .toList(),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            _empty()
          else
            ...items.map((item) {
              final values = visibleGroups
                  .map((group) => ((item[group.$2] as num?) ?? 0).toInt())
                  .toList();
              final total = values.fold<int>(0, (sum, value) => sum + value);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 76,
                      child: Text(
                        item['ScopeName']?.toString() ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Container(
                          height: 18,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: CustomColors.borderColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: total == 0 || maxTotal == 0
                              ? null
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    width:
                                        constraints.maxWidth * total / maxTotal,
                                    child: Row(
                                      children: List.generate(
                                        visibleGroups.length,
                                        (index) => values[index] == 0
                                            ? const SizedBox.shrink()
                                            : Expanded(
                                                flex: values[index],
                                                child: Container(
                                                  height: 18,
                                                  color:
                                                      visibleGroups[index].$3,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '$total',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _rankingCard(String title, List<Map<String, dynamic>> items) => _card(
    title,
    items.isEmpty
        ? _empty()
        : Column(
            children: [
              const Row(
                children: [
                  Expanded(child: Text('Nome', style: _tableHeaderStyle)),
                  SizedBox(
                    width: 55,
                    child: Text(
                      'Qtd.',
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text(
                      'Valor',
                      style: _tableHeaderStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const Divider(),
              ...items
                  .take(6)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['Name']?.toString() ?? '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: Text(
                              '${((item['TotalQuantity'] as num?) ?? 0).toInt()}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          SizedBox(
                            width: 92,
                            child: Text(
                              '${((item['TotalAmount'] as num?) ?? 0).toStringAsFixed(2)} Kz',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 10,
                                color: CustomColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
  );

  Widget _emergencyCard() {
    final priorities = [
      ('Emergência', 'Immediate', const Color(0xffE30713)),
      ('Altamente urgente', 'VeryUrgent', const Color(0xffF97316)),
      ('Urgente', 'Urgent', const Color(0xffFED906)),
      ('Menos urgente', 'Standard', const Color(0xff3D8737)),
      ('Não urgente', 'NonUrgent', const Color(0xff22ABE2)),
    ];
    final workflow = [
      ('Triagem', 'TriageCount', Icons.assignment_ind_outlined),
      ('Espera', 'PatientWaitingCount', Icons.schedule_outlined),
      ('Atendimento', 'AttendanceCount', Icons.medical_services_outlined),
      ('Exames', 'ExamsCount', Icons.biotech_outlined),
    ];
    return _card(
      'Monitorização de urgência',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'TEMPO REAL',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                'Total: ${controller.realTimeValue('TotalCount')}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Atendimentos por prioridade',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...priorities.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: CustomColors.backgroundColor,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.$3,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.$1, style: const TextStyle(fontSize: 11)),
                  ),
                  Text(
                    '${controller.priorityCount(item.$2)}',
                    style: TextStyle(
                      color: item.$3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Fluxo de atendimento',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          GridView.count(
            primary: false,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: workflow
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: CustomColors.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$3,
                          color: CustomColors.primaryColor,
                          size: 22,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${controller.realTimeValue(item.$2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CustomColors.borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: CustomColors.textColor,
    ),
  );

  Widget _legend(String chart, String label, Color color) => _LegendItem(
    label,
    color,
    visible: controller.isChartSeriesVisible(chart, label),
    onTap: () => controller.toggleChartSeries(chart, label),
  );

  Widget _empty() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: Text(
        'Sem dados disponíveis para o período.',
        style: TextStyle(color: CustomColors.mutedTextColor),
      ),
    ),
  );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.color, {this.visible = true, this.onTap});

  final String label;
  final Color color;
  final bool visible;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: visible ? 1 : 0.35,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: visible ? color : Colors.transparent,
                border: Border.all(color: color),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                decoration: visible ? null : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

const _tableHeaderStyle = TextStyle(
  fontSize: 9,
  fontWeight: FontWeight.w700,
  color: CustomColors.mutedTextColor,
);
