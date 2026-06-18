v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
E {}
T {Current-starved ring oscillator (5 stages) == ring_oscillator.spice  [VDD/VSS/vbp/ibias are labeled rails]} -400 -160 0 0 0.4 0.4 {}
C {sg13_lv_pmos.sym} 0 0 0 0 {name=Mcp1
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 0 0 0 {name=l1 lab=VDD}
C {sg13_lv_pmos.sym} 0 60 0 0 {name=Mp1
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 60 0 0 {name=l2 lab=VDD}
C {sg13_lv_nmos.sym} 0 120 0 0 {name=Mn1
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 120 0 0 {name=l3 lab=VSS}
C {sg13_lv_nmos.sym} 0 180 0 0 {name=Mcn1
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 20 180 0 0 {name=l4 lab=VSS}
C {devices/lab_wire.sym} 20 -30 0 0 {name=l5 lab=VDD}
C {devices/lab_wire.sym} -20 0 0 0 {name=l6 lab=vbp}
C {devices/lab_wire.sym} 20 210 0 0 {name=l7 lab=VSS}
C {devices/lab_wire.sym} -20 180 0 0 {name=l8 lab=ibias}
N -20 60 -20 120 {}
C {devices/lab_wire.sym} -20 90 0 0 {name=l9 lab=n5}
C {devices/lab_wire.sym} 20 90 0 0 {name=l10 lab=n1}
C {sg13_lv_pmos.sym} 180 0 0 0 {name=Mcp2
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 200 0 0 0 {name=l11 lab=VDD}
C {sg13_lv_pmos.sym} 180 60 0 0 {name=Mp2
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 200 60 0 0 {name=l12 lab=VDD}
C {sg13_lv_nmos.sym} 180 120 0 0 {name=Mn2
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 200 120 0 0 {name=l13 lab=VSS}
C {sg13_lv_nmos.sym} 180 180 0 0 {name=Mcn2
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 200 180 0 0 {name=l14 lab=VSS}
C {devices/lab_wire.sym} 200 -30 0 0 {name=l15 lab=VDD}
C {devices/lab_wire.sym} 160 0 0 0 {name=l16 lab=vbp}
C {devices/lab_wire.sym} 200 210 0 0 {name=l17 lab=VSS}
C {devices/lab_wire.sym} 160 180 0 0 {name=l18 lab=ibias}
N 160 60 160 120 {}
C {devices/lab_wire.sym} 160 90 0 0 {name=l19 lab=n1}
C {devices/lab_wire.sym} 200 90 0 0 {name=l20 lab=n2}
C {sg13_lv_pmos.sym} 360 0 0 0 {name=Mcp3
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 380 0 0 0 {name=l21 lab=VDD}
C {sg13_lv_pmos.sym} 360 60 0 0 {name=Mp3
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 380 60 0 0 {name=l22 lab=VDD}
C {sg13_lv_nmos.sym} 360 120 0 0 {name=Mn3
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 380 120 0 0 {name=l23 lab=VSS}
C {sg13_lv_nmos.sym} 360 180 0 0 {name=Mcn3
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 380 180 0 0 {name=l24 lab=VSS}
C {devices/lab_wire.sym} 380 -30 0 0 {name=l25 lab=VDD}
C {devices/lab_wire.sym} 340 0 0 0 {name=l26 lab=vbp}
C {devices/lab_wire.sym} 380 210 0 0 {name=l27 lab=VSS}
C {devices/lab_wire.sym} 340 180 0 0 {name=l28 lab=ibias}
N 340 60 340 120 {}
C {devices/lab_wire.sym} 340 90 0 0 {name=l29 lab=n2}
C {devices/lab_wire.sym} 380 90 0 0 {name=l30 lab=n3}
C {sg13_lv_pmos.sym} 540 0 0 0 {name=Mcp4
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 560 0 0 0 {name=l31 lab=VDD}
C {sg13_lv_pmos.sym} 540 60 0 0 {name=Mp4
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 560 60 0 0 {name=l32 lab=VDD}
C {sg13_lv_nmos.sym} 540 120 0 0 {name=Mn4
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 560 120 0 0 {name=l33 lab=VSS}
C {sg13_lv_nmos.sym} 540 180 0 0 {name=Mcn4
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 560 180 0 0 {name=l34 lab=VSS}
C {devices/lab_wire.sym} 560 -30 0 0 {name=l35 lab=VDD}
C {devices/lab_wire.sym} 520 0 0 0 {name=l36 lab=vbp}
C {devices/lab_wire.sym} 560 210 0 0 {name=l37 lab=VSS}
C {devices/lab_wire.sym} 520 180 0 0 {name=l38 lab=ibias}
N 520 60 520 120 {}
C {devices/lab_wire.sym} 520 90 0 0 {name=l39 lab=n3}
C {devices/lab_wire.sym} 560 90 0 0 {name=l40 lab=n4}
C {sg13_lv_pmos.sym} 720 0 0 0 {name=Mcp5
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 740 0 0 0 {name=l41 lab=VDD}
C {sg13_lv_pmos.sym} 720 60 0 0 {name=Mp5
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 740 60 0 0 {name=l42 lab=VDD}
C {sg13_lv_nmos.sym} 720 120 0 0 {name=Mn5
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 740 120 0 0 {name=l43 lab=VSS}
C {sg13_lv_nmos.sym} 720 180 0 0 {name=Mcn5
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 740 180 0 0 {name=l44 lab=VSS}
C {devices/lab_wire.sym} 740 -30 0 0 {name=l45 lab=VDD}
C {devices/lab_wire.sym} 700 0 0 0 {name=l46 lab=vbp}
C {devices/lab_wire.sym} 740 210 0 0 {name=l47 lab=VSS}
C {devices/lab_wire.sym} 700 180 0 0 {name=l48 lab=ibias}
N 700 60 700 120 {}
C {devices/lab_wire.sym} 700 90 0 0 {name=l49 lab=n4}
C {devices/lab_wire.sym} 740 90 0 0 {name=l50 lab=n5}
C {sg13_lv_pmos.sym} -260 0 0 0 {name=Mbp
l=0.5u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} -240 0 0 0 {name=l51 lab=VDD}
C {devices/lab_wire.sym} -240 -30 0 0 {name=l52 lab=VDD}
C {devices/lab_wire.sym} -280 0 0 0 {name=l53 lab=vbp}
C {devices/lab_wire.sym} -240 30 0 0 {name=l54 lab=vbp}
C {sg13_lv_nmos.sym} -260 120 0 0 {name=Mmir
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} -240 120 0 0 {name=l55 lab=VSS}
C {devices/lab_wire.sym} -240 90 0 0 {name=l56 lab=vbp}
C {devices/lab_wire.sym} -280 120 0 0 {name=l57 lab=ibias}
C {devices/lab_wire.sym} -240 150 0 0 {name=l58 lab=VSS}
C {sg13_lv_nmos.sym} -410 120 0 0 {name=Mbn
l=0.5u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} -390 120 0 0 {name=l59 lab=VSS}
C {devices/lab_wire.sym} -390 90 0 0 {name=l60 lab=ibias}
C {devices/lab_wire.sym} -430 120 0 0 {name=l61 lab=ibias}
C {devices/lab_wire.sym} -390 150 0 0 {name=l62 lab=VSS}
C {devices/iopin.sym} -580 120 0 0 {name=P1 lab=ibias}
C {devices/lab_wire.sym} -580 120 0 0 {name=l63 lab=ibias}
N 20 90 160 90 {}
N 200 90 340 90 {}
N 380 90 520 90 {}
N 560 90 700 90 {}
C {sg13_lv_pmos.sym} 940 0 0 0 {name=Mb1p
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 960 0 0 0 {name=l64 lab=VDD}
C {sg13_lv_nmos.sym} 940 60 0 0 {name=Mb1n
l=0.13u
w=0.5u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 960 60 0 0 {name=l65 lab=VSS}
C {sg13_lv_pmos.sym} 940 150 0 0 {name=Mb2p
l=0.13u
w=2u
ng=1
m=1
model=sg13_lv_pmos
spiceprefix=X
}
C {devices/lab_wire.sym} 960 150 0 0 {name=l66 lab=VDD}
C {sg13_lv_nmos.sym} 940 210 0 0 {name=Mb2n
l=0.13u
w=1u
ng=1
m=1
model=sg13_lv_nmos
spiceprefix=X
}
C {devices/lab_wire.sym} 960 210 0 0 {name=l67 lab=VSS}
C {devices/lab_wire.sym} 960 -30 0 0 {name=l68 lab=VDD}
C {devices/lab_wire.sym} 960 90 0 0 {name=l69 lab=VSS}
C {devices/lab_wire.sym} 960 120 0 0 {name=l70 lab=VDD}
C {devices/lab_wire.sym} 960 240 0 0 {name=l71 lab=VSS}
N 920 0 920 60 {}
C {devices/lab_wire.sym} 920 30 0 0 {name=l72 lab=n5}
C {devices/lab_wire.sym} 960 30 0 0 {name=l73 lab=b1}
N 920 150 920 210 {}
C {devices/lab_wire.sym} 920 180 0 0 {name=l74 lab=b1}
C {devices/lab_wire.sym} 960 180 0 0 {name=l75 lab=clk}
N 960 180 1020 180 {}
C {devices/opin.sym} 1020 180 0 0 {name=P2 lab=clk}
C {devices/iopin.sym} -260 -120 0 0 {name=P3 lab=VDD}
C {devices/lab_wire.sym} -260 -120 0 0 {name=l76 lab=VDD}
C {devices/iopin.sym} -260 360 0 0 {name=P4 lab=VSS}
C {devices/lab_wire.sym} -260 360 0 0 {name=l77 lab=VSS}
