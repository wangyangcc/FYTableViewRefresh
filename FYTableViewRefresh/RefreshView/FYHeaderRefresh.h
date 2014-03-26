//
//  FYHeaderRefresh.h
//  FYTableViewRefresh
//
//  Created by wang yangyang on 14-3-25.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYHeaderRefresh : UIControl

/* The designated initializer
 * This initializes a CKRefreshControl with a default height and width.
 * Once assigned to a UITableViewController, the frame of the control is managed automatically.
 * When a user has pulled-to-refresh, the CKRefreshControl fires its UIControlEventValueChanged event.
 */
- (id)init;

@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

// This 'Tint Color' will set the text color and spinner color
@property (nonatomic, retain) UIColor *tintColor UI_APPEARANCE_SELECTOR; // Default = 0.5 gray, 1.0 alpha
@property (nonatomic, retain) NSAttributedString *attributedTitle UI_APPEARANCE_SELECTOR;

// May be used to indicate to the refreshControl that an external event has initiated the refresh action
- (void)beginRefreshing;
// Must be explicitly called when the refreshing has completed
- (void)endRefreshing;

@end
