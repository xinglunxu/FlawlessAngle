//
//  BlackHole.m
//  AnglesUltimate
//
//  Created by xinglunxu on 9/22/15.
//  Copyright (c) 2015 xinglunxu. All rights reserved.
//

#import "BlackHole.h"
#import "Ball.h"
@import Foundation;

const float PULLTIME = 2;
const float PULLSPEED = 20;

const uint32_t ballBitMask_ = 0x1;
const uint32_t barBitMask_ = 0x1<<2;
const uint32_t lineBitMask_ = 0x1<<1;
const uint32_t blackHoleBitMask_ = 0x1<<3;
@implementation BlackHole

-(id)initWithImageNamed:(NSString *)name
{
    self = [super initWithImageNamed:name];
    [self runAction:[SKAction rotateByAngle:1000 duration:200]];
    return self;
}


-(void)pullBall:(Ball *)ball
{
    ball.physicsBody.contactTestBitMask = blackHoleBitMask_;
    CGVector v = [self normalize:ball.position];
    float vectorX = v.dx*PULLSPEED;
    float vectorY = v.dy*PULLSPEED;
    NSLog(@"x: %f  y: %f", vectorX, vectorY);
    [ball removeAllActions];
    [ball runAction:[ball getBallMovingAction:1]];
    SKAction* pulled = [SKAction moveByX:vectorX y:vectorY duration:PULLTIME];
    SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:pulled, nil]];
    [ball runAction:sequence];
    [self selfRemove:ball];
}

-(void)selfRemove:(Ball *)ball
{
    SKAction* back = [ball returnPreviousAction];
    SKAction *selfRemoveAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        self.physicsBody.categoryBitMask = 0;
        [self removeFromParent];
        [ball runAction:back];
        ball.physicsBody.contactTestBitMask = barBitMask_ | lineBitMask_ | blackHoleBitMask_;
    }];
    SKAction *delayAction = [SKAction waitForDuration:2];
    SKAction *sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction, selfRemoveAction, nil]];
    [self runAction:sequence];
}

-(float)getDistance:(CGPoint)p
{
    float xDist = p.x - self.position.x;
    float yDist = p.y - self.position.y;
    float dist = sqrtf((xDist*xDist)+(yDist*yDist));
    return dist;
}

-(CGVector)normalize:(CGPoint)p
{
    float d = [self getDistance:p];
    float xDist = self.position.x - p.x;
    float yDist = self.position.y - p.y;
    return CGVectorMake(xDist/d, yDist/d);
}

-(void)pullParticle:(SKEmitterNode *)SKENode
{
    NSOperatingSystemVersion NV;
    NV.majorVersion = 9;
    NV.minorVersion = 0;
    NV.patchVersion = 0;
    
    if([[NSProcessInfo processInfo]isOperatingSystemAtLeastVersion:NV]){return;}
    SKENode.particleAction = [SKAction moveTo:self.position duration:1];
    SKAction *cancelParticleAction = [SKAction customActionWithDuration:0.0 actionBlock:^(SKNode* node, CGFloat elapsedTime){
        SKENode.particleAction = nil;
    }];
    SKAction *delayAction = [SKAction waitForDuration:1.8];
    SKAction* sequence = [SKAction sequence:[NSArray arrayWithObjects:delayAction,cancelParticleAction, nil]];
    [self runAction:sequence];
    

}

@end
