import 'package:flutter/material.dart';

// ContentDetailGraph(
//   width: 384,
//   height: 90,
//   lineColor: Color.fromRGBO(15, 205, 176, 1),
//   colorList: [
//     Color.fromRGBO(27, 185, 208, 1),
//     Color.fromRGBO(108, 216, 183, 0.3),
//   ],
//   metaData: rpmDataList,
//   maxY: maxRpmY,
//   minY: minRpmY,
// )

class ContentDetailGraph extends StatelessWidget {
  /// 넓이
  double width;

  /// 높이
  double height;

  /// 라인 컬러
  Color lineColor;

  /// 색 리스트
  List<Color> colorList;

  /// 메타 데이터
  List<CustomMetaData> metaData;

  /// 최고높이
  double maxY;

  /// 최저높이
  double minY;

  ContentDetailGraph({
    required this.width,
    required this.height,
    required this.lineColor,
    required this.colorList,
    required this.metaData,
    required this.maxY,
    required this.minY,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: GraphPainter(
          metaData: metaData,
          lineColor: lineColor,
          colorList: colorList,
          containerWidth: width,
          containerHegiht: height,
          maxY: maxY,
          minY: minY,
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  List<CustomMetaData> metaData;
  late Paint linePaint;
  List<Color> colorList;
  Color lineColor;

  /// 넓이
  double containerWidth;

  /// 높이
  double containerHegiht;

  /// 최고 Rpm
  double maxY;
  double minY;

  /// 넓이 비율
  double _widthRatio = 1;

  /// 높이 비율
  double _heightRatio = 1;

  /// 그래프의 높이
  double graphHeight = 100;

  /// 그래프의 넓이
  double graphWidth = 100;

  /// 마지막 높이
  double _lastHegiht = 0;

  GraphPainter({
    required this.metaData,
    required this.lineColor,
    required this.colorList,
    required this.containerWidth,
    required this.containerHegiht,
    required this.maxY,
    required this.minY,
  }) {
    linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    init(Size(containerWidth, containerHegiht));
  }

  /// 초기세팅
  void init(Size size) {
    getSize(size);
    getRatio(size);
  }

  /// 그래프의 높이와 넓이 -> 컨테이너의 사이즈
  void getSize(Size size) {
    /// 그래프의 높이
    graphHeight = (size.height);

    /// 그래프의 넓이
    graphWidth = size.width;
  }

  /// 비율 구하기
  void getRatio(Size size) {
    _widthRatio = (size.width / (metaData.last.duration + metaData.last.time));
    _heightRatio = ((size.height - 5) / (maxY - minY)); // 5는 아래 높이
  }

  /// 마지막 높이 넣기
  void setLastHegiht(double y) {
    _lastHegiht = y;
  }

  /// 데이터있는곳마다 포인트 찍어주기
  void getDataPoints(Path graphPath) {
    for (int i = 0; i < metaData.length; i++) {
      double x = metaData[i].duration * _widthRatio; //  duration
      double y = graphHeight -
          ((metaData[i].y.toDouble()) - minY) * _heightRatio -
          5; // rpm

      if (i == 0) {
        graphPath.moveTo(0, y);
      } else {
        graphPath.lineTo(
            x,
            graphHeight -
                ((metaData[i - 1].y.toDouble()) - minY) * _heightRatio -
                5);
      }

      graphPath.lineTo(x, y);
      setLastHegiht(y);
    }
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
