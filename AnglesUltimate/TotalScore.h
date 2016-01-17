//
//  TotalScore.h
//  AnglesUltimate
//
//  Created by xinglunxu on 9/25/15.
//  Copyright © 2015 xinglunxu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TotalScore : SKLabelNode
-(id)initWithSize:(CGSize)size;
-(void)increaseScore:(int)add;
-(void)resetscore;
-(int)getScore;
@end
