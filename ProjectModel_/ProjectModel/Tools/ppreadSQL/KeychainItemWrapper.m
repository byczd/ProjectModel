/*
     File: KeychainItemWrapper.m 
 Abstract: 
 Objective-C wrapper for accessing a single keychain item.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
*/ 

#import "KeychainItemWrapper.h"
#import <Security/Security.h>

/*

These are the default constants and their respective types,
available for the kSecClassGenericPassword Keychain Item class:

kSecAttrAccessGroup			-		CFStringRef
kSecAttrCreationDate		-		CFDateRef
kSecAttrModificationDate    -		CFDateRef
kSecAttrDescription			-		CFStringRef
kSecAttrComment				-		CFStringRef
kSecAttrCreator				-		CFNumberRef
kSecAttrType                -		CFNumberRef
kSecAttrLabel				-		CFStringRef
kSecAttrIsInvisible			-		CFBooleanRef
kSecAttrIsNegative			-		CFBooleanRef
kSecAttrAccount				-		CFStringRef
kSecAttrService				-		CFStringRef
kSecAttrGeneric				-		CFDataRef
 
See the header file Security/SecItem.h for more details.

*/

@interface KeychainItemWrapper (PrivateMethods)
/*
The decision behind the following two methods (secItemFormatToDictionary and dictionaryToSecItemFormat) was
to encapsulate the transition between what the detail view controller was expecting (NSString *) and what the
Keychain API expects as a validly constructed container class.
*/
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;

// Updates the item in the keychain, or adds it if it doesn't exist.
- (BOOL)writeToKeychain;

@end

@implementation KeychainItemWrapper

@synthesize keychainItemData, genericPasswordQuery;

