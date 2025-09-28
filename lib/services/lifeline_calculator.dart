import 'dart:isolate';
import 'dart:ui' as ui;
import 'dart:math';

// --- Модели данных для общения между Isolate и основным потоком ---

/// Входные данные для вычислений в изоляте.
class CalculationInput {
  final SendPort sendPort;
  final ui.Size size;
  final double geometrySpeed;
  final double geometryAmplitude;
  final double timeValue;
  final double branchDensity;
  final double branchAnimationValue;

  CalculationInput({
    required this.sendPort,
    required this.size,
    required this.geometrySpeed,
    required this.geometryAmplitude,
    required this.timeValue,
    required this.branchDensity,
    required this.branchAnimationValue,
  });
}

/// Результат вычислений, возвращаемый из изолята.
class CalculationOutput {
  final List<double> mainPathPoints;
  final List<double> yearPathPoints;
  final List<List<double>> branchPoints;
  final List<List<double>> rootPoints;

  CalculationOutput({
    required this.mainPathPoints,
    required this.yearPathPoints,
    required this.branchPoints,
    required this.rootPoints,
  });
}


/// Основная точка входа для нового изолята.
void lifelineIsolateEntry(CalculationInput input) {
  final size = input.size;
  const margin = 80.0;

  List<double> generateOrganicPath({bool isMain = true, bool isYear = false}) {
    final points = <double>[];
    final random = Random(isMain ? 1 : (isYear ? 3 : 2));
    
    final effectiveWidth = size.width - (margin * 2);
    final midY = size.height / 2;
    
    final segments = (size.width / 50).clamp(48, 500).round();
    const startX = margin;
    
    double noise(double x, double y) => (sin(x * 12.9898 + y * 78.233) * 43758.5453) % 1.0;
    
    double getYAtX(double x, Random random) {
      final t = (x - startX) / effectiveWidth.clamp(1.0, double.infinity);
      final geometryFactor = sin(t * pi * input.geometrySpeed + input.timeValue * pi * 2) * input.geometryAmplitude;
      
      const waveDensity1 = 2 * pi / 800;
      const waveDensity2 = 6 * pi / 800;

      final wave1 = sin(x * waveDensity1) * (20 + random.nextDouble() * 10);
      final wave2 = sin(x * waveDensity2) * (10 + random.nextDouble() * 5);
      final noise1 = (noise(t * 8, 0.5) - 0.5) * 30;
      final offset = isYear ? 90.0 : 0.0;
      return midY + geometryFactor + wave1 + wave2 + noise1 + offset;
    }

    final pathPoints = <ui.Offset>[];
    for (int i = 0; i <= segments; i++) {
        final t = i / segments;
        final x = startX + (t * effectiveWidth);
        final y = getYAtX(x, random);
        pathPoints.add(ui.Offset(x, y));
    }

    if (pathPoints.isEmpty) return [];

    points.addAll([pathPoints[0].dx, pathPoints[0].dy]);
    for (int i = 0; i < pathPoints.length - 1; i++) {
        final p0 = i > 0 ? pathPoints[i - 1] : pathPoints[i];
        final p1 = pathPoints[i];
        final p2 = pathPoints[i + 1];
        final p3 = (i + 2 < pathPoints.length) ? pathPoints[i + 2] : p2;

        const tension = 1.0;
        final cp1x = p1.dx + (p2.dx - p0.dx) / 6 * tension;
        final cp1y = p1.dy + (p2.dy - p0.dy) / 6 * tension;
        final cp2x = p2.dx - (p3.dx - p1.dx) / 6 * tension;
        final cp2y = p2.dy - (p3.dy - p1.dy) / 6 * tension;

        points.addAll([cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy]);
    }

    return points;
  }
  
  List<List<double>> generateBranches(List<double> mainPathPoints) {
    if (mainPathPoints.length < 4) return [];
    
    final allBranchesPoints = <List<double>>[];
    final random = Random(123);
  
    // Функция для получения точки на основном пути по T-параметру (0.0 - 1.0)
    ui.Offset getPointOnMainPath(double t) {
      // Количество сегментов в основном пути
      final totalSegments = (mainPathPoints.length - 2) ~/ 6;
      if (totalSegments <= 0) return ui.Offset(mainPathPoints[0], mainPathPoints[1]);
      
      // Находим нужный сегмент
      final segmentFloat = t * totalSegments;
      final segmentIndex = segmentFloat.floor().clamp(0, totalSegments - 1);
      
      // Базовый индекс точки в массиве
      final pointIndex = segmentIndex * 6 + 2; // +2 чтобы получить конечную точку сегмента
      
      if (pointIndex + 1 >= mainPathPoints.length) {
        // Возвращаем последнюю точку
        return ui.Offset(mainPathPoints[mainPathPoints.length - 2], mainPathPoints[mainPathPoints.length - 1]);
      }
      
      return ui.Offset(mainPathPoints[pointIndex], mainPathPoints[pointIndex + 1]);
    }
  
    // Функция для получения направления касательной в точке пути
    ui.Offset getTangentAtT(double t) {
      const delta = 0.01;
      final point1 = getPointOnMainPath((t - delta).clamp(0.0, 1.0));
      final point2 = getPointOnMainPath((t + delta).clamp(0.0, 1.0));
      
      final direction = point2 - point1;
      final length = direction.distance;
      if (length == 0) return const ui.Offset(1, 0);
      
      return direction / length;
    }
  
    final branchCount = (10 + 20 * input.branchDensity).floor();
  
    for (int i = 0; i < branchCount; i++) {
      final branchPoints = <double>[];
      
      // Выбираем случайную точку на основном пути (избегаем краев)
      final startT = 0.15 + random.nextDouble() * 0.7;
      final startPoint = getPointOnMainPath(startT);
      final tangent = getTangentAtT(startT);
      
      // Стартуем ветку из точки на основном пути
      branchPoints.addAll([startPoint.dx, startPoint.dy]);
  
      final length = (80 + random.nextDouble() * 120) * (0.5 + input.branchDensity);
      
      // Новая логика для угла
      final tangentAngle = tangent.direction;
      final side = random.nextBool() ? 1.0 : -1.0;
      // Случайное отклонение от касательной в диапазоне от 30 до 120 градусов
      final deviation = (pi / 6) + random.nextDouble() * (pi / 2);
      // Итоговый угол ветки
      final branchAngle = tangentAngle + deviation * side;
      final branchDirection = ui.Offset(cos(branchAngle), sin(branchAngle));
  
      const segments = 8;
  
      for (int j = 1; j <= segments; j++) {
        final t = j / segments;
        final dist = t * length;
        
        // Основная точка ветки
        final basePoint = startPoint + branchDirection * dist;
        
        // Добавляем "живое" искривление
        final curveFactor = sin(t * pi * 2 + input.branchAnimationValue * pi * 2) * 10 * t;
        final curveDirection = ui.Offset(-branchDirection.dy, branchDirection.dx);
        
        final finalPoint = basePoint + curveDirection * curveFactor;
        
        branchPoints.addAll([finalPoint.dx, finalPoint.dy]);
      }
      allBranchesPoints.add(branchPoints);
    }
    return allBranchesPoints;
  }

  List<List<double>> generateRoots(ui.Offset convergencePoint) {
    final allRootsPoints = <List<double>>[];
    final random = Random(42);
    const rootCount = 7;
    const maxStartYOffset = 200.0;
    const startXPosition = -150.0; 

    for (int i = 0; i < rootCount; i++) {
      final rootPoints = <double>[];
      final startY = convergencePoint.dy + (random.nextDouble() - 0.5) * maxStartYOffset;
      final startPoint = ui.Offset(startXPosition, startY);
      
      final cp1 = ui.Offset(
        startXPosition + (convergencePoint.dx - startXPosition) * 0.3 * (0.8 + random.nextDouble() * 0.4),
        startY + (random.nextDouble() - 0.5) * 150
      );
      final cp2 = ui.Offset(
        startXPosition + (convergencePoint.dx - startXPosition) * 0.7 * (0.8 + random.nextDouble() * 0.4),
        convergencePoint.dy + (random.nextDouble() - 0.5) * 100
      );

      rootPoints.addAll([startPoint.dx, startPoint.dy, cp1.dx, cp1.dy, cp2.dx, cp2.dy, convergencePoint.dx, convergencePoint.dy]);
      allRootsPoints.add(rootPoints);
    }
    return allRootsPoints;
  }


  final mainPathPoints = generateOrganicPath(isMain: true);
  final yearPathPoints = generateOrganicPath(isYear: true);
  final branchPoints = generateBranches(mainPathPoints);

  final convergencePoint = ui.Offset(mainPathPoints[0], mainPathPoints[1]);
  final rootPoints = generateRoots(convergencePoint);


  final result = CalculationOutput(
    mainPathPoints: mainPathPoints,
    yearPathPoints: yearPathPoints,
    branchPoints: branchPoints,
    rootPoints: rootPoints,
  );
  
  input.sendPort.send(result);
}


