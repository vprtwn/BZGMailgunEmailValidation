#import "BZGMailgunEmailValidator.h"

@interface BZGMailgunEmailValidator ()

@property (strong, nonatomic) NSString *publicKey;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation BZGMailgunEmailValidator

+ (BZGMailgunEmailValidator *)validatorWithPublicKey:(NSString *)publicKey operationQueue:(NSOperationQueue *)operationQueue
{
    BZGMailgunEmailValidator *validator = [[BZGMailgunEmailValidator alloc] init];
    if (validator) {
        validator.publicKey = publicKey;
        validator.operationQueue = operationQueue;
        validator.performsFallbackValidation = YES;
    }
    return validator;
}

- (void)validateEmailAddress:(NSString *)address
                     success:(void (^)(BOOL isValid, NSString *didYouMean))success
                     failure:(void (^)(NSError *error))failure
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.mailgun.net/v2/"];
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;

    NSURL *url = [NSURL URLWithString:@"address/validate"
                        relativeToURL:baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?address=%@&api_key=%@", address, self.publicKey]];
    [request setURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *json = nil;
                               NSError *error = nil;

                               if (!connectionError){
                                   json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                   if (json) {
                                       BOOL isValid = [[json valueForKey:@"is_valid"] boolValue];

                                       NSString *didYouMean = nil;
                                       if (![[json valueForKey:@"did_you_mean"] isKindOfClass:[NSNull class]]) {
                                           didYouMean = [json valueForKey:@"did_you_mean"];
                                       }

                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(isValid, didYouMean);
                                       });
                                       return;
                                   }
                               }

                               if (self.performsFallbackValidation) {
                                   // from http://www.regular-expressions.info/email.html
                                   NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
                                   NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                                                     options:NSRegularExpressionCaseInsensitive
                                                                                                       error:&error];
                                   NSUInteger matches = [regex matchesInString:address options:0 range:NSMakeRange(0, address.length)];
                                   if (error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           failure(error);
                                       });
                                   } else {
                                       BOOL isValid = matches != 0;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(isValid, nil);
                                       });
                                   }
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       failure(connectionError);
                                   });
                               }
                           }];
}

@end
