# BZGMailgunEmailValidation

A simple objective-C wrapper for the Mailgun email validation API.

```objective-c
BZGMailgunEmailValidator *validator = 
    [BZGMailgunEmailValidator validatorWithPublicKey:YOUR_PUBLIC_KEY 
                                      operationQueue:queue];

[validator validateEmailAddress:self.emailFieldCell.textField.text
                        success:^(BOOL isValid, NSString *didYouMean) {
                        // Validation succeeded
                      } failure:^(NSError *error) {
                        // Validation failed
                      }];
```

By default, a BZGMailgunEmailValidator instance performs fallback regex-based validation if Mailgun validation fails. 
Set `performsFallbackValidation` to `NO` if you'd prefer to handle this case yourself.

### Installation
If you're using Cocoapods, simply add `pod 'BZGMailgunEmailValidation'` to your `Podfile`. 

Otherwise, add `BZGMailgunEmailValidator.h` and `BZGMailgunEmailValidator.m` to your project.

### References
http://blog.mailgun.com/post/free-email-validation-api-for-web-forms/

http://documentation.mailgun.com/api-email-validation.html

http://www.regular-expressions.info/email.html

https://wiki.mozilla.org/TLD_List
