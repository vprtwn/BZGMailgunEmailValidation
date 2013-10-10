# BZGMailgunEmailValidation

A simple objective-C wrapper for the Mailgun email validation API.

```objective-c
[BZGMailgunEmailValidation validateEmailAddress:address
                                      publicKey:YOUR_MAILGUN_PUBLIC_KEY
                                        success:^(BOOL isValid, NSString *didYouMean) {
                                            // :)
                                        } failure:^(NSError *error) {
                                            // :(
                                        }];
```