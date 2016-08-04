//
//  ViewController.m
//  AWNavigationMenuItem
//
//  Created by Abe Wang on 2016/7/25.
//  Copyright © 2016 Abe Wang. All rights reserved.
//

#import "ViewController.h"
#import "AWNavigationMenuItem.h"

@interface ViewController ()
<AWNavigationMenuItemDataSource, AWNavigationMenuItemDelegate>
@property (nonatomic, strong) AWNavigationMenuItem *menuItem;
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];

	self.titles = @[@"Title 1", @"Title 2", @"Title 3", @"Title 4", @"Title 5"];
	
	self.menuItem = [[AWNavigationMenuItem alloc] init];
	self.menuItem.dataSource = self;
	self.menuItem.delegate = self;
	
	self.contentLabel = [[UILabel alloc] init];
	self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.contentLabel.textAlignment = NSTextAlignmentCenter;
	self.contentLabel.font = [UIFont boldSystemFontOfSize:40.f];
	self.contentLabel.text = self.titles[0];
	[self.view addSubview:self.contentLabel];
	
	[NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_contentLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentLabel)]];
	[NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentLabel)]];
}

#pragma mark - AWNavigationMenuItemDataSource

- (NSUInteger)numberOfRowsInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem
{
	return self.titles.count;
}

- (NSString *)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem menuTitleAtIndex:(NSUInteger)inIndex
{
	return (inIndex % 2) == 1 ? self.titles[inIndex] : nil;
}

- (NSAttributedString *)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem attributedMenuTitleAtIndex:(NSUInteger)inIndex
{
	NSMutableAttributedString *attributedMenu = [[NSMutableAttributedString alloc] initWithString:self.titles[inIndex] attributes:@{NSForegroundColorAttributeName: [UIColor purpleColor], NSFontAttributeName: [UIFont systemFontOfSize:20.f]}];
	[attributedMenu setAttributes:@{NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: [UIFont systemFontOfSize:26.f]} range:NSMakeRange(self.titles[inIndex].length - 1, 1)];
	
	NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
	attachment.image = [UIImage imageNamed:@"icon_pressure"];
	attachment.bounds = CGRectMake(0.f, 0.f, 20.f, 20.f);
	
	NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
	[attributedMenu insertAttributedString:attachmentString atIndex:5];
	
	return (inIndex % 2) == 0 ? attributedMenu : nil;
}

- (CGRect)maskViewFrameInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem
{
	return self.view.frame;
}

#pragma mark - AWNavigationMenuItemDelegate

- (void)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem selectionDidChange:(NSUInteger)inIndex
{
	self.contentLabel.text = self.titles[inIndex];
}

- (void)navigationMenuItemWillUnfold:(AWNavigationMenuItem *)inMenuItem
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)navigationMenuItemWillFold:(AWNavigationMenuItem *)inMenuItem
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
