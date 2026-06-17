v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {Current-starved ring oscillator (5 stages) - schematic == ring_oscillator.spice} -200 -900 0 0 0.5 0.5 {}
C {sg13_lv_nmos.sym} 0 0 0 0 {name=Mbn
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -30 0 0 {name=l1 lab=ibias}
C {devices/lab_wire.sym} -20 0 0 0 {name=l2 lab=ibias}
C {devices/lab_wire.sym} 20 30 0 0 {name=l3 lab=VSS}
C {devices/lab_wire.sym} 20 0 0 0 {name=l4 lab=VSS}
C {sg13_lv_nmos.sym} 0 -250 0 0 {name=Mmir
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -280 0 0 {name=l5 lab=vbp}
C {devices/lab_wire.sym} -20 -250 0 0 {name=l6 lab=ibias}
C {devices/lab_wire.sym} 20 -220 0 0 {name=l7 lab=VSS}
C {devices/lab_wire.sym} 20 -250 0 0 {name=l8 lab=VSS}
C {sg13_lv_pmos.sym} 0 -500 0 0 {name=Mbp
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 -470 0 0 {name=l9 lab=vbp}
C {devices/lab_wire.sym} -20 -500 0 0 {name=l10 lab=vbp}
C {devices/lab_wire.sym} 20 -530 0 0 {name=l11 lab=VDD}
C {devices/lab_wire.sym} 20 -500 0 0 {name=l12 lab=VDD}
C {sg13_lv_pmos.sym} 350 -600 0 0 {name=Mcp1
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -570 0 0 {name=l13 lab=pp1}
C {devices/lab_wire.sym} 330 -600 0 0 {name=l14 lab=vbp}
C {devices/lab_wire.sym} 370 -630 0 0 {name=l15 lab=VDD}
C {devices/lab_wire.sym} 370 -600 0 0 {name=l16 lab=VDD}
C {sg13_lv_pmos.sym} 350 -400 0 0 {name=Mp1
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -370 0 0 {name=l17 lab=n1}
C {devices/lab_wire.sym} 330 -400 0 0 {name=l18 lab=n5}
C {devices/lab_wire.sym} 370 -430 0 0 {name=l19 lab=pp1}
C {devices/lab_wire.sym} 370 -400 0 0 {name=l20 lab=VDD}
C {sg13_lv_nmos.sym} 350 -200 0 0 {name=Mn1
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -230 0 0 {name=l21 lab=n1}
C {devices/lab_wire.sym} 330 -200 0 0 {name=l22 lab=n5}
C {devices/lab_wire.sym} 370 -170 0 0 {name=l23 lab=nn1}
C {devices/lab_wire.sym} 370 -200 0 0 {name=l24 lab=VSS}
C {sg13_lv_nmos.sym} 350 0 0 0 {name=Mcn1
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 370 -30 0 0 {name=l25 lab=nn1}
C {devices/lab_wire.sym} 330 0 0 0 {name=l26 lab=ibias}
C {devices/lab_wire.sym} 370 30 0 0 {name=l27 lab=VSS}
C {devices/lab_wire.sym} 370 0 0 0 {name=l28 lab=VSS}
C {sg13_lv_pmos.sym} 650 -600 0 0 {name=Mcp2
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 670 -570 0 0 {name=l29 lab=pp2}
C {devices/lab_wire.sym} 630 -600 0 0 {name=l30 lab=vbp}
C {devices/lab_wire.sym} 670 -630 0 0 {name=l31 lab=VDD}
C {devices/lab_wire.sym} 670 -600 0 0 {name=l32 lab=VDD}
C {sg13_lv_pmos.sym} 650 -400 0 0 {name=Mp2
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 670 -370 0 0 {name=l33 lab=n2}
C {devices/lab_wire.sym} 630 -400 0 0 {name=l34 lab=n1}
C {devices/lab_wire.sym} 670 -430 0 0 {name=l35 lab=pp2}
C {devices/lab_wire.sym} 670 -400 0 0 {name=l36 lab=VDD}
C {sg13_lv_nmos.sym} 650 -200 0 0 {name=Mn2
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 670 -230 0 0 {name=l37 lab=n2}
C {devices/lab_wire.sym} 630 -200 0 0 {name=l38 lab=n1}
C {devices/lab_wire.sym} 670 -170 0 0 {name=l39 lab=nn2}
C {devices/lab_wire.sym} 670 -200 0 0 {name=l40 lab=VSS}
C {sg13_lv_nmos.sym} 650 0 0 0 {name=Mcn2
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 670 -30 0 0 {name=l41 lab=nn2}
C {devices/lab_wire.sym} 630 0 0 0 {name=l42 lab=ibias}
C {devices/lab_wire.sym} 670 30 0 0 {name=l43 lab=VSS}
C {devices/lab_wire.sym} 670 0 0 0 {name=l44 lab=VSS}
C {sg13_lv_pmos.sym} 950 -600 0 0 {name=Mcp3
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 970 -570 0 0 {name=l45 lab=pp3}
C {devices/lab_wire.sym} 930 -600 0 0 {name=l46 lab=vbp}
C {devices/lab_wire.sym} 970 -630 0 0 {name=l47 lab=VDD}
C {devices/lab_wire.sym} 970 -600 0 0 {name=l48 lab=VDD}
C {sg13_lv_pmos.sym} 950 -400 0 0 {name=Mp3
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 970 -370 0 0 {name=l49 lab=n3}
C {devices/lab_wire.sym} 930 -400 0 0 {name=l50 lab=n2}
C {devices/lab_wire.sym} 970 -430 0 0 {name=l51 lab=pp3}
C {devices/lab_wire.sym} 970 -400 0 0 {name=l52 lab=VDD}
C {sg13_lv_nmos.sym} 950 -200 0 0 {name=Mn3
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 970 -230 0 0 {name=l53 lab=n3}
C {devices/lab_wire.sym} 930 -200 0 0 {name=l54 lab=n2}
C {devices/lab_wire.sym} 970 -170 0 0 {name=l55 lab=nn3}
C {devices/lab_wire.sym} 970 -200 0 0 {name=l56 lab=VSS}
C {sg13_lv_nmos.sym} 950 0 0 0 {name=Mcn3
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 970 -30 0 0 {name=l57 lab=nn3}
C {devices/lab_wire.sym} 930 0 0 0 {name=l58 lab=ibias}
C {devices/lab_wire.sym} 970 30 0 0 {name=l59 lab=VSS}
C {devices/lab_wire.sym} 970 0 0 0 {name=l60 lab=VSS}
C {sg13_lv_pmos.sym} 1250 -600 0 0 {name=Mcp4
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1270 -570 0 0 {name=l61 lab=pp4}
C {devices/lab_wire.sym} 1230 -600 0 0 {name=l62 lab=vbp}
C {devices/lab_wire.sym} 1270 -630 0 0 {name=l63 lab=VDD}
C {devices/lab_wire.sym} 1270 -600 0 0 {name=l64 lab=VDD}
C {sg13_lv_pmos.sym} 1250 -400 0 0 {name=Mp4
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1270 -370 0 0 {name=l65 lab=n4}
C {devices/lab_wire.sym} 1230 -400 0 0 {name=l66 lab=n3}
C {devices/lab_wire.sym} 1270 -430 0 0 {name=l67 lab=pp4}
C {devices/lab_wire.sym} 1270 -400 0 0 {name=l68 lab=VDD}
C {sg13_lv_nmos.sym} 1250 -200 0 0 {name=Mn4
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1270 -230 0 0 {name=l69 lab=n4}
C {devices/lab_wire.sym} 1230 -200 0 0 {name=l70 lab=n3}
C {devices/lab_wire.sym} 1270 -170 0 0 {name=l71 lab=nn4}
C {devices/lab_wire.sym} 1270 -200 0 0 {name=l72 lab=VSS}
C {sg13_lv_nmos.sym} 1250 0 0 0 {name=Mcn4
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1270 -30 0 0 {name=l73 lab=nn4}
C {devices/lab_wire.sym} 1230 0 0 0 {name=l74 lab=ibias}
C {devices/lab_wire.sym} 1270 30 0 0 {name=l75 lab=VSS}
C {devices/lab_wire.sym} 1270 0 0 0 {name=l76 lab=VSS}
C {sg13_lv_pmos.sym} 1550 -600 0 0 {name=Mcp5
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1570 -570 0 0 {name=l77 lab=pp5}
C {devices/lab_wire.sym} 1530 -600 0 0 {name=l78 lab=vbp}
C {devices/lab_wire.sym} 1570 -630 0 0 {name=l79 lab=VDD}
C {devices/lab_wire.sym} 1570 -600 0 0 {name=l80 lab=VDD}
C {sg13_lv_pmos.sym} 1550 -400 0 0 {name=Mp5
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1570 -370 0 0 {name=l81 lab=n5}
C {devices/lab_wire.sym} 1530 -400 0 0 {name=l82 lab=n4}
C {devices/lab_wire.sym} 1570 -430 0 0 {name=l83 lab=pp5}
C {devices/lab_wire.sym} 1570 -400 0 0 {name=l84 lab=VDD}
C {sg13_lv_nmos.sym} 1550 -200 0 0 {name=Mn5
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1570 -230 0 0 {name=l85 lab=n5}
C {devices/lab_wire.sym} 1530 -200 0 0 {name=l86 lab=n4}
C {devices/lab_wire.sym} 1570 -170 0 0 {name=l87 lab=nn5}
C {devices/lab_wire.sym} 1570 -200 0 0 {name=l88 lab=VSS}
C {sg13_lv_nmos.sym} 1550 0 0 0 {name=Mcn5
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1570 -30 0 0 {name=l89 lab=nn5}
C {devices/lab_wire.sym} 1530 0 0 0 {name=l90 lab=ibias}
C {devices/lab_wire.sym} 1570 30 0 0 {name=l91 lab=VSS}
C {devices/lab_wire.sym} 1570 0 0 0 {name=l92 lab=VSS}
C {sg13_lv_pmos.sym} 1850 -600 0 0 {name=Mb1p
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1870 -570 0 0 {name=l93 lab=b1}
C {devices/lab_wire.sym} 1830 -600 0 0 {name=l94 lab=n5}
C {devices/lab_wire.sym} 1870 -630 0 0 {name=l95 lab=VDD}
C {devices/lab_wire.sym} 1870 -600 0 0 {name=l96 lab=VDD}
C {sg13_lv_nmos.sym} 1850 -400 0 0 {name=Mb1n
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1870 -430 0 0 {name=l97 lab=b1}
C {devices/lab_wire.sym} 1830 -400 0 0 {name=l98 lab=n5}
C {devices/lab_wire.sym} 1870 -370 0 0 {name=l99 lab=VSS}
C {devices/lab_wire.sym} 1870 -400 0 0 {name=l100 lab=VSS}
C {sg13_lv_pmos.sym} 1850 -200 0 0 {name=Mb2p
l=0.13u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1870 -170 0 0 {name=l101 lab=clk}
C {devices/lab_wire.sym} 1830 -200 0 0 {name=l102 lab=b1}
C {devices/lab_wire.sym} 1870 -230 0 0 {name=l103 lab=VDD}
C {devices/lab_wire.sym} 1870 -200 0 0 {name=l104 lab=VDD}
C {sg13_lv_nmos.sym} 1850 0 0 0 {name=Mb2n
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 1870 -30 0 0 {name=l105 lab=clk}
C {devices/lab_wire.sym} 1830 0 0 0 {name=l106 lab=b1}
C {devices/lab_wire.sym} 1870 30 0 0 {name=l107 lab=VSS}
C {devices/lab_wire.sym} 1870 0 0 0 {name=l108 lab=VSS}
C {devices/iopin.sym} -200 -700 0 0 {name=P1 lab=VDD}
C {devices/iopin.sym} -200 200 0 0 {name=P2 lab=VSS}
C {devices/iopin.sym} -350 100 0 0 {name=P3 lab=ibias}
C {devices/opin.sym} 2100 -200 0 0 {name=P4 lab=clk}
