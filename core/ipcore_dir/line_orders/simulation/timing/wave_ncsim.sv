
 
 
 




window new WaveWindow  -name  "Waves for BMG Example Design"
waveform  using  "Waves for BMG Example Design"


      waveform add -signals /line_orders_tb/status
      waveform add -signals /line_orders_tb/line_orders_synth_inst/bmg_port/CLKA
      waveform add -signals /line_orders_tb/line_orders_synth_inst/bmg_port/ADDRA
      waveform add -signals /line_orders_tb/line_orders_synth_inst/bmg_port/DINA
      waveform add -signals /line_orders_tb/line_orders_synth_inst/bmg_port/WEA
      waveform add -signals /line_orders_tb/line_orders_synth_inst/bmg_port/DOUTA
console submit -using simulator -wait no "run"
