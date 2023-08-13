# Atrous_Convolution_Circuit

About this work
- There are two layers of CNN in this work.
- In layer 0, there are three task, including:
  1. replicate padding
  2. atrous convolution
  3. ReLU function 
- In layer 1, there are two task, including:
  1. max pooling
  2. round up

Data sumary of gate level simulation (by Quartus)
- Device: EP4CE55F23A7
- Totoal logic element: 895/55856(2%)
- Total registers: 93
- Total pins: 82/325(25%)
- Total virtual pins: 0
- Total memory bits: 0 /2396160(0%)
- Embedded Multiplier 9-bit element: 0 /308(0%)
- Total PLLs: 0/4(0%) 

Software Verification
 - main.py is used to produce img.dat, layer0_goden.dat, and layer1_goden.dat file.
 - img.dat file is used to be the input of ATCONV.v file.
 - layer0_goden.dat and layer1_goden.dat can be used to verify whether outputs of ATCONV.v file are correct or not.
