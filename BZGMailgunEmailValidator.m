#import "BZGMailgunEmailValidator.h"

@interface BZGMailgunEmailValidator ()

@property (strong, nonatomic) NSString *publicKey;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation BZGMailgunEmailValidator

+ (BZGMailgunEmailValidator *)validatorWithPublicKey:(NSString *)publicKey
{
    BZGMailgunEmailValidator *validator = [[BZGMailgunEmailValidator alloc] init];
    if (validator) {
        validator.publicKey = publicKey;
        validator.performsFallbackValidation = YES;
        validator.operationQueue = [[NSOperationQueue alloc] init];
        validator.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return validator;
}

- (void)validateEmailAddress:(NSString *)address
                     success:(void (^)(BOOL isValid, NSString *didYouMean))success
                     failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(success);

    NSURL *baseURL = [NSURL URLWithString:@"https://api.mailgun.net/v2/"];

    NSURL *url = [NSURL URLWithString:@"address/validate" relativeToURL:baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?address=%@&api_key=%@", address, self.publicKey]];
    [request setURL:url];
    [request setTimeoutInterval:3];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.operationQueue
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
                                   // regex from http://www.regular-expressions.info/email.html
                                   NSString *pattern = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";
                                   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
                                   if (error) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (failure) {
                                               failure(error);
                                           }
                                       });
                                   } else {
                                       BOOL isValid = [predicate evaluateWithObject:address];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           success(isValid, nil);
                                       });
                                   }
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (failure) {
                                           failure(connectionError);
                                       }
                                   });
                               }
                           }];
}

@end
