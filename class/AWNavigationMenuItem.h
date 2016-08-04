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
- (NSUInteger)numberOfRowsInNavigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem;
- (CGRect)maskViewFrameInNavigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem;
@optional
- (nullable NSString *)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem menuTitleAtIndex:(NSUInteger)inIndex;
- (nullable NSAttributedString *)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem attributedMenuTitleAtIndex:(NSUInteger)inIndex;
@end

@protocol AWNavigationMenuItemDelegate <NSObject>
@optional
- (void)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem selectionDidChange:(NSUInteger)inIndex;
- (void)navigationMenuItemWillUnfold:(nonnull AWNavigationMenuItem *)inMenuItem;
- (void)navigationMenuItemWillFold:(nonnull AWNavigationMenuItem *)inMenuItem;
@end

@interface AWNavigationMenuItem : NSObject
- (void)reloadMenu;
@property (nonatomic, weak, nullable) UIViewController<AWNavigationMenuItemDataSource> *dataSource;
@property (nonatomic, weak, nullable) UIViewController<AWNavigationMenuItemDelegate> *delegate;
@property (nonatomic, readonly, nullable) UIButton *menuNavigationBarButton;
@property (nonatomic, assign) BOOL isExpanded;
@end
