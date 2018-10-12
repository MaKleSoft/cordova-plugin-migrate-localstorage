#import "MigrateLocalStorage.h"

@implementation MigrateLocalStorage

- (BOOL) copyFrom:(NSString*)src to:(NSString*)dest
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // Bail out if source file does not exist
    if (![fileManager fileExistsAtPath:src]) {
        return NO;
    }
    
    // Bail out if dest file exists
    if ([fileManager fileExistsAtPath:dest]) {
        return NO;
    }
    
    // create path to dest
    if (![fileManager createDirectoryAtPath:[dest stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
        return NO;
    }
    
    // copy src to dest
    return [fileManager copyItemAtPath:src toPath:dest error:nil];
}

- (void) migrateLocalStorage
{
    NSError *error;
    
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [cachePaths objectAtIndex:0];
    
    NSArray *cacheDirectoryItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:&error];
//    NSLog(@"%@", cacheDirectoryItems);  // Print directory items to log
    
    NSMutableArray *cacheLocalStorageItems = [NSMutableArray arrayWithCapacity:1000];
    
    // Filter out LocalStorage files from cache and copy to cacheLocalStorageItems
    for(int i = 0; i < cacheDirectoryItems.count; i++){
        if([cacheDirectoryItems[i] rangeOfString:@".localstorage"].location == NSNotFound){

        }else{

            [cacheLocalStorageItems addObject:[cacheDirectoryItems objectAtIndex:i]];
        }
    }
    
    // Migrate UIWebView local storage files to WKWebView. Adapted from:
    // https://github.com/Telerik-Verified-Plugins/WKWebView/blob/master/src/ios/MyMainViewController.m
    
    NSString* appLibraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* original = @"";
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[appLibraryFolder stringByAppendingPathComponent:@"WebKit/LocalStorage/file__0.localstorage"]]) {
        original = [appLibraryFolder stringByAppendingPathComponent:@"Caches"];
    }else{
        return;
    }
    
    NSString* target = [[NSString alloc] initWithString: [appLibraryFolder stringByAppendingPathComponent:@"WebKit"]];
    
#if TARGET_IPHONE_SIMULATOR
    // the simulutor squeezes the bundle id into the path
    NSString* bundleIdentifier = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    target = [target stringByAppendingPathComponent:bundleIdentifier];
#endif

    NSString* wkWebViewStoragePath = [target stringByAppendingPathComponent:@"WebsiteData/LocalStorage/file__0.localstorage"];
    
    target = [target stringByAppendingPathComponent:@"WebsiteData/LocalStorage"];
    
        if (![[NSFileManager defaultManager] fileExistsAtPath:wkWebViewStoragePath]) {
            
            for(int i = 0; i < cacheLocalStorageItems.count; i++){
                
                [self copyFrom:[original stringByAppendingPathComponent:cacheLocalStorageItems[i]] to:[target stringByAppendingPathComponent:cacheLocalStorageItems[i]]];
                
            }
            
        }
    
}

- (void)pluginInitialize
{
    [self migrateLocalStorage];
}


@end
