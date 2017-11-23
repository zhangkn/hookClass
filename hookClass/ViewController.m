//
//  ViewController.m
//  hookClass
//
//  Created by devzkn on 02/11/2017.
//  Copyright © 2017 Weiliu. All rights reserved.
//

#import "ViewController.h"
#import "Meow.h"
@interface ViewController (){
    
    NSString * _password;
}

@end

@implementation ViewController


+ (void)load{
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [Meow initWithClassName:@"ViewController"];

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self->_password = @"喵咕咪~"; // directly access, undectectable in BigBang or ANYMethodLog

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
