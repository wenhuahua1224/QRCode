//
//  ViewController.m
//  YZQRCode
//
//  Created by apple on 1/6/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "ViewController.h"
#import "YZQRCode.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
- (IBAction)generateBtnClick:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)recognitionBtnClick:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)generateBtnClick:(id)sender {
    NSError *error = nil;
//    UIImage* image = [[YZQRCode sharedYZQRCode] writerWithQRCodeString:@"xxxxxx" RColor:[UIColor redColor] GColor:[UIColor blueColor] BColor:[UIColor blackColor] offColor:[UIColor whiteColor] imageWidth:self.iconView.frame.size.width imageHeight:self.iconView.frame.size.height error:&error];
//    UIImage* image1 = [[YZQRCode sharedYZQRCode] writerWithQRCodeString:@"xxxxx" AColor:[UIColor colorWithRed:108/255.0f green:49/255.0f blue:124/255.0f alpha:1.0] BColor:[UIColor colorWithRed:26/255.0f green:155/255.0f blue:205/255.0f alpha:1.0] CColor:[UIColor colorWithRed:252/255.0f green:102/255.0f blue:33/255.0f alpha:1.0] DColor:[UIColor colorWithRed:102/255.0f green:154/255.0f blue:26/255.0f alpha:1.0] EColor:[UIColor colorWithRed:239/255.0f green:27/255.0f blue:171/255.0f alpha:1.0] offColor:[UIColor whiteColor] imageWidth:280 imageHeight:280 error:&error];
    UIImage *image2 = [[YZQRCode sharedYZQRCode] writerWithQRCodeString:@"xxx" format:YZQRcodeFormatQRCode imageWidth:280 imageHeight:280 error:&error];
    if (error == nil) {
        self.iconView.image = [[YZQRCode sharedYZQRCode] addIconToQRCodeImage:image2 withIcon:[UIImage imageNamed:@"203656742.jpg"] withIconSize:CGSizeMake(28, 28)];
        self.titleLabel.text = @"成功";
    } else {
        NSLog(@"error : %@", [error localizedDescription]);
        self.titleLabel.text = [NSString stringWithFormat:@"失败:%@", [error localizedDescription]];
    }
}

- (IBAction)recognitionBtnClick:(id)sender {
    NSError *error = nil;
    if (error == nil) {
       NSString* titleText = [[YZQRCode sharedYZQRCode] readerWithQRCodeImage:[UIImage imageNamed:@"53630630.jpg"] error:&error];
        self.titleLabel.text = [NSString stringWithFormat:@"成功:%@", titleText];
    } else {
        NSLog(@"error: %@", [error localizedDescription]);
        self.titleLabel.text = [NSString stringWithFormat:@"失败:%@", [error localizedDescription]];
    }
}
@end
