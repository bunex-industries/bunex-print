//
//  imageItem.h
//  ImageKit test
//
//  Created by minibun on 25/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@interface imageItem : NSObject
{
    NSString *path;
    CAKeyframeAnimation * anim;
}


- (NSString *) imageRepresentationType;
- (id) imageRepresentation;
- (NSString *) imageUID;
- (void)setPath:(NSString *)p;
-(void)setAnim:(CAKeyframeAnimation*)a;
-(CAKeyframeAnimation*)anim;
@end
