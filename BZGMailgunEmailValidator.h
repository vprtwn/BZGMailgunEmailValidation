#import <Foundation/Foundation.h>

@interface BZGMailgunEmailValidator : NSObject

/**
 * A Boolean value indicating whether the validator performs fallback validation if Mailgun validation fails.
 * @discussion Fallback validation is performed locally using a regular expression. The default value for this property is YES.
 */
@property (assign, nonatomic) BOOL performsFallbackValidation;

/**
 * Returns a validator instance initialized with the given public key and operation queue.
 * @param publicKey Your Mailgun public API key.
 * @param operationQueue The operation queue to which blocks are dispatched when the request completes or fails.
 * @return A BZGMailgunEmailValidator instance.
 */
+ (BZGMailgunEmailValidator *)validatorWithPublicKey:(NSString *)publicKey operationQueue:(NSOperationQueue *)operationQueue;

/**
 * Loads a validation request for the given email address. Executes the success block if the request succeeds and the failure block if the request fails.
 * @param address The email address to validate.
 * @param success The block to execute when the request succeeds (required).
 * @param failure The block to execute when the request fails (optional).
 */
- (void)validateEmailAddress:(NSString *)address
                     success:(void (^)(BOOL isValid, NSString *didYouMean))success
                     failure:(void (^)(NSError *error))failure;
@end
