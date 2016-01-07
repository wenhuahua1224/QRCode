//
//  YZQRCode.h
//  YZQRCode
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZXImage.h"
#import "ZXBitMatrix.h"

typedef enum {
    /** Aztec 2D barcode format. */
    YZQRcodeFormatAztec,
    /** CODABAR 1D format. */
    YZQRcodeFormatCodabar,
    /** Code 39 1D format. */
    YZQRcodeFormatCode39,
    /** Code 93 1D format. */
    YZQRcodeFormatCode93,
    /** Code 128 1D format. */
    YZQRcodeFormatCode128,
    /** Data Matrix 2D barcode format. */
    YZQRcodeFormatDataMatrix,
    /** EAN-8 1D format. */
    YZQRcodeFormatEan8,
    /** EAN-13 1D format. */
    YZQRcodeFormatEan13,
    /** ITF (Interleaved Two of Five) 1D format. */
    YZQRcodeFormatITF,
    /** MaxiCode 2D barcode format. */
    YZQRcodeFormatMaxiCode,
    /** PDF417 format. */
    YZQRcodeFormatPDF417,
    /** QR Code 2D barcode format. */
    YZQRcodeFormatQRCode,
    /** RSS 14 */
    YZQRcodeFormatRSS14,
    /** RSS EXPANDED */
    YZQRcodeFormatRSSExpanded,
    /** UPC-A 1D format. */
    YZQRcodeFormatUPCA,
    /** UPC-E 1D format. */
    YZQRcodeFormatUPCE,
    /** UPC/EAN extension format. Not a stand-alone format. */
    YZQRcodeFormatUPCEANExtension
} YZQRcodeFormat;

@interface YZQRCode : NSObject

+ (YZQRCode *) sharedYZQRCode;

/*
 * 生成带图标的二维码图片
 * image 二维码图片
 * icon  图标
 * iconSize 图标的宽＊高
 */
- (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize;

/*
 * 生成带图标的二维码图片
 * image 二维码图片
 * icon  图标
 * scale  图片是二维码图片的几分之几（scale > 0 ）
 */
- (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale;

/*
 * 识别相册二维码码 (仅限于NSString)
 * image 二维码图片
 */
- (NSString *) readerWithQRCodeImage:(UIImage *) image error:(NSError **) error;

/*
 * 生成二维码和条形码 (黑白二维码)
 * codeString 文本信息
 * yzQRCodeformat 编码格式
 * width 图片的宽
 * height 图片的高
 * error 错误信息
 */
- (UIImage *) writerWithQRCodeString:(NSString *) codeString format:(YZQRcodeFormat) yzQRCodeformat imageWidth:(CGFloat) width imageHeight:(CGFloat) height error:(NSError **) error;

/*
 * 生成二维码和条形码
 * codeString 文本信息
 * yzQRCodeformat 编码格式
 * width 图片的宽
 * height 图片的高
 * imageColor 二维码的颜色
 * backgroundColor 二维码图片的背景颜色
 * error 错误信息
 */
- (UIImage *) writerWithQRCodeString:(NSString *) codeString format:(YZQRcodeFormat) yzQRCodeformat imageWidth:(CGFloat) width imageHeight:(CGFloat) height QRCodeImageColor:(UIColor *) imageColor BackgroundColor:(UIColor *) backgroundColor error:(NSError **) error;

/*
 * 生成二维码(四个角四种色二维码)
 * codeString 文本信息
 * leftTopColor 左上颜色
 * rightTopColor 右上颜色
 * leftDownColor 左下颜色
 * rightDownColor 右下颜色
 * width 图片的宽度
 * height 图片的高度
 * offColor 图片底色
 * error 错误信息
 */

- (UIImage *) writerWithQRCodeString:(NSString *) codeString leftTopColor:(UIColor *) leftTopColor rightTopColor:(UIColor *) rightTopColor leftDownColor:(UIColor *) leftDownColor rightDownColor:(UIColor *) rightDownColor offColor:(UIColor *) offColor imageWidth:(CGFloat) width imageHeight:(CGFloat) height error:(NSError **) error;

/*
 * 生成二维码(上下两种色二维码)
 * codeString 文本信息
 * topColor 上部颜色
 * downColor 下部颜色
 * offColor 底色
 * width 宽度
 * height 高度
 * error 错误信息
 */
- (UIImage *) writerWithQRCodeString:(NSString *)codeString topColor:(UIColor *) topColor downColor:(UIColor *) downColor offColor:(UIColor *) offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError **)error;

/*
 * 生成二维码(三种颜色二维码)
 * codeString 文本信息
 * RColor 第一层颜色
 * BColor 第三层颜色
 * GColor 第二层颜色
 * offColor 底色
 * width 宽度
 * height 高度
 * error 错误信息
 */
- (UIImage *) writerWithQRCodeString:(NSString *)codeString RColor:(UIColor *) RColor GColor:(UIColor *) GColor BColor:(UIColor *) BColor offColor:(UIColor *) offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError **)error;

/*
 * 生成二维码(三种颜色二维码)
 * codeString 文本信息
 * AColor 第一种颜色
 * BColor 第二种颜色
 * CColor 第三种颜色
 * DColor 第四种颜色
 * EColor 第五种颜色
 * offColor 底色
 * width 宽度
 * height 高度
 * error 错误信息
 */

- (UIImage *) writerWithQRCodeString:(NSString *)codeString AColor:(UIColor *)AColor BColor:(UIColor *)BColor CColor:(UIColor *)CColor DColor:(UIColor *) DColor EColor:(UIColor *) EColor  offColor:(UIColor *)offColor imageWidth:(CGFloat)width imageHeight:(CGFloat)height error:(NSError **)error;

@end
