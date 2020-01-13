class CsvWriter {

  // csv書き込み用
  private FileWriter writer = null;

  // csvファイルがopenされた状態かどうが
  private boolean isOpen_ = false;

  // 記録開始
  public void open(File outputFile, String[] rowTitles) throws IOException {
    if (this.isOpen_) return;

    // 1行目の列タイトルの生成
    String rowTitlesText = "";
    for (String rowTitle : rowTitles) {
      rowTitlesText += rowTitle + ", ";
    }
    rowTitlesText = rowTitlesText.substring(0, rowTitlesText.length() - 2);

    // csv作成
    outputFile.createNewFile();
    if (outputFile.exists() && outputFile.isFile() && outputFile.canWrite()){
      this.writer = new FileWriter(outputFile, true);
      this.writer.write(rowTitlesText);
    }

    // 変数の初期化
    this.isOpen_ = true;
  }

  // 記録更新
  public void update(String[] rowValues) throws IOException {
    if (!this.isOpen_) return;

    // 値をcsvの文字列に変換
    String rowValuesText = "";
    for (String rowValue : rowValues) {
      rowValuesText += rowValue + ", ";
    }
    rowValuesText = rowValuesText.substring(0, rowValuesText.length() - 2);

    // csvに値を追記
    try {
      if (this.writer != null) this.writer.write("\n" + rowValuesText);
    }
    catch (IOException e) {
      close();
      throw e;
    }
  }

  // 記録終了
  public void close() {
    if (!this.isOpen_) return;
    this.isOpen_ = false;
    try {
      if (this.writer != null) this.writer.close();
    }
    catch (IOException e) {
      println(e);
    }
  }

  // csvファイルが開かれているかどうかの取得
  public boolean isOpen() { return this.isOpen_; };
}