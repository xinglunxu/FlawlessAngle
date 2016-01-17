//
//  BlackHole.h
//  AnglesUltimate
//
//  Created by xinglunxu on 9/22/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Ball.h"

@interface BlackHole : SKSpriteNode

-(void)pullBall:(Ball *)ball;
-(void)pullParticle:(SKEmitterNode*)SKNode;
@end
