//
//  AWNavigationMenuItem.m
//  AWNavigationMenuItem
//
//  Created by Abe Wang on 2016/7/25.
//  Copyright © 2016 Abe Wang. All rights reserved.
//

#import "AWNavigationMenuItem.h"

#pragma mark - AWNavigationMenuItemCell

@interface AWNavigationMenuItemCell : UITableViewCell
@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIImageView *selectImageView;
@property (nonatomic, assign) BOOL isSelected;
@end

@implementation AWNavigationMenuItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.preservesSuperviewLayoutMargins = NO;
		self.separatorInset = UIEdgeInsetsZero;
		self.layoutMargins = UIEdgeInsetsZero;
		
		self.titleLabel = [[UILabel alloc] init];
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
		self.titleLabel.textColor = [UIColor grayColor];
		self.titleLabel.font = [UIFont systemFontOfSize:16.f];
		[self.contentView addSubview:self.titleLabel];
		
		self.selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_choose"]];
		self.selectImageView.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:self.selectImageView];
		
		[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f].active = YES;
		[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f].active = YES;
		[NSLayoutConstraint constraintWithItem:self.selectImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f].active = YES;
		[NSLayoutConstraint constraintWithItem:self.selectImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.f constant:-6.f].active = YES;

		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_titleLabel]-(>=15)-[_selectImageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_titleLabel, _selectImageView)]];
	}
	return self;
}

- (void)setIsSelected:(BOOL)isSelected
{
	_isSelected = isSelected;
	self.selectImageView.hidden = !isSelected;
	self.titleLabel.textColor = isSelected ? [UIColor blackColor] : [UIColor grayColor];
}

@end

#pragma mark - AWNavigationMenuItem

static NSTimeInterval const kNavigationMenuAnimationDuration = 0.25;
static NSString *const kMenuCellIdentifier = @"kMenuCellIdentifier";
static CGFloat const kNavigationButtonHeight = 48.f;
static CGFloat const kMenuTopSpacing = 76.f;

@interface AWNavigationMenuItem ()
<UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate>
@property (nonatomic, strong, nullable) NSLayoutConstraint *menuHeightConstraint;
@property (nonatomic, strong, nullable) UIButton *menuNavigationBarButton;
@property (nonatomic, strong, nullable) UILabel *navigationTitle;
@property (nonatomic, strong, nullable) UIImageView *arrowImage;
@property (nonatomic, strong, nullable) UITableView *menuTableView;
@property (nonatomic, strong, nullable) UIView *maskView;
@property (nonatomic, strong, nullable) NSDictionary *defaultTitleAttributes;
@property (nonatomic, strong, nullable) NSDictionary *defaultMenuItemAttributes;
@property (nonatomic, strong, nullable) NSDictionary *defaultSelectedMenuItemAttributes;
@property (nonatomic, assign) NSUInteger lastSelectedIndex;
@property (nonatomic, assign) CGFloat menuHeight;
@end

@implementation AWNavigationMenuItem

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
		
		UITapGestureRecognizer *tapMaskViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggle)];
		tapMaskViewGestureRecognizer.delegate = self;
		
		self.maskView = [[UIView alloc] init];
		self.maskView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5f];
		[self.maskView addGestureRecognizer:tapMaskViewGestureRecognizer];
		
		self.menuTableView = [[UITableView alloc] init];
		self.menuTableView.translatesAutoresizingMaskIntoConstraints = NO;
		self.menuTableView.backgroundColor = [UIColor clearColor];
		self.menuTableView.rowHeight = kNavigationButtonHeight;
		self.menuTableView.layer.cornerRadius = 5.f;
		self.menuTableView.scrollEnabled = NO;
		self.menuTableView.dataSource = self;
		self.menuTableView.delegate = self;
		[self.maskView addSubview:self.menuTableView];
		
		if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
			self.menuTableView.cellLayoutMarginsFollowReadableWidth = NO;
		}
		
		[self.menuTableView registerClass:[AWNavigationMenuItemCell class] forCellReuseIdentifier:kMenuCellIdentifier];
		
		[NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(<=10)-[_menuTableView]-(<=10)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_menuTableView)]];
		[NSLayoutConstraint constraintWithItem:self.menuTableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeTop multiplier:1.f constant:kMenuTopSpacing].active = YES;
		
		self.menuHeightConstraint = [NSLayoutConstraint constraintWithItem:self.menuTableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:0.f];
		self.menuHeightConstraint.active = YES;
		
		self.defaultTitleAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont boldSystemFontOfSize:17.f]};
		self.defaultMenuItemAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor], NSFontAttributeName: [UIFont systemFontOfSize:16.f]};
		self.defaultSelectedMenuItemAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:16.f]};
	}
	return self;
}

#pragma mark - Instance Methods

- (void)reloadMenu
{
	[self.menuTableView reloadData];
}

