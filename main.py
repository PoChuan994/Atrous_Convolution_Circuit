import cv2
import numpy as np
import math
from PIL import Image as im
import torchvision.transforms as T

grayscale_output =  []
layer0_data = []
layer1_data = []
datanum = -1
bin_conv_frc = ""
layer0_output = np.zeros([64, 64], np.float32)

input_image = im.open("./images/bleach.png")
input_image = input_image.convert("L")
transforms = T.Resize(size=(64, 64), antialias=True)
input_image = transforms(input_image)

### produce img.dat
input_image = np.asarray(input_image, np.float32)
np.set_printoptions(precision=4)
for y in range(64):
    for x in range(64):
        datanum = datanum + 1
        int_part = int(input_image[y][x])
        binary_part = format(int_part, '09b')
        binary_part = binary_part+"0000"
        grayscale_output.append(str(binary_part)+" //data "+str(datanum)+":"+str(int_part)+"\n")

path = "./data/img.dat"
f = open(path, "w")
f.writelines(grayscale_output)
f.close()
datanum = -1    # reset

### layer0
# Replicate padding
input_image = cv2.copyMakeBorder(input_image,2,2,2,2,cv2.BORDER_REPLICATE)
input = np.asarray(input_image, np.float32)

# atrous convolution + ReLU
AC_output = np.zeros([64, 64], np.float32)
for y in range(64):   # collumn shift
    for x in range(64):   # row shift
        datanum = datanum + 1
        AC_output[y][x] = input[y][x]*(-0.0625) + input[y][x+2]*(-0.125) + input[y][x+4]*(-0.0625) + input[y+2][x]*(-0.25) + input[y+2][x+2]*1 + input[y+2][x+4]*(-0.25) + input[y+4][x]*(-0.0625) + input[y+4][x+2]*(-0.125) + input[y+4][x+4]*(-0.0625) -0.75
        # ReLU
        tmp_test1 = max(AC_output[y][x], 0)
        layer0_output[y][x] = max(AC_output[y][x], 0)
        conv_int_part = math.floor(layer0_output[y][x])
        conv_float_part = layer0_output[y][x] % 1
        #  transform integer part into binary
        bin_conv_int = format(conv_int_part,'09b')
        #  transform fraction part into binary
        if(conv_float_part==0):
            bin_conv_frc = "0000"
        elif(conv_float_part==0.0625):
            bin_conv_frc = "0001"
        elif (conv_float_part == 0.125):
            bin_conv_frc = "0010"
        elif (conv_float_part == 0.1875):
            bin_conv_frc = "0011"
        elif (conv_float_part == 0.25):
            bin_conv_frc = "0100"
        elif (conv_float_part == 0.3125):
            bin_conv_frc = "0101"
        elif (conv_float_part == 0.375):
            bin_conv_frc = "0110"
        elif (conv_float_part == 0.4375):
            bin_conv_frc = "0111"
        elif (conv_float_part == 0.5):
            bin_conv_frc = "1000"
        elif (conv_float_part == 0.5625):
            bin_conv_frc = "1001"
        elif (conv_float_part ==0.625):
            bin_conv_frc = "1010"
        elif (conv_float_part == 0.6875):
            bin_conv_frc = "1011"
        elif (conv_float_part == 0.75):
            bin_conv_frc = "1100"
        elif (conv_float_part == 0.8125):
            bin_conv_frc = "1101"
        elif (conv_float_part == 0.875):
            bin_conv_frc = "1110"
        else:
            bin_conv_frc = "1111"
        layer0_data.append(str(bin_conv_int)+bin_conv_frc+"  //data "+str(datanum)+": "+str(layer0_output[y][x])+"\n")


path = "./data/layer0_golden.dat"
f = open(path, "w")
f.writelines(layer0_data)
f.close()
datanum=-1


### layer1
# Max-pooling
maxpooling_output = np.zeros([32, 32], np.float32)
y_index = 0
x_index = 0
for y in range(0, 64, 2):
    x_index = 0
    for x in range(0, 64, 2):
        maxpooling_output[y_index][x_index] = max(layer0_output[y][x], layer0_output[y][x+1], layer0_output[y+1][x], layer0_output[y+1][x+1])
        # maxpooling_output[y_index][x_index] = np.max(layer0_output[y:y+2, x:x+2])
        x_index = x_index + 1
    y_index = y_index + 1

# Round up
for y in range(32):
    for x in range(32):
        maxpooling_output[y][x] = math.ceil(maxpooling_output[y][x])

        datanum +=1
        int_part = int(maxpooling_output[y][x])
        binary_part = format(int_part, "09b")
        binary_part = binary_part + "0000"
        layer1_data.append(str(binary_part)+" //data " + str(datanum) + ": " + str(int_part) + "\n")

path = "./data/layer1_golden.dat"
f = open(path, "w")
f.writelines(layer1_data)
f.close()