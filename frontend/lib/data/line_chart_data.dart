import 'package:fl_chart/fl_chart.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';

class LineData {
  final ApiServices apiService = ApiServices();

  List<FlSpot> spots = [];
  final leftTitle = {
    0: '0',
    20000: '20K',
    40000: '40K',
    60000: '60K',
    80000: '80K',
    100000: '100K',
    120000: '120K'
  };
  final bottomTitle = {
    0: 'Jan',
    1: 'Feb',
    2: 'Mar',
    3: 'Apr',
    4: 'May',
    5: 'Jun',
    6: 'Jul',
    7: 'Aug',
    8: 'Sep',
    9: 'Oct',
    10: 'Nov',
    11: 'Dec',
  };

  Future<void> fetchData() async {
    spots = await apiService.fetchMonthlySales();
  }
}