- (void)installNavigationTitleView
{
	NSAttributedString *attributedTitle;
	if ([self.dataSource respondsToSelector:@selector(navigationMenuItem:attributedMenuTitleAtIndex:)]) {
		attributedTitle = [self.dataSource navigationMenuItem:self attributedMenuTitleAtIndex:0];
	}
	if (!attributedTitle && [self.dataSource respondsToSelector:@selector(navigationMenuItem:menuTitleAtIndex:)]) {
		attributedTitle = [[NSAttributedString alloc] initWithString:[self.dataSource navigationMenuItem:self menuTitleAtIndex:0] ?: @"" attributes:self.defaultTitleAttributes];
	}
	
	self.navigationTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), 44.0)];
	self.navigationTitle.attributedText = attributedTitle;
	
	self.arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_filter_normal"]];
	
	self.menuNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.menuNavigationBarButton addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
	[self.menuNavigationBarButton addTarget:self action:@selector(highlight) forControlEvents:UIControlEventTouchDown];
	[self.menuNavigationBarButton addTarget:self action:@selector(cancelHighlight) forControlEvents:UIControlEventTouchCancel];
	[self.menuNavigationBarButton addTarget:self action:@selector(cancelHighlight) forControlEvents:UIControlEventTouchDragOutside];
	
	[self resizeNavigationBarButton];
}

- (void)resizeNavigationBarButton
{
	[self.navigationTitle sizeToFit];
	
	self.menuNavigationBarButton.frame = CGRectMake(0.f, 0.f, CGRectGetWidth(self.navigationTitle.frame) + CGRectGetWidth(self.arrowImage.frame) + 25.f, CGRectGetHeight(self.navigationTitle.frame));
	
	[self.menuNavigationBarButton addSubview:self.navigationTitle];
	self.arrowImage.frame = CGRectMake(CGRectGetMaxX(self.navigationTitle.frame) + 5.0, (CGRectGetHeight(self.menuNavigationBarButton.frame) - CGRectGetHeight(self.arrowImage.frame)) / 2.f, CGRectGetWidth(self.arrowImage.frame), CGRectGetHeight(self.arrowImage.frame));
	[self.menuNavigationBarButton addSubview:self.arrowImage];
	
	// Do this trick to let button be center of navigation bar
	self.dataSource.navigationItem.titleView = nil;
	self.dataSource.navigationItem.titleView = self.menuNavigationBarButton;
}

- (void)cancelHighlight
{
	self.navigationTitle.alpha = 1.f;
	self.arrowImage.image = [UIImage imageNamed:@"navi_filter_normal"];
}

- (void)highlight
{
	self.navigationTitle.alpha = 0.5f;
	self.arrowImage.image = [UIImage imageNamed:@"navi_filter_focus"];
}

- (void)toggle
{
	NSUInteger count = [self.dataSource numberOfRowsInNavigationMenuItem:self];
	if (self.lastSelectedIndex >= count) {
		return;
	}
	
	[self cancelHighlight];
	
	if (self.isExpanded && [self.maskView superview]) {
		[self rotateArrowOn:NO];
		if ([self.delegate respondsToSelector:@selector(navigationMenuItemWillFold:)]) {
			[self.delegate navigationMenuItemWillFold:self];
		}
		
		__weak typeof(self) weakSelf = self;
		[UIView animateWithDuration:kNavigationMenuAnimationDuration animations:^{
			weakSelf.arrowImage.image = [UIImage imageNamed:@"navi_filter_normal"];
			weakSelf.menuHeightConstraint.constant = 0.f;
			weakSelf.maskView.alpha = 0.f;
			[weakSelf.maskView layoutIfNeeded];
		} completion:^(BOOL finished) {
			[weakSelf.maskView removeFromSuperview];
		}];
	}
	else if (![self.maskView superview]) {
		[self rotateArrowOn:YES];
		if ([self.delegate respondsToSelector:@selector(navigationMenuItemWillUnfold:)]) {
			[self.delegate navigationMenuItemWillUnfold:self];
		}
		
		self.maskView.alpha = 0.f;
		[self.dataSource.view addSubview:self.maskView];
		
		self.menuHeightConstraint.constant = 0.f;
		[self.maskView layoutIfNeeded];
		
		__weak typeof(self) weakSelf = self;
		[UIView animateWithDuration:kNavigationMenuAnimationDuration animations:^{
			weakSelf.arrowImage.image = [UIImage imageNamed:@"navi_filter_focus"];
			weakSelf.menuHeightConstraint.constant = self.menuHeight;
			weakSelf.maskView.alpha = 1.f;
			[weakSelf.maskView layoutIfNeeded];
		} completion:nil];
	}
	
	_isExpanded = !self.isExpanded;
}

