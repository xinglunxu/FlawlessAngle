//
//  Instruction.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/27/15.
//  Copyright © 2015 xinglunxu. All rights reserved.
//





#import "Instruction.h"
CGSize s;
SKLabelNode* first;
SKLabelNode* second;
SKLabelNode* third;
float fontSize;
@implementation Instruction
-(id)initWithSize:(CGSize)size{
    self = [super init];
    s = size;
    fontSize = s.width/45;
    [self setupInstructions];
    return self;
}

-(void)setupInstructions
{
    first = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Regular"];
    first.fontSize = fontSize;
    first.position = CGPointMake(s.width/2, s.height*3/4);
    first.text = @"1.Use finger to draw a line to intercept the moving direction of the white square";
    second = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Regular"];
    second.fontSize = fontSize;
    second.position = CGPointMake(s.width/2, s.height*2/4);
    second.text = @"2. The drawed line will reflect the white square when it is hit.";
    third = [[SKLabelNode alloc] initWithFontNamed:@"ChalkboardSE-Regular"];
    third.fontSize = fontSize;
    third.position = CGPointMake(s.width/2, s.height*1/4);
    third.text = @"3. To score, make the white square hit the black bar on the edge by doing the previous steps.";
    [self addChild:first];
    [self addChild:second];
    [self addChild:third];
}

-(void)displayInstructions
{
    first.alpha = 1;
    second.alpha = 1;
    third.alpha = 1;
}

-(void)hideInstructions
{
    first.alpha = 0;
    second.alpha = 0;
    third.alpha = 0;
}

@end
