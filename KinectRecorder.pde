// --------------------------------------------------

// プログラム各種設定定数

  // ウィンドウサイズ
  final int windowWidth = 640;
  final int windowHeight = 360;

  // 映像の録画解像度
  final int outputWidth = 640;
  final int outputHeight = 360;

// --------------------------------------------------

JointRecorder jointRecorder;

// エラーメッセージ
String error = "";

void settings() {
  // ウィンドウサイズの指定
  size(windowWidth, windowHeight);
}

void setup() {
  jointRecorder = new JointRecorder(this, outputWidth, outputHeight);
}

void draw() {
  if (error.equals("")) {
    try {
      jointRecorder.update();
      jointRecorder.draw();
      error = "";
    }
    catch (Exception e) {
      error = e.toString();
    }
  }

  // エラーメッセージの表示
  textAlign(CENTER, CENTER);
  textSize(12);
  fill(0, 0, 0);
  text(error, width / 2 + 1, height / 2 + 1);
  fill(255, 0, 0);
  text(error, width / 2, height / 2);
}

void dispose() {
  // 終了処理
  jointRecorder.stopRec();
}

void keyPressed() {
  if (key == ENTER) {
    if (jointRecorder.isStartRec()) jointRecorder.stopRec();
    else {
      try {
        jointRecorder.startRec();
        error = "";
      }
      catch (Exception e) {
        error = e.toString();
      }
    }
  }
}