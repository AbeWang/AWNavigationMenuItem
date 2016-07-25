//
//  AWNavigationMenuItem.h
//  AWNavigationMenuItem
//
//  Created by Abe Wang on 2016/7/25.
//  Copyright © 2016 Abe Wang. All rights reserved.
//

@import UIKit;
@class AWNavigationMenuItem;

@protocol AWNavigationMenuItemDataSource <NSObject>
@required
- (NSUInteger)numberOfRowsInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem;
- (NSString *)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem menuTitleAtIndex:(NSUInteger)inIndex;
- (CGRect)maskViewFrameInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem;
@optional
- (NSString *)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem menuSubtitleAtIndex:(NSUInteger)inIndex;
@end

@protocol AWNavigationMenuItemDelegate <NSObject>
@optional
- (void)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem selectionDidChange:(NSUInteger)inIndex;
- (BOOL)navigationMenuItemShouldUnFold:(AWNavigationMenuItem *)inMenuItem;
- (void)navigationMenuItemWillUnfold:(AWNavigationMenuItem *)inMenuItem;
- (void)navigationMenuItemWillFold:(AWNavigationMenuItem *)inMenuItem;
@end

@interface AWNavigationMenuItem : NSObject
- (void)reloadMenu;
@property (nonatomic, weak) UIViewController<AWNavigationMenuItemDataSource> *dataSource;
@property (nonatomic, weak) UIViewController<AWNavigationMenuItemDelegate> *delegate;
@property (nonatomic, readonly) UIButton *menuNavigationBarButton;
@property (nonatomic, assign) BOOL isExpanded;
@end
