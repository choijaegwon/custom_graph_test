import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<MetaData> metaData = [
    MetaData(duration: 0, time: 12, level: 2, rpm: 16, description: ""),
    MetaData(duration: 12, time: 23, level: 6, rpm: 30, description: ""),
    MetaData(duration: 35, time: 5, level: 12, rpm: 6, description: ""),
    MetaData(duration: 40, time: 10, level: 11, rpm: 15, description: "")
  ];
  late List<CustomMetaData> dataList;

  @override
  void initState() {
    super.initState();
    dataList = metaData.map((data) {
      return CustomMetaData(
        duration: data.duration,
        time: data.time.toDouble(),
        y: data.rpm.toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DetailGraph(
        width: 100,
        height: 94,
        colorList: [
          Color.fromRGBO(27, 185, 208, 1),
          Color.fromRGBO(108, 216, 183, 0.3),
        ],
        metaData: dataList,
      ),
    );
  }
}

class DetailGraph extends StatelessWidget {
  /// 넓이
  double width;

  /// 높이
  double height;

  /// 색 리스트
  List<Color> colorList;

  /// 메타 데이터
  List<CustomMetaData> metaData;

  DetailGraph({
    required this.width,
    required this.height,
    required this.colorList,
    required this.metaData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.transparent,
          width: width,
          height: height,
          child: CustomPaint(
            painter: GraphPainter(
              metaData: metaData,
              colorList: colorList,
              width: width,
              height: height,
            ),
          ),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  List<CustomMetaData> metaData;
  late Paint linePaint;
  List<Color> colorList;

  /// 넓이
  double width;

  /// 높이
  double height;

  /// 최고 Rpm
  double _maxY = -1000;

  /// 넓이 비율
  double _widthRatio = 1;

  /// 높이 비율
  double _heightRatio = 1;

  /// 그래프의 높이
  double graphHeight = 100;

  /// 그래프의 넓이
  double graphWidth = 100;

  // 마지막 그래프
  double _lastHegiht = 0;

  /// 초기세팅
  void init(Size size) {
    getMaxY();
    getRatio(size);
    getSize(size);
  }

  /// 최소 최대 높이 구하기
  void getMaxY() {
    for (var data in metaData) {
      if (data.y > _maxY) {
        _maxY = data.y.toDouble();
      }
    }
  }

  /// 비율 구하기
  void getRatio(Size size) {
    _widthRatio = (size.width / (metaData.last.duration + metaData.last.time));
    _heightRatio = (size.height / (_maxY));
  }

  /// 그래프의 높이와 넓이
  void getSize(Size size) {
    /// 그래프의 높이
    graphHeight = size.height;

    /// 그래프의 넓이
    graphWidth = size.width;
  }

  /// 마지막 높이 넣기
  void setLastHegiht(double y) {
    _lastHegiht = y;
  }

  /// 데이터있는곳마다 포인트 찍어주기
  void getDataPoints(Path graphPath) {
    for (int i = 0; i < metaData.length; i++) {
      double x = metaData[i].duration * _widthRatio; //  duration
      double y = graphHeight - metaData[i].y.toDouble() * _heightRatio; // rpm
      if (i != 0) {
        graphPath.lineTo(
            x, graphHeight - metaData[i - 1].y.toDouble() * _heightRatio);
      }
      graphPath.lineTo(x, y);
      setLastHegiht(y);
    }
  }

  GraphPainter({
    required this.metaData,
    required this.colorList,
    required this.width,
    required this.height,
  }) {
    linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    init(Size(width, height));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 색상
    final gradient = LinearGradient(
      colors: colorList,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    Path graphPath = drawPath(canvas); // 그려주는 함수

    // 그래프 후 밑에 색칠하는 로직 시작
    final gradientPath = Path.from(graphPath)
      ..lineTo(0, graphHeight)
      ..close();

    final gradientPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);
  }

  /// 다각형으로 그려주기
  Path drawPath(Canvas canvas) {
    Path graphPath = Path();
    graphPath.moveTo(0, graphHeight);
    getDataPoints(graphPath);
    graphPath.lineTo(graphWidth, _lastHegiht); // 마지막 높이 이어주는 점
    graphPath.lineTo(graphWidth, graphHeight); // 마지막 높이에서 아래로 내려주는 점
    canvas.drawPath(graphPath, linePaint); // 그려주는 함수
    return graphPath;
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return true;
  }
}

class MetaData {
  double duration;
  int time;
  int level;
  int rpm;
  String description;

  MetaData({
    required this.duration,
    required this.time,
    required this.level,
    required this.rpm,
    required this.description,
  });
}

class CustomMetaData {
  double duration;
  double time;
  double y;

  CustomMetaData({
    required this.duration,
    required this.time,
    required this.y,
  });
}
