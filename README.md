# AWNavigationMenuItem
Navigation Menu for iOS.
AWNavigationMenuItem now also supports attributed titles!

<img src="http://abewang.myftp.org/AWNavigationMenuItem.gif" width="277" height="494"/>
<img src="http://abewang.myftp.org/AWNavigationMenuItem2.gif" width="277" height="494"/>

# Requirements
This project works on iOS 8+ and requires ARC to build.

# Usage
You can add the `AWNavigationMenuItem.h` and `AWNavigationMenuItem.m` source files to your project.

1. Include AWNavigationMenuItem header. `#import "AWNavigationMenuItem.h"`
2. Initialize AWNavigationMenuItem.

```objc
AWNavigationMenuItem *menuItem = [[AWNavigationMenuItem alloc] init];
menuItem.dataSource = self;
menuItem.delegate = self;
```

3. Implement the delegate and dataSource.

```objc
#pragma mark - AWNavigationMenuItemDataSource
- (NSUInteger)numberOfRowsInNavigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem
{
// Required
// Return menu item count
}
- (CGRect)maskViewFrameInNavigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem
{
// Required
// Return mask view frame
}
- (nullable NSString *)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem menuTitleAtIndex:(NSUInteger)inIndex
{
// Optional
// Return menu title
}
- (nullable NSAttributedString *)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem attributedMenuTitleAtIndex:(NSUInteger)inIndex
{
// Optional
// Return attributed menu title
}

#pragma mark - AWNavigationMenuItemDelegate
- (void)navigationMenuItem:(nonnull AWNavigationMenuItem *)inMenuItem selectionDidChange:(NSUInteger)inIndex
{
// Optional
}
- (void)navigationMenuItemWillUnfold:(nonnull AWNavigationMenuItem *)inMenuItem
{
// Optional
}
- (void)navigationMenuItemWillFold:(nonnull AWNavigationMenuItem *)inMenuItem
{
// Optional
}
```

# License
This project is under MIT License.
