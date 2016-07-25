# AWNavigationMenuItem
Navigation Menu for iOS.

# License
This project is under MIT License.

# Usage
To initialize the AWNavigationMenuItem

```objc
AWNavigationMenuItem *menuItem = [[AWNavigationMenuItem alloc] init];
menuItem.dataSource = self;
menuItem.delegate = self;
```

and implement the delegate and dataSource
```objc
#pragma mark - AWNavigationMenuItemDataSource
- (NSUInteger)numberOfRowsInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem
{
// Return item count
}
- (NSString *)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem menuTitleAtIndex:(NSUInteger)inIndex
{
// Return menu title
}
- (CGRect)maskViewFrameInNavigationMenuItem:(AWNavigationMenuItem *)inMenuItem
{
// Return mask rect 
}

#pragma mark - AWNavigationMenuItemDelegate
- (void)navigationMenuItem:(AWNavigationMenuItem *)inMenuItem selectionDidChange:(NSUInteger)inIndex
{
// Optional
}
- (void)navigationMenuItemWillUnfold:(AWNavigationMenuItem *)inMenuItem
{
// Optional
}
- (void)navigationMenuItemWillFold:(AWNavigationMenuItem *)inMenuItem
{
// Optional
}
```