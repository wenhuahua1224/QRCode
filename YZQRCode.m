//
//  YZQRCode.m
//  YZQRCode
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "YZQRCode.h"
#import "UIImage+Resize.h"
#import "ZXLuminanceSource.h"
#import "ZXCGImageLuminanceSource.h"
#import "ZXBinaryBitmap.h"
#import "ZXHybridBinarizer.h"
#import "ZXDecodeHints.h"
#import "ZXMultiFormatReader.h"
#import "ZXResult.h"
#import "ZXEncodeHints.h"
#import "ZXMultiFormatWriter.h"

@implementation YZQRCode

+ (YZQRCode *)sharedYZQRCode
{
    static YZQRCode* only = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        only = [[YZQRCode alloc] init];
    });
    return only;
}

//通过两张图片进行位置和大小的绘制，实现两张图片的合并；其实此原理做法也可以用于多张图片的合并
- (UIImage *) addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize {
    UIGraphicsBeginImageContext(image.size);
    
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    CGFloat widthOfIcon = iconSize.width;
    CGFloat heightOfIcon = iconSize.height;
    
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    [icon drawInRect:CGRectMake((widthOfImage-widthOfIcon)/2, (heightOfImage-heightOfIcon)/2,widthOfIcon, heightOfIcon)];
    UIImage *img =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

//通过两张图片进行位置和大小的绘制，实现两张图片的合并；其实此原理做法也可以用于多张图片的合并
- (UIImage *) addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale {
    UIGraphicsBeginImageContext(image.size);
    
    CGFloat widthOfImage = image.size.width;
    CGFloat heightOfImage = image.size.height;
    CGFloat widthOfIcon = widthOfImage/scale;
    CGFloat heightOfIcon = heightOfImage/scale;
    
    [image drawInRect:CGRectMake(0, 0, widthOfImage, heightOfImage)];
    [icon drawInRect:CGRectMake((widthOfImage-widthOfIcon)/2, (heightOfImage-heightOfIcon)/2,widthOfIcon, heightOfIcon)];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return img;
}

- (void)setColorIntensities:(int8_t *)intensities color:(CGColorRef)color {
    memset(intensities, 0, 4);
    
    size_t numberOfComponents = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);
    
    if (numberOfComponents == 4) {
        for (int i = 0; i < 4; i++) {
            intensities[i] = components[i] * 255;
        }
    } else if (numberOfComponents == 2) {
        for (int i = 0; i < 3; i++) {
            intensities[i] = components[0] * 255;
        }
        intensities[3] = components[1] * 255;
    }
}