- (id)initWithIdentifier: (NSString *)serviceName withAccount:(NSString *)userName andDelFlag:(BOOL)delFlag accessGroup:(NSString *) accessGroup
{
    if (self = [super init])
    {
        // Begin Keychain search setup. The genericPasswordQuery leverages the special user
        // defined attribute kSecAttrGeneric to distinguish itself between other generic Keychain
        // items which may be included by the same application.
        genericPasswordQuery = [[NSMutableDictionary alloc] init];
		[genericPasswordQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
        //kSecClass种类：kSecClassGenericPassword//一般密码
        [genericPasswordQuery setObject:serviceName forKey:(id)kSecAttrService];
        //kSecAttrService位置
//        [genericPasswordQuery setObject:nil forKey:(id)kSecAttrGeneric];
        //kSecAttrGeneric//用户自定义内容
        [genericPasswordQuery setObject:userName forKey:(id)kSecAttrAccount];
        //kSecAttrAccount--账户//kSecValueData--密码
		if (accessGroup != nil)
		{
#if TARGET_IPHONE_SIMULATOR
#else			
			[genericPasswordQuery setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
		}
        if (delFlag){
             OSStatus state = SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery, NULL);
            if (state == noErr) {//existthen
                OSStatus deleteState = SecItemDelete((__bridge CFDictionaryRef)genericPasswordQuery);
                debugLog(@"---deletekeychin-%@:%@",serviceName,(deleteState==noErr)?@"Success":@"Fail");
            }
            return self;
        }
		
		// Use the proper search constants, return only the attributes of the first match.
        [genericPasswordQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        //kSecMatchLimit,kSecMatchLimitOne=只返回第一个匹配数据，查询方法使用，还有值kSecMatchLimitAll
        [genericPasswordQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
        //kSecReturnAttributes并设置为yes时，表示查询钥匙串数据的属性，
        
        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];
        NSMutableDictionary *outDictionary = nil;
        //查询是否存在对应serviceName和account的keychain
        if (SecItemCopyMatching((CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr)
        {
            // load the saved data from Keychain.
            self.keychainItemData = [self secItemFormatToDictionary:outDictionary];//存在后续store为update,否则为add
		}
        else
        {
            // Stick these default values into keychain item if nothing found.
            [self resetKeychainItem];
            // Add the generic attribute and the keychain access group.
            [keychainItemData setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
            [keychainItemData setObject:serviceName forKey:(id)kSecAttrService];
            [keychainItemData setObject:userName forKey:(id)kSecAttrAccount];
            [keychainItemData setObject:serviceName forKey:(id)kSecAttrLabel];
//            [keychainItemData setObject:userName forKey:(id)kSecAttrDescription];
            if (accessGroup != nil)
            {
#if TARGET_IPHONE_SIMULATOR
#else
                [keychainItemData setObject:accessGroup forKey:(id)kSecAttrAccessGroup];
#endif
            }
        }
       
		[outDictionary release];
    }
    
	return self;
}

- (void)dealloc
{
    [keychainItemData release];
    [genericPasswordQuery release];
    
	[super dealloc];
}

- (BOOL)setObject:(id)inObject forKey:(id)key 
{
    if (inObject == nil) return NO;
    id currentObject = [keychainItemData objectForKey:key];
    if (![currentObject isEqual:inObject])
    {
        [keychainItemData setObject:inObject forKey:key];
        return [self writeToKeychain];
    }
    else
        return YES;
}

- (id)objectForKey:(id)key
{
    return [keychainItemData objectForKey:key];
}

- (void)resetKeychainItem
{
	OSStatus junk = noErr;
    if (!keychainItemData) 
    {
        self.keychainItemData = [[NSMutableDictionary alloc] init];
    }
    else if (keychainItemData)
    {
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:keychainItemData];
		junk = SecItemDelete((CFDictionaryRef)tempDictionary);
//        if (junk == noErr || junk == errSecItemNotFound){
//            NSLog(@"!!!!!resetKeychainItem-Error:Problem deleting current dictionary.");
//        }
        NSAssert(junk == noErr||junk == errSecItemNotFound, @"!!!!!resetKeychainItem-Error:Problem deleting current dictionary." );
    }
    
    // Default attributes for keychain item.
    [keychainItemData setObject:@"" forKey:(id)kSecAttrAccount];
    [keychainItemData setObject:@"" forKey:(id)kSecAttrLabel];
    [keychainItemData setObject:@"" forKey:(id)kSecAttrDescription];
	// Default data for keychain item.
    [keychainItemData setObject:@"" forKey:(id)kSecValueData];
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for a SecItem.
    
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the Generic Password keychain item class attribute.
    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // Convert the NSString to NSData to meet the requirements for the value type kSecValueData.
	// This is where to store sensitive data that should be encrypted.
    NSString *passwordString = [dictionaryToConvert objectForKey:(id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
    
    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
    // The assumption is that this method will be called with a properly populated dictionary
    // containing all the right key/value pairs for the UI element.
    
    // Create a dictionary to return populated with the attributes and data.
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    
    // Add the proper search key and class attribute.
    [returnDictionary setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [returnDictionary setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    
    // Acquire the password data from the attributes.
    NSData *passwordData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData) == noErr)
    {
        // Remove the search, class, and identifier key/value, we don't need them anymore.
        [returnDictionary removeObjectForKey:(id)kSecReturnData];
        
        // Add the password to the dictionary, converting from NSData to NSString.
        NSString *password = [[[NSString alloc] initWithBytes:[passwordData bytes] length:[passwordData length] 
                                                     encoding:NSUTF8StringEncoding] autorelease];
        [returnDictionary setObject:password forKey:(id)kSecValueData];
    }
    else
    {
        // Don't do anything if nothing is found.
        debugLog(@"!!!!!SecItemCopyMatching-Error:Serious error, no matching item found in the keychain.");
//        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }
    
    [passwordData release];
   
	return returnDictionary;
}

- (BOOL)writeToKeychain
{
    NSDictionary *attributes = NULL;
    NSMutableDictionary *updateItem = NULL;
	OSStatus result;
    
    if (SecItemCopyMatching((CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&attributes) == noErr)
    {
        // First we need the attributes from the Keychain.
        updateItem = [NSMutableDictionary dictionaryWithDictionary:attributes];
        // Second we need to add the appropriate search key/values.
        [updateItem setObject:[genericPasswordQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];
        
        // Lastly, we need to set up the updated attribute list being careful to remove the class.
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:keychainItemData];
        [tempCheck removeObjectForKey:(id)kSecClass];
		
#if TARGET_IPHONE_SIMULATOR
		// Remove the access group if running on the iPhone simulator.
		// 
		// Apps that are built for the simulator aren't signed, so there's no keychain access group
		// for the simulator to check. This means that all apps can see all keychain items when run
		// on the simulator.
		//
		// If a SecItem contains an access group attribute, SecItemAdd and SecItemUpdate on the
		// simulator will return -25243 (errSecNoAccessForItem).
		//
		// The access group attribute will be included in items returned by SecItemCopyMatching,
		// which is why we need to remove it before updating the item.
		[tempCheck removeObjectForKey:(id)kSecAttrAccessGroup];
#endif
        
        // An implicit assumption is that you can only update a single item at a time.
		
        result = SecItemUpdate((CFDictionaryRef)updateItem, (CFDictionaryRef)tempCheck);
        if (result!=noErr) {
            debugLog(@"!!!!!!Couldn't update the Keychain Item.%d" ,(int)result);
        }
//        NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    }
    else
    {
        // No previous item found; add the new one.
        result = SecItemAdd((CFDictionaryRef)[self dictionaryToSecItemFormat:keychainItemData], NULL);
        if (result!=noErr) {
            debugLog(@"!!!!!Couldn't add the Keychain Item.%d", (int)result);
        }
//        NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
//        这个 “SecItemAdd” 方法，绝大部分时间都是执行正确的，但在iOS 8.4.1系统偶尔会添加失败，status的值为: -34018(errSecMissingEntitlement)
//        经过分析，是iOS系统的一个bug，当app频繁的从钥匙串请求数据的时候就会造成这种问题，所以尽量减少对keychain的访问,一个解决办法是:在内存中缓存这个值
    }
    return (result==noErr);
}

@end
