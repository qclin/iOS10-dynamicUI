//
//  Header.h
//  DynamicField
//
//  Created by Qiao Lin on 2/19/17.
//  Copyright © 2017 Qiao Lin. All rights reserved.
//

#ifndef Header_h
#define Header_h

@import UIKit;

#if DEBUG
@interface UIDynamicAnimator (DebuggingOnly)
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;
@end
#endif

#endif /* Header_h */
