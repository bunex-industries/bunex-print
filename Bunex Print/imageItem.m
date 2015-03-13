//
//  imageItem.m
//  ImageKit test
//
//  Created by minibun on 25/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import "imageItem.h"

@implementation imageItem


- (NSString *) imageRepresentationType
{
    if ([[path pathExtension] isEqualToString:@"MOV"] || [[path pathExtension] isEqualToString:@"mov"])
    {
        return IKImageBrowserQTMoviePathRepresentationType;
    }
    return IKImageBrowserPathRepresentationType;
}

- (id) imageRepresentation
{
    return path;
}

- (NSString *) imageUID
{
    return path;
}

- (void)setPath:(NSString *)p
{
    if(p != path)
    {
        path = p;
    }
}

-(void)setAnim:(CAKeyframeAnimation*)a
{
    anim = a;
}
-(CAKeyframeAnimation*)anim
{
    return anim;
}

@end
