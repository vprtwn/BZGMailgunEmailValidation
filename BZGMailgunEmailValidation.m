//
// BZGMailgunEmailValidation
//
// https://github.com/benzguo/BZGMailgunEmailValidation
//

#import "BZGMailgunEmailValidation.h"

@implementation BZGMailgunEmailValidation

+ (void)validateEmailAddress:(NSString *)address
                   publicKey:(NSString *)publicKey
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
    url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:@"?address=%@&api_key=%@", address, publicKey]];
    [request setURL:url];

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSDictionary *json = nil;
                               NSError *error = nil;

                               if (!connectionError){
                                   json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                   if (!json) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           failure(error);
                                       });
                                       return;
                                   }

                                   BOOL isValid = [[json valueForKey:@"is_valid"] boolValue];
                                   NSString *didYouMean = [self checkForNull:[json valueForKey:@"did_you_mean"]];

                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       success(isValid, didYouMean);
                                   });

                               } else {
                                   error = connectionError;
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       failure(error);
                                   });
                               }
                           }];
}

+ (id)checkForNull:(id)value
{
    if([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return value;
}

@end
