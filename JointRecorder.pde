import KinectPV2.KJoint;
import KinectPV2.*;
import java.io.FileWriter;

class JointRecorder {

  // kinectSDKのラッパー
  private KinectPV2 kinect;

  // カメラ映像を描画する仮想画面
  public PGraphics output;

  // mp4出力用クラス
  private VideoRecorder videoRecorder;

  // csv出力用クラス
  private CsvWriter csvWriter;

  // 経過フレーム数
  int frame;

  // 経過時間
  int time;

  // コンストラクタ
  public JointRecorder(PApplet papplet, int outputWidth, int outputHeight) {
    // kinectPV2インスタンスの生成
    this.kinect = new KinectPV2(papplet);
    // カラーカメラの映像取得を有効化
    this.kinect.enableColorImg(true);
    // 現実座標でのスケルトンの取得を有効化
    this.kinect.enableSkeleton3DMap(true);
    // カラーカメラ座標でのスケルトンの取得を有効化
    this.kinect.enableSkeletonColorMap(true);
    // KinectPV2の初期化
    this.kinect.init();

    // 動画保存用の画像バッファ生成
    this.output = createGraphics(outputWidth, outputHeight);

    // インスタンス生成
    this.videoRecorder = new VideoRecorder();
    this.csvWriter = new CsvWriter();
  }

  // 録画開始
  public void startRec() throws Exception {
    try{
      String saveDirPath = sketchPath() + "\\" + year()+"-"+month()+"-"+day()+"_"+hour()+"-"+minute()+"-"+second();
      File saveDir = new File(saveDirPath);
      saveDir.mkdir();
      this.frame = 0;
      this.time = 0;
      this.videoRecorder.start(new File(saveDirPath + "\\log.mp4"), this.output.width, this.output.height, 60.0, 2000000);
      this.csvWriter.open(new File(saveDirPath + "\\log.csv"), createCsvTitles());
    }
    catch (Exception e) {
      stopRec();
      throw e;
    }
  }

  // 録画終了
  public void stopRec() {
    this.videoRecorder.stop();
    this.csvWriter.close();
  }

  public boolean isStartRec() {
    return (videoRecorder.isStart() && csvWriter.isOpen());
  }

  // 更新
  public void update() throws Exception {
    // スケルトンの取得
    ArrayList<KSkeleton> skeleton3dArray = this.kinect.getSkeleton3d();
    ArrayList<KSkeleton> skeletonColorArray = this.kinect.getSkeletonColorMap();

    // 動画保存用の画像バッファへの書き込みを開始
    this.output.beginDraw();

    // 背景を初期化
    this.output.background(0, 0, 0);

    // カラーカメラの映像を描画
    this.output.pushMatrix();
    this.output.scale(-1.0f, 1.0);
    this.output.image(this.kinect.getColorImage(), -this.output.width, 0, this.output.width, this.output.height);
    this.output.popMatrix();

    // カラーカメラ座標スケルトンのプレビュー
    for (KSkeleton skeletonColor : skeletonColorArray) {
      if (skeletonColor.isTracked()) {
        KJoint[] jointsColor = skeletonColor.getJoints();
        color col = skeletonColor.getIndexColor();
        this.output.fill(col);
        this.output.noStroke();
        for(KJoint jointColor : jointsColor) {
          this.output.pushMatrix();
          this.output.scale(-1.0f * (float)this.output.width / 1920.0f, (float)this.output.height / 1080.0f);
          this.output.ellipse(jointColor.getX() - 1920.0f, jointColor.getY(), 30, 30);
          this.output.popMatrix();
        }
      }
    }

    // 動画保存用の画像バッファへの書き込みを終了
    this.output.endDraw();

    if (isStartRec()) {
      try {
        // mp4ファイルの更新
        this.time = this.videoRecorder.update(this.output);

        // csvファイルの更新
        this.csvWriter.update(createCsvValues(skeleton3dArray));
      }
      catch (Exception e) {
        stopRec();
        throw e;
      }
    }
  }

  public void draw() {
    // 動画保存用の画像バッファをプレビュー
    image(output, 0, 0, width, height);

    // フレームレートの表示
    textAlign(LEFT, TOP);
    textSize(32);
    fill(0, 0, 0);
    text(frameRate, 21, 21);
    fill(255, 255, 255);
    text(frameRate, 20, 20);

    // 記録中の表示
    if (isStartRec()) {
      textAlign(RIGHT, TOP);
      textSize(32);
      fill(0, 0, 0);
      text("●REC", width - 19, 19);
      fill(255, 0, 0);
      text("●REC", width - 20, 20);
    }
  }

  private String[] createCsvValues(ArrayList<KSkeleton> skeleton3dArray) {
    this.frame += 1;
    String[] row = new String[1 + 1 + 6 * 25 * 3];
    for(int i = 0; i < row.length; i++) row[i] = "null";
    row[0] = Integer.toString(this.frame);
    row[1] = Integer.toString(this.time);
    for (int peopleIndex = 0; peopleIndex < skeleton3dArray.size(); peopleIndex++) {
      KSkeleton skeleton3d = (KSkeleton)skeleton3dArray.get(peopleIndex);
      if (skeleton3d.isTracked()) {
        KJoint[] joints3d = skeleton3d.getJoints();
        for(int jointIndex = 0; jointIndex < joints3d.length; jointIndex++) {
          row[2 + (peopleIndex * joints3d.length + jointIndex) * 3 + 0] =
            Float.toString(joints3d[jointIndex].getX());
          row[2 + (peopleIndex * joints3d.length + jointIndex) * 3 + 1] =
            Float.toString(joints3d[jointIndex].getY());
          row[2 + (peopleIndex * joints3d.length + jointIndex) * 3 + 2] =
            Float.toString(joints3d[jointIndex].getZ());
        }
      }
    }
    return row;
  }

  private String[] createCsvTitles() {
    String[] row = new String[1 + 1 + 6 * 25 * 3];
    int maxPeople = 6;
    String[] skeletonTitles = {
      "SpineBase",
      "SpineMid",
      "Neck",
      "Head",
      "ShoulderLeft",
      "ElbowLeft",
      "WristLeft",
      "HandLeft",
      "ShoulderRight",
      "ElbowRight",
      "WristRight",
      "HandRight",
      "HipLeft",
      "KneeLeft",
      "AnkleLeft",
      "FootLeft",
      "HipRight",
      "KneeRight",
      "AnkleRight",
      "FootRight",
      "SpineShoulder",
      "HandTipLeft",
      "ThumbLeft",
      "HandTipRight",
      "ThumbRight"
    };
    String result = "";
    row[0] = "frame";
    row[1] = "time [ms]";
    for (int peopleIndex = 0; peopleIndex < maxPeople; peopleIndex++) {
      for(int jointIndex = 0; jointIndex < skeletonTitles.length; jointIndex++) {
        row[2 + (peopleIndex * skeletonTitles.length + jointIndex) * 3 + 0]
          = "skeletons[" + peopleIndex + "][" + skeletonTitles[jointIndex] + "].x";
        row[2 + (peopleIndex * skeletonTitles.length + jointIndex) * 3 + 1]
          = "skeletons[" + peopleIndex + "][" + skeletonTitles[jointIndex] + "].y";
        row[2 + (peopleIndex * skeletonTitles.length + jointIndex) * 3 + 2]
          = "skeletons[" + peopleIndex + "][" + skeletonTitles[jointIndex] + "].z";
      }
    }
    return row;
  }

}