- (NSString *) readerWithQRCodeImage:(UIImage *)image error:(NSError *__autoreleasing *)error
{
    //  由于拍照的图片大于280，二维码的标准图片是280*280，所以要讲图片进行缩小操作，
    if ((image.size.width > 280) && (image.size.height >280)) {
        image = [image resizedImageToSize:CGSizeMake(280, 280)];
    }
    CGImageRef imageToDecode = image.CGImage;
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:error];
    
    if (result) {
        return result.text;
    }else {
        return nil;
    }
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString format:(YZQRcodeFormat)yzQRCodeformat imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError **)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBarcodeFormat zxBarcodeFormat = [self yzQRCodeformatWithZxBarcodeFormat:yzQRCodeformat];
    ZXBitMatrix* result = [writer encode:codeString format:zxBarcodeFormat width:width height:height error:error];
    if (result) {
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString format:(YZQRcodeFormat)yzQRCodeformat imageWidth:(CGFloat)width imageHeight:(CGFloat)height QRCodeImageColor:(UIColor *)imageColor BackgroundColor:(UIColor *)backgroundColor error:(NSError *__autoreleasing *)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBarcodeFormat zxBarcodeFormat = [self yzQRCodeformatWithZxBarcodeFormat:yzQRCodeformat];
    ZXBitMatrix* result = [writer encode:codeString format:zxBarcodeFormat width:width height:height error:error];
    if (result) {
        ZXImage* zximage = [ZXImage imageWithMatrix:result onColor:imageColor.CGColor offColor:backgroundColor.CGColor];
        CGImageRef image = [zximage cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }
}

- (ZXBarcodeFormat) yzQRCodeformatWithZxBarcodeFormat:(YZQRcodeFormat) yzQRCodeformat;
{
    if (yzQRCodeformat == YZQRcodeFormatAztec) {
        /** Aztec 2D barcode format. */
        return kBarcodeFormatAztec;
    } else if (yzQRCodeformat == YZQRcodeFormatCodabar) {
        /** CODABAR 1D format. */
        return kBarcodeFormatCodabar;
    } else if (yzQRCodeformat == YZQRcodeFormatCode39) {
        /** Code 39 1D format. */
        return kBarcodeFormatCode39;
    } else if (yzQRCodeformat == YZQRcodeFormatCode128) {
        /** Code 128 1D format. */
        return kBarcodeFormatCode128;
    } else if (yzQRCodeformat == YZQRcodeFormatDataMatrix) {
        /** Data Matrix 2D barcode format. */
        return kBarcodeFormatDataMatrix;
    } else if (yzQRCodeformat == YZQRcodeFormatEan8) {
        /** EAN-8 1D format. */
        return kBarcodeFormatEan8;
    } else if (yzQRCodeformat == YZQRcodeFormatEan13) {
        /** EAN-13 1D format. */
        return kBarcodeFormatEan13;
    } else if (yzQRCodeformat == YZQRcodeFormatITF) {
        /** ITF (Interleaved Two of Five) 1D format. */
        return kBarcodeFormatITF;
    } else if (yzQRCodeformat == YZQRcodeFormatMaxiCode) {
        /** MaxiCode 2D barcode format. */
        return kBarcodeFormatMaxiCode;
    } else if (yzQRCodeformat == YZQRcodeFormatPDF417) {
        /** PDF417 format. */
        return kBarcodeFormatPDF417;
    } else if (yzQRCodeformat == YZQRcodeFormatQRCode) {
        /** QR Code 2D barcode format. */
        return kBarcodeFormatQRCode;
    } else if (yzQRCodeformat == YZQRcodeFormatRSS14) {
        /** RSS 14 */
        return kBarcodeFormatRSS14;
    } else if (yzQRCodeformat == YZQRcodeFormatRSSExpanded) {
        /** RSS EXPANDED */
        return kBarcodeFormatRSSExpanded;
    } else if (yzQRCodeformat == YZQRcodeFormatUPCA) {
        /** UPC-A 1D format. */
        return kBarcodeFormatUPCA;
    } else if (yzQRCodeformat == YZQRcodeFormatUPCE) {
        /** UPC-E 1D format. */
        return kBarcodeFormatUPCE;
    } else if (yzQRCodeformat == YZQRcodeFormatUPCEANExtension) {
        /** UPC/EAN extension format. Not a stand-alone format. */
        return kBarcodeFormatUPCEANExtension;
    } else {
        return kBarcodeFormatQRCode;
    }
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString leftTopColor:(UIColor *)leftTopColor rightTopColor:(UIColor *)rightTopColor leftDownColor:(UIColor *)leftDownColor rightDownColor:(UIColor *)rightDownColor offColor:(UIColor *) offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError *__autoreleasing *)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:codeString format:kBarcodeFormatQRCode width:width height:height error:error];
    if (result) {
        ZXImage* zximage = [self imageWithMatrix:result leftTopColor:leftTopColor.CGColor rightTopColor:rightTopColor.CGColor leftDownColor:leftDownColor.CGColor rightDownColor:rightDownColor.CGColor offColor:offColor.CGColor];
        CGImageRef image = [zximage cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }

}

// 四个角四种颜色
- (ZXImage *)imageWithMatrix:(ZXBitMatrix *)matrix leftTopColor:(CGColorRef)leftTopColor rightTopColor:(CGColorRef)rightTopColor leftDownColor:(CGColorRef)leftDownColor rightDownColor:(CGColorRef)rightDownColor offColor:(CGColorRef)offColor {
    int8_t leftTopColorIntensities[4],rightTopColorIntensities[4], leftDownColorIntensities[4], rightDownColorIntensities[4], offIntensities[4];
    
    [self setColorIntensities:leftTopColorIntensities color:leftTopColor];
    [self setColorIntensities:rightTopColorIntensities color:rightTopColor];
    [self setColorIntensities:leftDownColorIntensities color:leftDownColor];
    [self setColorIntensities:rightDownColorIntensities color:rightDownColor];
    [self setColorIntensities:offIntensities color:offColor];
    
    int width = matrix.width;
    int height = matrix.height;
    int8_t *bytes = (int8_t *)malloc(width * height * 4);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (x < width / 2 && y < height / 2) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? leftTopColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else if (x < width / 2 && y >= height / 2) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? rightTopColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else if (x >= width / 2 && y < height / 2) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? leftDownColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else if (x >= width / 2 && y >= height / 2) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? rightDownColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            }
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    CGImageRef image = CGBitmapContextCreateImage(c);
    CFRelease(c);
    free(bytes);
    
    ZXImage *zxImage = [[ZXImage alloc] initWithCGImageRef:image];
    
    CFRelease(image);
    return zxImage;
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString topColor:(UIColor *)topColor downColor:(UIColor *)downColor offColor:(UIColor *)offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError *__autoreleasing *)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:codeString format:kBarcodeFormatQRCode width:width height:height error:error];
    if (result) {
        ZXImage* zximage = [self imageWithMatrix:result topColor:topColor.CGColor downColor:downColor.CGColor offColor:offColor.CGColor];
        CGImageRef image = [zximage cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }
}

