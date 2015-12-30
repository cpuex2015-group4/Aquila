

 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"

      waveform add -signals /finv_table_tb/status
      waveform add -signals /finv_table_tb/finv_table_synth_inst/bmg_port/CLKA
      waveform add -signals /finv_table_tb/finv_table_synth_inst/bmg_port/ADDRA
      waveform add -signals /finv_table_tb/finv_table_synth_inst/bmg_port/DOUTA

console submit -using simulator -wait no "run"
