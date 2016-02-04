//
//  HttpData.h
//  Birdy2
//
//  Created by veso on 2/2/16.
//  Copyright © 2016 veso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpData : NSObject

-(void) getFrom: (NSString*) urlStr
        headers: (NSDictionary*) headersDict
withCompletionHandler: (void(^)(NSDictionary*, NSError*)) completionHandler;

-(void) postAt: (NSString*) urlStr
      withBody: (NSDictionary*) bodyDict
       headers: (NSDictionary*) headersDict
andCompletionHandler: (void(^)(NSDictionary*, NSError*)) completionHandler;

-(void) putAt: (NSString*) urlStr
      withBody: (NSDictionary*) bodyDict
       headers: (NSDictionary*) headersDict
andCompletionHandler: (void(^)(NSDictionary*, NSError*)) completionHandler;

+(HttpData*)httpData;

@end
