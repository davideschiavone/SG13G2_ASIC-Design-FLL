v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {4-bit current-steering DAC - schematic == dac4.spice (IREF ideal ref)} -200 -1000 0 0 0.5 0.5 {}
C {sg13_lv_pmos.sym} 0 -500 0 0 {name=Mpref
l=1u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -470 0 0 {name=l109 lab=vpcs}
C {devices/lab_wire.sym} -20 -500 0 0 {name=l110 lab=vpcs}
C {devices/lab_wire.sym} 20 -530 0 0 {name=l111 lab=VDD}
C {devices/lab_wire.sym} 20 -500 0 0 {name=l112 lab=VDD}
C {devices/isource.sym} 0 -150 0 0 {name=Iref value="2u"}
C {devices/lab_wire.sym} 0 -180 0 0 {name=l113 lab=vpcs}
C {devices/lab_wire.sym} 0 -120 0 0 {name=l114 lab=VSS}
C {sg13_lv_pmos.sym} 350 -900 0 0 {name=Minvp0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -870 0 0 {name=l115 lab=b0b}
C {devices/lab_wire.sym} 330 -900 0 0 {name=l116 lab=b0}
C {devices/lab_wire.sym} 370 -930 0 0 {name=l117 lab=VDD}
C {devices/lab_wire.sym} 370 -900 0 0 {name=l118 lab=VDD}
C {sg13_lv_nmos.sym} 350 -700 0 0 {name=Minvn0
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -730 0 0 {name=l119 lab=b0b}
C {devices/lab_wire.sym} 330 -700 0 0 {name=l120 lab=b0}
C {devices/lab_wire.sym} 370 -670 0 0 {name=l121 lab=VSS}
C {devices/lab_wire.sym} 370 -700 0 0 {name=l122 lab=VSS}
C {sg13_lv_pmos.sym} 350 -350 0 0 {name=Msrc0
l=1u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -320 0 0 {name=l123 lab=cs0}
C {devices/lab_wire.sym} 330 -350 0 0 {name=l124 lab=vpcs}
C {devices/lab_wire.sym} 370 -380 0 0 {name=l125 lab=VDD}
C {devices/lab_wire.sym} 370 -350 0 0 {name=l126 lab=VDD}
C {sg13_lv_nmos.sym} 350 -100 0 0 {name=Mto0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -130 0 0 {name=l127 lab=iout}
C {devices/lab_wire.sym} 330 -100 0 0 {name=l128 lab=b0}
C {devices/lab_wire.sym} 370 -70 0 0 {name=l129 lab=cs0}
C {devices/lab_wire.sym} 370 -100 0 0 {name=l130 lab=VSS}
C {sg13_lv_nmos.sym} 350 150 0 0 {name=Mdo0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 120 0 0 {name=l131 lab=ndump}
C {devices/lab_wire.sym} 330 150 0 0 {name=l132 lab=b0b}
C {devices/lab_wire.sym} 370 180 0 0 {name=l133 lab=cs0}
C {devices/lab_wire.sym} 370 150 0 0 {name=l134 lab=VSS}
C {sg13_lv_pmos.sym} 700 -900 0 0 {name=Minvp1
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 720 -870 0 0 {name=l135 lab=b1b}
C {devices/lab_wire.sym} 680 -900 0 0 {name=l136 lab=b1}
C {devices/lab_wire.sym} 720 -930 0 0 {name=l137 lab=VDD}
C {devices/lab_wire.sym} 720 -900 0 0 {name=l138 lab=VDD}
C {sg13_lv_nmos.sym} 700 -700 0 0 {name=Minvn1
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 720 -730 0 0 {name=l139 lab=b1b}
C {devices/lab_wire.sym} 680 -700 0 0 {name=l140 lab=b1}
C {devices/lab_wire.sym} 720 -670 0 0 {name=l141 lab=VSS}
C {devices/lab_wire.sym} 720 -700 0 0 {name=l142 lab=VSS}
C {sg13_lv_pmos.sym} 700 -350 0 0 {name=Msrc1
l=1u
w=2u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 720 -320 0 0 {name=l143 lab=cs1}
C {devices/lab_wire.sym} 680 -350 0 0 {name=l144 lab=vpcs}
C {devices/lab_wire.sym} 720 -380 0 0 {name=l145 lab=VDD}
C {devices/lab_wire.sym} 720 -350 0 0 {name=l146 lab=VDD}
C {sg13_lv_nmos.sym} 700 -100 0 0 {name=Mto1
l=0.13u
w=1u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 720 -130 0 0 {name=l147 lab=iout}
C {devices/lab_wire.sym} 680 -100 0 0 {name=l148 lab=b1}
C {devices/lab_wire.sym} 720 -70 0 0 {name=l149 lab=cs1}
C {devices/lab_wire.sym} 720 -100 0 0 {name=l150 lab=VSS}
C {sg13_lv_nmos.sym} 700 150 0 0 {name=Mdo1
l=0.13u
w=1u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 720 120 0 0 {name=l151 lab=ndump}
C {devices/lab_wire.sym} 680 150 0 0 {name=l152 lab=b1b}
C {devices/lab_wire.sym} 720 180 0 0 {name=l153 lab=cs1}
C {devices/lab_wire.sym} 720 150 0 0 {name=l154 lab=VSS}
C {sg13_lv_pmos.sym} 1050 -900 0 0 {name=Minvp2
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1070 -870 0 0 {name=l155 lab=b2b}
C {devices/lab_wire.sym} 1030 -900 0 0 {name=l156 lab=b2}
C {devices/lab_wire.sym} 1070 -930 0 0 {name=l157 lab=VDD}
C {devices/lab_wire.sym} 1070 -900 0 0 {name=l158 lab=VDD}
C {sg13_lv_nmos.sym} 1050 -700 0 0 {name=Minvn2
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1070 -730 0 0 {name=l159 lab=b2b}
C {devices/lab_wire.sym} 1030 -700 0 0 {name=l160 lab=b2}
C {devices/lab_wire.sym} 1070 -670 0 0 {name=l161 lab=VSS}
C {devices/lab_wire.sym} 1070 -700 0 0 {name=l162 lab=VSS}
C {sg13_lv_pmos.sym} 1050 -350 0 0 {name=Msrc2
l=1u
w=2u
ng=1
m=4
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1070 -320 0 0 {name=l163 lab=cs2}
C {devices/lab_wire.sym} 1030 -350 0 0 {name=l164 lab=vpcs}
C {devices/lab_wire.sym} 1070 -380 0 0 {name=l165 lab=VDD}
C {devices/lab_wire.sym} 1070 -350 0 0 {name=l166 lab=VDD}
C {sg13_lv_nmos.sym} 1050 -100 0 0 {name=Mto2
l=0.13u
w=1u
ng=1
m=4
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1070 -130 0 0 {name=l167 lab=iout}
C {devices/lab_wire.sym} 1030 -100 0 0 {name=l168 lab=b2}
C {devices/lab_wire.sym} 1070 -70 0 0 {name=l169 lab=cs2}
C {devices/lab_wire.sym} 1070 -100 0 0 {name=l170 lab=VSS}
C {sg13_lv_nmos.sym} 1050 150 0 0 {name=Mdo2
l=0.13u
w=1u
ng=1
m=4
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1070 120 0 0 {name=l171 lab=ndump}
C {devices/lab_wire.sym} 1030 150 0 0 {name=l172 lab=b2b}
C {devices/lab_wire.sym} 1070 180 0 0 {name=l173 lab=cs2}
C {devices/lab_wire.sym} 1070 150 0 0 {name=l174 lab=VSS}
C {sg13_lv_pmos.sym} 1400 -900 0 0 {name=Minvp3
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1420 -870 0 0 {name=l175 lab=b3b}
C {devices/lab_wire.sym} 1380 -900 0 0 {name=l176 lab=b3}
C {devices/lab_wire.sym} 1420 -930 0 0 {name=l177 lab=VDD}
C {devices/lab_wire.sym} 1420 -900 0 0 {name=l178 lab=VDD}
C {sg13_lv_nmos.sym} 1400 -700 0 0 {name=Minvn3
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1420 -730 0 0 {name=l179 lab=b3b}
C {devices/lab_wire.sym} 1380 -700 0 0 {name=l180 lab=b3}
C {devices/lab_wire.sym} 1420 -670 0 0 {name=l181 lab=VSS}
C {devices/lab_wire.sym} 1420 -700 0 0 {name=l182 lab=VSS}
C {sg13_lv_pmos.sym} 1400 -350 0 0 {name=Msrc3
l=1u
w=2u
ng=1
m=8
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1420 -320 0 0 {name=l183 lab=cs3}
C {devices/lab_wire.sym} 1380 -350 0 0 {name=l184 lab=vpcs}
C {devices/lab_wire.sym} 1420 -380 0 0 {name=l185 lab=VDD}
C {devices/lab_wire.sym} 1420 -350 0 0 {name=l186 lab=VDD}
C {sg13_lv_nmos.sym} 1400 -100 0 0 {name=Mto3
l=0.13u
w=1u
ng=1
m=8
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1420 -130 0 0 {name=l187 lab=iout}
C {devices/lab_wire.sym} 1380 -100 0 0 {name=l188 lab=b3}
C {devices/lab_wire.sym} 1420 -70 0 0 {name=l189 lab=cs3}
C {devices/lab_wire.sym} 1420 -100 0 0 {name=l190 lab=VSS}
C {sg13_lv_nmos.sym} 1400 150 0 0 {name=Mdo3
l=0.13u
w=1u
ng=1
m=8
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1420 120 0 0 {name=l191 lab=ndump}
C {devices/lab_wire.sym} 1380 150 0 0 {name=l192 lab=b3b}
C {devices/lab_wire.sym} 1420 180 0 0 {name=l193 lab=cs3}
C {devices/lab_wire.sym} 1420 150 0 0 {name=l194 lab=VSS}
C {sg13_lv_nmos.sym} 1750 150 0 0 {name=Mdump
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1770 120 0 0 {name=l195 lab=ndump}
C {devices/lab_wire.sym} 1730 150 0 0 {name=l196 lab=ndump}
C {devices/lab_wire.sym} 1770 180 0 0 {name=l197 lab=VSS}
C {devices/lab_wire.sym} 1770 150 0 0 {name=l198 lab=VSS}
C {devices/iopin.sym} -200 -700 0 0 {name=P5 lab=VDD}
C {devices/iopin.sym} -200 350 0 0 {name=P6 lab=VSS}
C {devices/ipin.sym} 290 -900 0 0 {name=P7 lab=b0}
C {devices/ipin.sym} 640 -900 0 0 {name=P8 lab=b1}
C {devices/ipin.sym} 990 -900 0 0 {name=P9 lab=b2}
C {devices/ipin.sym} 1340 -900 0 0 {name=P10 lab=b3}
C {devices/iopin.sym} 1950 -100 0 0 {name=P11 lab=iout}
