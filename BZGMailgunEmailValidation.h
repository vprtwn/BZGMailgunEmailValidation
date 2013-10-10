//
// BZGMailgunEmailValidation
//
// https://github.com/benzguo/BZGMailgunEmailValidation
//

#import <Foundation/Foundation.h>

@interface BZGMailgunEmailValidation : NSObject

/**
 Loads a validation request given an email address and a Mailgun public API key.
 Executes the success block if the request succeeds and the failure block if the request fails.
 */
+ (void)validateEmailAddress:(NSString *)address
                   publicKey:(NSString *)publicKey
                     success:(void (^)(BOOL isValid, NSString *didYouMean))success
                     failure:(void (^)(NSError *error))failure;

@end
