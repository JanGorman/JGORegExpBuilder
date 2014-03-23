//
//  ViewController.m
//  Demo
//
//  Created by Jan Gorman on 23/03/14.
//  Copyright (c) 2014 Jan Gorman. All rights reserved.
//

#import "ViewController.h"
#import "JGORegExpBuilder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    JGORegExpBuilder *builder = RegExpBuilder().startOfLine().exactly(1).of(@"p");

    builder.test(@"padasd");
}

@end