- (void)rotateArrowOn:(BOOL)on
{
	CATransform3D fromZRotation = on ? CATransform3DMakeRotation(0.f, 0.f, 0.f, 1.f) : CATransform3DMakeRotation(179.f * M_PI / 180.f, 0.f, 0.f, 1.f);
	CATransform3D toZRotation = on ? CATransform3DMakeRotation(180.f * M_PI / 180.f, 0.f, 0.f, 1.f) : CATransform3DMakeRotation(0.f, 0.f, 0.f, 1.f);
	CATransform3D transformation = CATransform3DIdentity;
	CATransform3D xRotation = CATransform3DMakeRotation(0.f, 1.f, 0.f, 0.f);
	CATransform3D yRotation = CATransform3DMakeRotation(0.f, 0.f, 1.f, 0.f);
	
	CATransform3D xyConcat = CATransform3DConcat(xRotation, yRotation);
	CATransform3D toXyzConcat = CATransform3DConcat(xyConcat, toZRotation);
	CATransform3D fromXyzConcat = CATransform3DConcat(xyConcat, fromZRotation);
	CATransform3D fromConcat = CATransform3DConcat(fromXyzConcat, transformation);
	CATransform3D toConcat = CATransform3DConcat(toXyzConcat, transformation);
	
	CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform"];
	rotation.fromValue = [NSValue valueWithCATransform3D:fromConcat];
	rotation.toValue = [NSValue valueWithCATransform3D:toConcat];
	rotation.duration = 0.25f;
	rotation.fillMode = kCAFillModeForwards;
	rotation.removedOnCompletion = NO;
	[self.arrowImage.layer addAnimation:rotation forKey:@"animation"];
}

- (void)updateMaskLayout
{
	self.maskView.frame = [self.dataSource maskViewFrameInNavigationMenuItem:self];
	self.menuHeight = kNavigationButtonHeight * [self.dataSource numberOfRowsInNavigationMenuItem:self];
	self.menuHeightConstraint.constant = self.menuHeight;
	[self.maskView layoutIfNeeded];
}

#pragma mark - UITableView delegate & dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource numberOfRowsInNavigationMenuItem:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AWNavigationMenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuCellIdentifier forIndexPath:indexPath];
	cell.isSelected = (indexPath.row == self.lastSelectedIndex);
	
	NSAttributedString *attributedMenuTitle;
	if ([self.dataSource respondsToSelector:@selector(navigationMenuItem:attributedMenuTitleAtIndex:)]) {
		attributedMenuTitle = [self.dataSource navigationMenuItem:self attributedMenuTitleAtIndex:indexPath.row];
	}
	if (!attributedMenuTitle && [self.dataSource respondsToSelector:@selector(navigationMenuItem:menuTitleAtIndex:)]) {
		attributedMenuTitle = [[NSAttributedString alloc] initWithString:[self.dataSource navigationMenuItem:self menuTitleAtIndex:indexPath.row] ?: @"" attributes:cell.isSelected ? self.defaultSelectedMenuItemAttributes : self.defaultMenuItemAttributes];
	}
	cell.titleLabel.attributedText = attributedMenuTitle;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row >= [self.dataSource numberOfRowsInNavigationMenuItem:self]) {
		return;
	}
	
	self.lastSelectedIndex = indexPath.row;
	[self.menuTableView reloadData];
	
	if ([self.delegate respondsToSelector:@selector(navigationMenuItem:selectionDidChange:)]) {
		[self.delegate navigationMenuItem:self selectionDidChange:self.lastSelectedIndex];
	}
	
	__weak typeof(self) weakSelf = self;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		NSAttributedString *attributedTitle;
		if ([weakSelf.dataSource respondsToSelector:@selector(navigationMenuItem:attributedMenuTitleAtIndex:)]) {
			attributedTitle = [weakSelf.dataSource navigationMenuItem:weakSelf attributedMenuTitleAtIndex:weakSelf.lastSelectedIndex];
		}
		if (!attributedTitle && [weakSelf.dataSource respondsToSelector:@selector(navigationMenuItem:menuTitleAtIndex:)]) {
			attributedTitle = [[NSAttributedString alloc] initWithString:[weakSelf.dataSource navigationMenuItem:weakSelf menuTitleAtIndex:weakSelf.lastSelectedIndex] ?: @"" attributes:weakSelf.defaultTitleAttributes];
		}
		weakSelf.navigationTitle.attributedText = attributedTitle;
		[weakSelf resizeNavigationBarButton];
		[weakSelf toggle];
	});
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	return (touch.view == self.maskView);
}

#pragma mark - Notifications

- (void)orientationDidChange:(NSNotification *)inNotification
{
	self.isExpanded = NO;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self updateMaskLayout];
	});
}

#pragma mark - Properties

- (void)setDataSource:(UIViewController<AWNavigationMenuItemDataSource> *)inDataSource
{
	_dataSource = inDataSource;
	
	if (!self.menuNavigationBarButton) {
		[self installNavigationTitleView];
	}
	
	[self updateMaskLayout];
}

- (void)setIsExpanded:(BOOL)isExpanded
{
	if (_isExpanded == isExpanded) {
		return;
	}
	[self toggle];
}

@end
