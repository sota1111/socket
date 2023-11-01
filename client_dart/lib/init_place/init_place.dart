import 'package:flutter/material.dart';
import 'config.dart';

class InitPlaceScreen extends StatefulWidget {
  const InitPlaceScreen({super.key});

  @override
  InitPlaceScreenState createState() => InitPlaceScreenState();
}

class InitPlaceScreenState extends State<InitPlaceScreen> {
  Offset? point;
  late Offset coordinateXY;
  String currentFloorImage = floorData['1F']!['path']!;
  double originalImageHeight = floorData['1F']!['height']!;
  double originalImageWidth = floorData['1F']!['width']!;
  final TransformationController transformationController = TransformationController();
  static const double minScale = 0.5;
  static const double maxScale = 3.0;

  void resetPinPoint() {
    setState(() {
      point = null;
    });
  }

  void onPinTapped(TapDownDetails details) {
    setState(() {
      point = transformationController.toScene(
        Offset(details.localPosition.dx, details.localPosition.dy),
      );
      point = _adjustPinIconSize(point!);
      printDebugInfo(details);
    });
  }

  Offset _adjustPinIconSize(Offset point) {
    final correctedOffset = Offset(
      point.dx - 12.0 / transformationController.value.getMaxScaleOnAxis(),
      point.dy - (24.0 - 4) / transformationController.value.getMaxScaleOnAxis(),
    );
    return correctedOffset;
  }

  void printDebugInfo(TapDownDetails details) {
    debugPrint("\npoint:$point");
    debugPrint("Local Position: ${details.localPosition}"); //画像の座標
    debugPrint("Global Position: ${details.globalPosition}");
    debugPrint("Max Scale: ${transformationController.value.getMaxScaleOnAxis()}");
    final size = MediaQuery.of(context).size;
    debugPrint("Screen Width: ${size.width}");
    debugPrint("Screen Height: ${size.height}");
    coordinateXY = details.localPosition;

    if ((originalImageHeight > size.height) || (originalImageWidth > size.width)){
      double heightRatio = size.height / originalImageHeight;
      debugPrint("Height Ratio: $heightRatio");
      double widthRatio = size.width / originalImageWidth;
      debugPrint("Width Ratio: $widthRatio");
      if(heightRatio<widthRatio){
        coordinateXY = details.localPosition/heightRatio;
      }else{
        coordinateXY = details.localPosition/widthRatio;
      }
    }
    debugPrint("coordinateXY: $coordinateXY");
  }


  void changeFloor(String floor) {
    setState(() {
      var floorInfo = floorData[floor];
      if (floorInfo != null) {
        currentFloorImage = floorInfo['path']!;
        originalImageHeight = floorInfo['height']!;
        originalImageWidth = floorInfo['width']!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: originalImageWidth / originalImageHeight,
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: minScale,
                    maxScale: maxScale,
                    onInteractionUpdate: (_) => resetPinPoint(),
                    transformationController: transformationController,
                    child: Stack(
                      children: [
                        _buildImageView(),
                        GestureDetector(
                          onTapDown: onPinTapped,
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            height: double.infinity,
                            child: _buildPinLayer(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 16,
          top: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);  // これで一つ前の画面に戻ります。
            },
            child: const Icon(Icons.arrow_back),  // 戻るアイコン
          ),
        ),
        _buildResetButton(),
        _buildConfirmButton(),
        _buildFloorSwitchButton('B1F', 16, 80),
        _buildFloorSwitchButton('1F', 16, 140),
        _buildFloorSwitchButton('2F', 16, 200),
        _buildFloorSwitchButton('3F', 16, 260),
        _buildFloorSwitchButton('4F', 16, 320),
        _buildFloorSwitchButton('5F', 16, 380),
        _buildFloorSwitchButton('6F', 16, 440),
      ],
    );
  }



  Widget _buildImageView() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black45,
          width: 1.0,
        ),
      ),
      width: originalImageWidth,
      height: originalImageHeight,
      child: Image.asset(
        currentFloorImage,
        fit: BoxFit.contain,
      ),
    );
  }



  Widget _buildPinLayer() {
    return Stack(
      children: [
        if (point != null)
          Positioned(
            left: (transformationController.value.getTranslation().x + point!.dx * transformationController.value.getMaxScaleOnAxis()),
            top: (transformationController.value.getTranslation().y + point!.dy * transformationController.value.getMaxScaleOnAxis()),
            child: const Icon(Icons.pin_drop, color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildResetButton() {
    return Positioned(
      right: 16,
      bottom: 60,
      child: ElevatedButton(
        onPressed: () {
          transformationController.value = Matrix4.identity();
          resetPinPoint();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade900,
          minimumSize: const Size(85, 50),
        ),
        child: const Text('縮尺\n初期化'),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: ElevatedButton(
        onPressed: () {
          // Right bottom button pressed
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange.shade900,
          minimumSize: const Size(85, 50),
        ),
        child: const Text(
          '座標\n決定',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  Widget _buildFloorSwitchButton(String floor, double left, double bottom) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: ElevatedButton(
        onPressed: (){
          changeFloor(floor);
          transformationController.value = Matrix4.identity();
          resetPinPoint();
        },
        child: Text(floor),
      ),
    );
  }
}
