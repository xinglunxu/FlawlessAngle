//
//  TotalScore.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/25/15.
//  Copyright © 2015 xinglunxu. All rights reserved.
//

#import "TotalScore.h"
int score;

@implementation TotalScore

-(id)initWithSize:(CGSize)size
{
    self = [super initWithFontNamed:@"ChalkboardSE-Regular"];
    self.position = CGPointMake(size.width/2, size.height*0.8);
    score = 0;
    self.text = [NSString stringWithFormat:@"score: %i",score];
    self.fontSize = 35;
    return self;
}
-(void)increaseScore:(int)add
{
    score += add;
    SKAction* addedToTotal = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode* node, CGFloat elapsedTime)
                              {
                                  self.text = [NSString stringWithFormat:@"score: %i",score];
                              }];
    SKAction* delay = [SKAction waitForDuration:0.8];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects: delay,addedToTotal, nil]];
    [self runAction:sequence];
    
}

-(void)resetscore
{
    score = 0;
    self.text = [NSString stringWithFormat:@"score: %i",score];
}

-(int)getScore
{
    return score;
}

@end
