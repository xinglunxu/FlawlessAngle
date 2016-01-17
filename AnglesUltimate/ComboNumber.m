//
//  ComboNumber.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/25/15.
//  Copyright © 2015 xinglunxu. All rights reserved.
//

#import "ComboNumber.h"
CGPoint origin;
@implementation ComboNumber

-(id)initWithSize:(CGSize)size
{
    self = [super initWithFontNamed:@"ChalkboardSE-Regular"];
    origin = CGPointMake(size.width/2, size.height/2);
    self.position = origin;
    return self;
}
//25~20
-(void)jumpNumber:(int)n color:(UIColor*)c size:(int)s time:(float)t decrease:(float)d
{
    self.alpha = 1;
    self.fontColor = c;
    self.fontSize = s;
    self.text = [NSString stringWithFormat:@"COMBO! +%i",n];
    SKAction* getSmaller = [SKAction customActionWithDuration:t actionBlock:^(SKNode* node, CGFloat elapsedTime)
                            {
                                if(self.fontSize <= s*4/5){return;}
                                self.fontSize -= d;
                            }];
    [self runAction:getSmaller];
}

-(void)combo:(int)n
{
    if(n<=10)
    {
        [self jumpNumber:n color:[UIColor whiteColor] size:25 time:2 decrease:0.1];
    }
    
    else if(n<=30)
    {
        [self jumpNumber:n color:[UIColor greenColor] size:35 time:3 decrease:0.2];
        self.alpha = 0.8;
    }
    else if(n<=100)
    {
        [self jumpNumber:n color:[UIColor orangeColor] size:45 time:4 decrease:0.3];
        self.alpha = 0.6;
    }
    else{
        [self jumpNumber:n color:[UIColor redColor] size:60 time:5 decrease:0.4];
        self.alpha = 0.5;
    }
}

-(void)comboLost:(CGPoint)p
{
    SKAction* moveP = [SKAction moveTo:p duration:1];
    SKAction* addedToTotal = [SKAction customActionWithDuration:1 actionBlock:^(SKNode* node, CGFloat elapsedTime)
                            {
                                if(self.fontSize <= 1){return;}
                                self.fontSize -= 0.2;
                            }];
    SKAction* group = [SKAction group:[NSArray arrayWithObjects:moveP,addedToTotal, nil]];
    SKAction* reset = [SKAction customActionWithDuration:2 actionBlock:^(SKNode* node, CGFloat elapsedTime)
                              {
                                  self.alpha = 0;
                                  self.position = origin;
                              }];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:group,reset, nil]];
    [self runAction:sequence];
}


@end
