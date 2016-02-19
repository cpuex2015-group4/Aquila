# Aquila
## IO ループバックで動作確認済み。b-rate 100000 では350kBのファイルは送れたが600kBのファイルはダメだった



# メモ
ここ以降は仕様やスペックの話ではなく、実装に当たる上でのメモ書きです
### main.vhd
パイプラインはF,D,Ex,WBの４ステージに切られている。
各ステージの名がついた変数は、各ステージでの処理の結果を保存する。
すなわち
(stage F)->[latch F] -> (stage D) ->[latch D]->...
といったデータの流れである。
外部出力は一旦outputラッチに受ける方針であったが、撤回された。
ある場所のforwardingを間に合わせるためである。

process内で、
計算は後のステージから順番に行う。命令実行の時系列を少しでも非パイプライン時のそれに近づけるためである。


#### F
次のPCを計算し、命令メモリに放り込む。
stage D の結果をがっつり使うことに注意。

#### D
命令を受け取りデコードする。分岐の時は直ちに次期アドレスをＦに送る。

#### Ex
ALU,FPU,IO,Memなどへの出力を行う。
IOへのwriteとFPU演算が構造ハザードを起こす。

#### Wb
IO,Mem,Exから適切なデータソースを選び、必要ならばレジスタに書き戻す。
IO,Memが構造ハザードを起こす。