// 上下两种颜色
- (ZXImage *)imageWithMatrix:(ZXBitMatrix *)matrix topColor:(CGColorRef)topColor downColor:(CGColorRef)downColor  offColor:(CGColorRef)offColor {
    int8_t topColorIntensities[4], downColorIntensities[4], offIntensities[4];
    [self setColorIntensities:downColorIntensities color:downColor];
    [self setColorIntensities:topColorIntensities color:topColor];
    [self setColorIntensities:offIntensities color:offColor];
    
    int width = matrix.width;
    int height = matrix.height;
    int8_t *bytes = (int8_t *)malloc(width * height * 4);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (y < height / 2) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? topColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? downColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            }
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    CGImageRef image = CGBitmapContextCreateImage(c);
    CFRelease(c);
    free(bytes);
    
    ZXImage *zxImage = [[ZXImage alloc] initWithCGImageRef:image];
    
    CFRelease(image);
    return zxImage;
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString RColor:(UIColor *)RColor GColor:(UIColor *)GColor BColor:(UIColor *)BColor offColor:(UIColor *)offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError *__autoreleasing *)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:codeString format:kBarcodeFormatQRCode width:width height:height error:error];
    if (result) {
        ZXImage* zximage = [self imageWithMatrix:result RColor:RColor.CGColor GColor:GColor.CGColor BColor:BColor.CGColor offColor:offColor.CGColor];
        CGImageRef image = [zximage cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }
}

// 三层颜色
- (ZXImage *)imageWithMatrix:(ZXBitMatrix *)matrix RColor:(CGColorRef)RColor GColor:(CGColorRef)GColor BColor:(CGColorRef)BColor  offColor:(CGColorRef)offColor {
    int8_t RColorIntensities[4], GColorIntensities[4], BColorIntensities[4], offIntensities[4];
    [self setColorIntensities:RColorIntensities color:RColor];
    [self setColorIntensities:GColorIntensities color:GColor];
    [self setColorIntensities:BColorIntensities color:BColor];
    [self setColorIntensities:offIntensities color:offColor];
    
    int width = matrix.width;
    int height = matrix.height;
    int8_t *bytes = (int8_t *)malloc(width * height * 4);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (y < height / 4 || y >= (height * 3 / 4)) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? RColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else {
                if (x < width / 4 || x  >= (width * 3 / 4)) {
                    BOOL bit = [matrix getX:x y:y];
                    for (int i = 0; i < 4; i++) {
                        int8_t intensity = bit ? RColorIntensities[i] : offIntensities[i];
                        bytes[y * width * 4 + x * 4 + i] = intensity;
                    }
                } else {
                    if (x < (width / 4) + (width / 8) || x >= (width / 2) + (width / 8) || y < (height / 4) + (height / 8) || y >= (height / 2) + (height / 8)) {
                        BOOL bit = [matrix getX:x y:y];
                        for (int i = 0; i < 4; i++) {
                            int8_t intensity = bit ? GColorIntensities[i] : offIntensities[i];
                            bytes[y * width * 4 + x * 4 + i] = intensity;
                        }
                    } else {
                        BOOL bit = [matrix getX:x y:y];
                        for (int i = 0; i < 4; i++) {
                            int8_t intensity = bit ? BColorIntensities[i] : offIntensities[i];
                            bytes[y * width * 4 + x * 4 + i] = intensity;
                        }
                    }
                }
            }
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    CGImageRef image = CGBitmapContextCreateImage(c);
    CFRelease(c);
    free(bytes);
    
    ZXImage *zxImage = [[ZXImage alloc] initWithCGImageRef:image];
    
    CFRelease(image);
    return zxImage;
}

