//
//  Levenshtein_Distance_Algorithm.h
//  bus
//
//  Created by mac_hero on 12/7/6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Levenshtein)

// calculate the distance between two string treating them each as a
// single word
- (float) compareWithWord: (NSString *) stringB;

// return the minimum of a, b and c
- (int) smallestOf: (int) a andOf: (int) b andOf: (int) c;

@end


