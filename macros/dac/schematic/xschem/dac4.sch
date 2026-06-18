v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {4-bit current-steering DAC == dac4.spice  [VDD/VSS/vpcs labeled rails]} -300 -200 0 0 0.4 0.4 {}
C {sg13_lv_pmos.sym} -260 0 0 0 {name=Mpref
l=1u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} -240 0 0 0 {name=l78 lab=VDD}
C {devices/lab_wire.sym} -240 -30 0 0 {name=l79 lab=VDD}
C {devices/lab_wire.sym} -280 0 0 0 {name=l80 lab=vpcs}
C {devices/lab_wire.sym} -240 30 0 0 {name=l81 lab=vpcs}
C {devices/isource.sym} -260 160 0 0 {name=Iref value="2u"}
C {devices/lab_wire.sym} -260 130 0 0 {name=l82 lab=vpcs}
C {devices/lab_wire.sym} -260 190 0 0 {name=l83 lab=VSS}
C {sg13_lv_pmos.sym} 0 -120 0 0 {name=Minvp0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -120 0 0 {name=l84 lab=VDD}
C {sg13_lv_nmos.sym} 0 -60 0 0 {name=Minvn0
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -60 0 0 {name=l85 lab=VSS}
C {devices/lab_wire.sym} 20 -150 0 0 {name=l86 lab=VDD}
C {devices/lab_wire.sym} 20 -30 0 0 {name=l87 lab=VSS}
N -20 -120 -20 -60 {}
C {devices/lab_wire.sym} -20 -90 0 0 {name=l88 lab=b0}
C {devices/lab_wire.sym} 20 -90 0 0 {name=l89 lab=b0b}
C {devices/ipin.sym} -80 -90 0 0 {name=P5 lab=b0}
C {devices/lab_wire.sym} -80 -90 0 0 {name=l90 lab=b0}
C {sg13_lv_pmos.sym} 0 120 0 0 {name=Msrc0
l=1u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 120 0 0 {name=l91 lab=VDD}
C {devices/lab_wire.sym} 20 90 0 0 {name=l92 lab=VDD}
C {devices/lab_wire.sym} -20 120 0 0 {name=l93 lab=vpcs}
C {devices/lab_wire.sym} 20 150 0 0 {name=l94 lab=cs0}
C {sg13_lv_nmos.sym} -50 260 0 0 {name=Mto0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} -30 260 0 0 {name=l95 lab=VSS}
C {sg13_lv_nmos.sym} 70 260 0 0 {name=Mdo0
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 90 260 0 0 {name=l96 lab=VSS}
N 20 150 20 290 {}
N -30 290 90 290 {}
C {devices/lab_wire.sym} -30 290 0 0 {name=l97 lab=cs0}
C {devices/lab_wire.sym} -30 230 0 0 {name=l98 lab=iout}
C {devices/lab_wire.sym} 90 230 0 0 {name=l99 lab=ndump}
C {devices/lab_wire.sym} -70 260 0 0 {name=l100 lab=b0}
C {devices/lab_wire.sym} 50 260 0 0 {name=l101 lab=b0b}
C {sg13_lv_pmos.sym} 260 -120 0 0 {name=Minvp1
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 280 -120 0 0 {name=l102 lab=VDD}
C {sg13_lv_nmos.sym} 260 -60 0 0 {name=Minvn1
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 280 -60 0 0 {name=l103 lab=VSS}
C {devices/lab_wire.sym} 280 -150 0 0 {name=l104 lab=VDD}
C {devices/lab_wire.sym} 280 -30 0 0 {name=l105 lab=VSS}
N 240 -120 240 -60 {}
C {devices/lab_wire.sym} 240 -90 0 0 {name=l106 lab=b1}
C {devices/lab_wire.sym} 280 -90 0 0 {name=l107 lab=b1b}
C {devices/ipin.sym} 180 -90 0 0 {name=P6 lab=b1}
C {devices/lab_wire.sym} 180 -90 0 0 {name=l108 lab=b1}
C {sg13_lv_pmos.sym} 260 120 0 0 {name=Msrc1
l=1u
w=2u
ng=1
m=2
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 280 120 0 0 {name=l109 lab=VDD}
C {devices/lab_wire.sym} 280 90 0 0 {name=l110 lab=VDD}
C {devices/lab_wire.sym} 240 120 0 0 {name=l111 lab=vpcs}
C {devices/lab_wire.sym} 280 150 0 0 {name=l112 lab=cs1}
C {sg13_lv_nmos.sym} 210 260 0 0 {name=Mto1
l=0.13u
w=1u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 230 260 0 0 {name=l113 lab=VSS}
C {sg13_lv_nmos.sym} 330 260 0 0 {name=Mdo1
l=0.13u
w=1u
ng=1
m=2
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 350 260 0 0 {name=l114 lab=VSS}
N 280 150 280 290 {}
N 230 290 350 290 {}
C {devices/lab_wire.sym} 230 290 0 0 {name=l115 lab=cs1}
C {devices/lab_wire.sym} 230 230 0 0 {name=l116 lab=iout}
C {devices/lab_wire.sym} 350 230 0 0 {name=l117 lab=ndump}
C {devices/lab_wire.sym} 190 260 0 0 {name=l118 lab=b1}
C {devices/lab_wire.sym} 310 260 0 0 {name=l119 lab=b1b}
C {sg13_lv_pmos.sym} 520 -120 0 0 {name=Minvp2
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 540 -120 0 0 {name=l120 lab=VDD}
C {sg13_lv_nmos.sym} 520 -60 0 0 {name=Minvn2
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 540 -60 0 0 {name=l121 lab=VSS}
C {devices/lab_wire.sym} 540 -150 0 0 {name=l122 lab=VDD}
C {devices/lab_wire.sym} 540 -30 0 0 {name=l123 lab=VSS}
N 500 -120 500 -60 {}
C {devices/lab_wire.sym} 500 -90 0 0 {name=l124 lab=b2}
C {devices/lab_wire.sym} 540 -90 0 0 {name=l125 lab=b2b}
C {devices/ipin.sym} 440 -90 0 0 {name=P7 lab=b2}
C {devices/lab_wire.sym} 440 -90 0 0 {name=l126 lab=b2}
C {sg13_lv_pmos.sym} 520 120 0 0 {name=Msrc2
l=1u
w=2u
ng=1
m=4
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 540 120 0 0 {name=l127 lab=VDD}
C {devices/lab_wire.sym} 540 90 0 0 {name=l128 lab=VDD}
C {devices/lab_wire.sym} 500 120 0 0 {name=l129 lab=vpcs}
C {devices/lab_wire.sym} 540 150 0 0 {name=l130 lab=cs2}
C {sg13_lv_nmos.sym} 470 260 0 0 {name=Mto2
l=0.13u
w=1u
ng=1
m=4
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 490 260 0 0 {name=l131 lab=VSS}
C {sg13_lv_nmos.sym} 590 260 0 0 {name=Mdo2
l=0.13u
w=1u
ng=1
m=4
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 610 260 0 0 {name=l132 lab=VSS}
N 540 150 540 290 {}
N 490 290 610 290 {}
C {devices/lab_wire.sym} 490 290 0 0 {name=l133 lab=cs2}
C {devices/lab_wire.sym} 490 230 0 0 {name=l134 lab=iout}
C {devices/lab_wire.sym} 610 230 0 0 {name=l135 lab=ndump}
C {devices/lab_wire.sym} 450 260 0 0 {name=l136 lab=b2}
C {devices/lab_wire.sym} 570 260 0 0 {name=l137 lab=b2b}
C {sg13_lv_pmos.sym} 780 -120 0 0 {name=Minvp3
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 800 -120 0 0 {name=l138 lab=VDD}
C {sg13_lv_nmos.sym} 780 -60 0 0 {name=Minvn3
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 800 -60 0 0 {name=l139 lab=VSS}
C {devices/lab_wire.sym} 800 -150 0 0 {name=l140 lab=VDD}
C {devices/lab_wire.sym} 800 -30 0 0 {name=l141 lab=VSS}
N 760 -120 760 -60 {}
C {devices/lab_wire.sym} 760 -90 0 0 {name=l142 lab=b3}
C {devices/lab_wire.sym} 800 -90 0 0 {name=l143 lab=b3b}
C {devices/ipin.sym} 700 -90 0 0 {name=P8 lab=b3}
C {devices/lab_wire.sym} 700 -90 0 0 {name=l144 lab=b3}
C {sg13_lv_pmos.sym} 780 120 0 0 {name=Msrc3
l=1u
w=2u
ng=1
m=8
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 800 120 0 0 {name=l145 lab=VDD}
C {devices/lab_wire.sym} 800 90 0 0 {name=l146 lab=VDD}
C {devices/lab_wire.sym} 760 120 0 0 {name=l147 lab=vpcs}
C {devices/lab_wire.sym} 800 150 0 0 {name=l148 lab=cs3}
C {sg13_lv_nmos.sym} 730 260 0 0 {name=Mto3
l=0.13u
w=1u
ng=1
m=8
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 750 260 0 0 {name=l149 lab=VSS}
C {sg13_lv_nmos.sym} 850 260 0 0 {name=Mdo3
l=0.13u
w=1u
ng=1
m=8
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 870 260 0 0 {name=l150 lab=VSS}
N 800 150 800 290 {}
N 750 290 870 290 {}
C {devices/lab_wire.sym} 750 290 0 0 {name=l151 lab=cs3}
C {devices/lab_wire.sym} 750 230 0 0 {name=l152 lab=iout}
C {devices/lab_wire.sym} 870 230 0 0 {name=l153 lab=ndump}
C {devices/lab_wire.sym} 710 260 0 0 {name=l154 lab=b3}
C {devices/lab_wire.sym} 830 260 0 0 {name=l155 lab=b3b}
C {sg13_lv_nmos.sym} 1040 260 0 0 {name=Mdump
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1060 260 0 0 {name=l156 lab=VSS}
C {devices/lab_wire.sym} 1060 230 0 0 {name=l157 lab=ndump}
C {devices/lab_wire.sym} 1020 260 0 0 {name=l158 lab=ndump}
C {devices/lab_wire.sym} 1060 290 0 0 {name=l159 lab=VSS}
C {devices/iopin.sym} 1160 230 0 0 {name=P9 lab=iout}
C {devices/lab_wire.sym} 1160 230 0 0 {name=l160 lab=iout}
C {devices/iopin.sym} -260 -200 0 0 {name=P10 lab=VDD}
C {devices/lab_wire.sym} -260 -200 0 0 {name=l161 lab=VDD}
C {devices/iopin.sym} -260 360 0 0 {name=P11 lab=VSS}
C {devices/lab_wire.sym} -260 360 0 0 {name=l162 lab=VSS}