- (UIImage *) writerWithQRCodeString:(NSString *)codeString AColor:(UIColor *)AColor BColor:(UIColor *)BColor CColor:(UIColor *)CColor DColor:(UIColor *)DColor EColor:(UIColor *)EColor offColor:(UIColor *)offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError *__autoreleasing *)error
{
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding =NSUTF8StringEncoding;
    ZXMultiFormatWriter* writer =[ZXMultiFormatWriter writer];
    ZXBitMatrix* result = [writer encode:codeString format:kBarcodeFormatQRCode width:width height:height error:error];
    if (result) {
        ZXImage* zximage = [self imageWithMatrix:result AColor:AColor.CGColor BColor:BColor.CGColor CColor:CColor.CGColor DColor:DColor.CGColor EColor:EColor.CGColor offColor:offColor.CGColor];
        CGImageRef image = [zximage cgimage];
        return [UIImage imageWithCGImage:image];
    } else {
        return nil;
    }
}

// 三层颜色
- (ZXImage *)imageWithMatrix:(ZXBitMatrix *)matrix AColor:(CGColorRef)AColor BColor:(CGColorRef)BColor CColor:(CGColorRef)CColor DColor:(CGColorRef)DColor EColor:(CGColorRef)EColor offColor:(CGColorRef)offColor {
    int8_t AColorIntensities[4], BColorIntensities[4], CColorIntensities[4], DColorIntensities[4], EColorIntensities[4],offIntensities[4];
    [self setColorIntensities:AColorIntensities color:AColor];
    [self setColorIntensities:BColorIntensities color:BColor];
    [self setColorIntensities:CColorIntensities color:CColor];
    [self setColorIntensities:DColorIntensities color:DColor];
    [self setColorIntensities:EColorIntensities color:EColor];
    [self setColorIntensities:offIntensities color:offColor];
    
    int width = matrix.width;
    int height = matrix.height;
    int8_t *bytes = (int8_t *)malloc(width * height * 4);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            if (y < height / 4 || y >= (height * 3 / 4)) {
                BOOL bit = [matrix getX:x y:y];
                for (int i = 0; i < 4; i++) {
                    int8_t intensity = bit ? AColorIntensities[i] : offIntensities[i];
                    bytes[y * width * 4 + x * 4 + i] = intensity;
                }
            } else {
                if (x < width / 4 || x > (width * 3 / 4)) {
                    BOOL bit = [matrix getX:x y:y];
                    for (int i = 0; i < 4; i++) {
                        int8_t intensity = bit ? AColorIntensities[i] : offIntensities[i];
                        bytes[y * width * 4 + x * 4 + i] = intensity;
                    }
                } else {
                    if (x < y) {
                        if (x < (height - y)) {
                            BOOL bit = [matrix getX:x y:y];
                            for (int i = 0; i < 4; i++) {
                                int8_t intensity = bit ? BColorIntensities[i] : offIntensities[i];
                                bytes[y * width * 4 + x * 4 + i] = intensity;
                            }
                        } else {
                            BOOL bit = [matrix getX:x y:y];
                            for (int i = 0; i < 4; i++) {
                                int8_t intensity = bit ? CColorIntensities[i] : offIntensities[i];
                                bytes[y * width * 4 + x * 4 + i] = intensity;
                            }
                        }
                    } else {
                        if (x < (height - y)) {
                            BOOL bit = [matrix getX:x y:y];
                            for (int i = 0; i < 4; i++) {
                                int8_t intensity = bit ? DColorIntensities[i] : offIntensities[i];
                                bytes[y * width * 4 + x * 4 + i] = intensity;
                            }
                        } else {
                            BOOL bit = [matrix getX:x y:y];
                            for (int i = 0; i < 4; i++) {
                                int8_t intensity = bit ? EColorIntensities[i] : offIntensities[i];
                                bytes[y * width * 4 + x * 4 + i] = intensity;
                            }
                        }
                    }
                }
            }
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CFRelease(colorSpace);
    CGImageRef image = CGBitmapContextCreateImage(c);
    CFRelease(c);
    free(bytes);
    
    ZXImage *zxImage = [[ZXImage alloc] initWithCGImageRef:image];
    
    CFRelease(image);
    return zxImage;
}

@end
