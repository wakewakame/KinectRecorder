import org.bytedeco.javacv.*;

// mp4ファイル出力クラス
class VideoRecorder {
  // FFmpegのJavaラッパー
  private FFmpegFrameRecorder recorder;

  // 動画に追記するフレーム
  private Frame frame;

  // 録画開始からの経過時間(マイクロ秒)
  private long startTime;

  // 録画が開始されているかどうか
  private boolean isStart_;

  // 録画ファイルのフレームレート
  private double fps;

  // 録画ファイルのビットレート
  private int bitrate;

  int w, h;
  
  // コンストラクタ
  public VideoRecorder() {
    // 初期化
    this.reset();
  }
  
  // 録画開始
  public void start(File outputFile, int width, int height, double fps, int bitrate) {
    if (this.isStart()) return;
    this.reset();
    this.recorder = new FFmpegFrameRecorder(outputFile, width, height);
    this.fps = fps;
    this.bitrate = bitrate;
    this.isStart_ = true;
    this.w = width; this.h = height;
  }
  
  private void firstUpdate() throws FrameRecorder.Exception {
    this.recorder.setFormat("mp4");
    this.recorder.setVideoCodecName("h264");
    this.recorder.setFrameRate(this.fps);
    this.recorder.setVideoBitrate(this.bitrate);
    this.recorder.setTimestamp(0);
    this.recorder.start();
    this.frame = new Frame(this.w, this.h, Frame.DEPTH_UBYTE, 3);
    if (
      this.frame == null ||
      this.frame.image == null ||
      this.frame.image.length != 1 ||
      (!(this.frame.image[0] instanceof java.nio.ByteBuffer)) ||
      (!this.frame.image[0].isDirect()) ||
      this.frame.image[0].isReadOnly()
    ) {
      throw new FrameRecorder.Exception("unexpected error");
    }
    this.startTime = millis();
  }
  
  // フレームの追加
  public int update(PGraphics output) throws FrameRecorder.Exception {
    try {
      if (!this.isStart()) return 0;
      if(this.frame == null) {
        this.firstUpdate();
      }
      this.frame.image[0].clear();
      output.loadPixels();
      java.nio.ByteBuffer bb = (java.nio.ByteBuffer)this.frame.image[0];
      for(int i = 0; i < output.width * output.height; i++) {
        color c = output.pixels[i];
        bb.put((byte)(c       & 0xFF));
        bb.put((byte)(c >>  8 & 0xFF));
        bb.put((byte)(c >> 16 & 0xFF));
      }
      this.frame.timestamp = this.getRecordingTime();
      if (this.recorder.getTimestamp() < this.frame.timestamp) {
        this.recorder.setTimestamp(this.frame.timestamp);
      }
      this.recorder.record(this.frame);
      return (int)(this.frame.timestamp / 1000);
    }
    catch(FrameRecorder.Exception e) {
      this.stop();
      throw e;
    }
  }
  
  // 録画の終了
  public void stop() {
    if (!this.isStart()) return;
    try {
      this.recorder.stop();
    }
    catch(FrameRecorder.Exception e) {
      println(e);
    }
    finally {
      this.reset();
    }
  }
  
  // 録画が開始されているかの判定
  public boolean isStart() {
    return this.isStart_;
  }
  
  // 録画が開始されてからの経過時間(マイクロ秒)
  private long getRecordingTime() {
    return (millis() - this.startTime) * 1000;
  }
  
  // 状態の初期化
  public void reset() {
    this.recorder = null;
    this.frame = null;
    this.startTime = 0;
    this.isStart_ = false;
  }
}