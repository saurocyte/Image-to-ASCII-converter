import os
import strutils
import csfml
import typetraits
import math

proc getImg(imgPath: string): Image = 
    let
        myImageContents: Image = newImage(imgPath)
    result = myImageContents

# HOLY. SHIT. 
proc incPointer [T](a: ptr T): ptr T =
    result = cast[ptr T](cast[uint](a) + cast[uint](1))

proc luminocityMap(img: Image): seq[float] = 
    # Get pixel data
    var 
        pixels: ptr uint8 = (pixelsPtr(img))
        i: int = 0
        groupedPixels: seq[seq[uint8]] = @[]
        pixel: seq[uint8] = @[]
    # Group data
    while i < (size(img).x * size(img).y * 4):
        pixel.add(pixels[])
        pixels = incPointer(pixels)
        if (i + 1) %% 4 == 0:
            groupedPixels.add(pixel)
            pixel = @[]
        inc(i)
    # Create map
    var lumMap: seq[float64] = @[]
    for pixel in groupedPixels:
        var 
            linearY: float = 0
            linearR: float = 0
            linearG: float = 0
            linearB: float = 0
            srgbY: float = 0
        if pixel[0].float < 0.04045:
            linearR = float(pixel[0]) / 12.92
        else:
            linearR = pow(((float(pixel[0]) + 0.055) / 1.055), 2.4)
        if float(pixel[1]) < 0.04045:
            linearG = pixel[1].float / 12.92
        else:
            linearG = pow(((float(pixel[1]) + 0.055) / 1.055), 2.4)
        if float(pixel[2]) < 0.04045:
            linearB = pixel[2].float / 12.92
        else:
            linearB = pow(((float(pixel[2]) + 0.055) / 1.055), 2.4)
        linearY += 0.2126 * linearR + 0.7152 * linearG + 0.0722 * linearB
        if linearY > 0.0031308:
            srgbY = pow(linearY, 1 / 2.4) * 1.055 - 0.055   
        else:
            srgbY = 12.92 * linearY
        lumMap.add(srgbY)
    result = lumMap

proc toAscii(lumMap: seq[float]): string = 
    let symbols = [".", ":", ";", "o", "x", "%", "#", "@"]
    var 
        ascii: string = ""
    for pixelLum in lumMap:
        # Luminocuty / constant (difference) * charNum
        ascii.add(symbols[int(pixelLum / 255 * float(len(symbols)))]) 
    result = ascii

proc saveImg(img: string) =
    # Getting image width (sry)
    let width = newImage(paramStr(1)).size.y

    let f = open("out.txt", fmWrite)
    var i = 0
    while i < len(img):
        write(f, img[i])
        if (i + 1) %% width == 0:
            write(f, "\n")
        inc(i)
        

saveImg(toAscii(luminocityMap(getImg(paramStr(1)))))