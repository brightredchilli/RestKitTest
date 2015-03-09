#import "RKTest.h"

#import <RestKit.h>
#import <Nocilla.h>

NSString * const kBaseURL = @"http://www.foo.com";
static AFHTTPClient *client = nil;

@interface Foo : NSObject
@property (nonatomic, strong) NSString *value;
@end
@implementation Foo
@end

@interface Bar : NSObject
@property (nonatomic, strong) NSString *value;
@end
@implementation Bar
@end

@implementation RKTest

+ (void)initialize {
    [[LSNocilla sharedInstance] start];
    stubRequest(@"GET", [kBaseURL stringByAppendingString:@"/*"].regex)
    .andReturn(200)
    .withHeaders(@{@"Content-Type": @"application/json"})
    .withBody(@"{\"value\":\"foo\"}");


    // initialize
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    RKObjectManager *manager = [[RKObjectManager alloc] initWithHTTPClient:client];

    NSIndexSet *successfulStatusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    // set up foo response descriptor
    RKObjectMapping *fooMapping = [RKObjectMapping mappingForClass:[Foo class]];
    [fooMapping addAttributeMappingsFromDictionary:@{@"value" : @"value"}];
    RKResponseDescriptor *fooDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:fooMapping
                                                                                       method:RKRequestMethodGET
                                                                                  pathPattern:@"/foo/"
                                                                                      keyPath:nil
                                                                                  statusCodes:successfulStatusCodes];
    [manager addResponseDescriptor:fooDescriptor];

    // set up bar response descriptor
    RKObjectMapping *barMapping = [RKObjectMapping mappingForClass:[Bar class]];
    [barMapping addAttributeMappingsFromDictionary:@{@"value" : @"value"}];
    RKResponseDescriptor *barDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:barMapping
                                                                                       method:RKRequestMethodGET
                                                                                  pathPattern:@"/bar/"
                                                                                      keyPath:nil
                                                                                  statusCodes:successfulStatusCodes];
    [manager addResponseDescriptor:barDescriptor];

    // set up bar route
    RKRoute *routeGet = [RKRoute routeWithClass:[Bar class] pathPattern:@"/bar/" method:RKRequestMethodGET];
    [manager.router.routeSet addRoute:routeGet];
    [RKObjectManager setSharedManager:manager];
}



- (void)makeFooCall {
    NSURL *fooURL = [NSURL URLWithString:@"foo/" relativeToURL:client.baseURL];
    NSURLRequest *fooRequest = [NSURLRequest requestWithURL:fooURL];
    RKObjectRequestOperation *operation =
    [[RKObjectManager sharedManager] objectRequestOperationWithRequest:fooRequest
                                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                   NSAssert([[mappingResult firstObject] isKindOfClass:[Foo class]], @"Must be Foo");
                                                               } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                   NSAssert(NO, @"Should not fail");
                                                               }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

- (void)makeBarCall {
    NSURL *barURL = [NSURL URLWithString:@"bar/" relativeToURL:client.baseURL];
    NSURLRequest *barRequest = [NSURLRequest requestWithURL:barURL];
    RKObjectRequestOperation *operation =
    [[RKObjectManager sharedManager] objectRequestOperationWithRequest:barRequest
                                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                   NSAssert([[mappingResult firstObject] isKindOfClass:[Bar class]], @"Must be Bar");
                                                               } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                   NSAssert(NO, @"Should not fail");
                                                               }];
    [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation];
}

- (void)makeVeryUnsafeBarCall {
    [[RKObjectManager sharedManager] getObject:[[Bar alloc] init]
                                          path:nil
                                    parameters:nil
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           NSAssert([[mappingResult firstObject] isKindOfClass:[Bar class]], @"Must be Bar");
                                       }
                                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           NSAssert(NO, @"Should not fail");
                                       }];
}

- (void)runTests {
    for (int i = 0 ; i < 4000; i++)
    {
        [self makeFooCall];
        [self makeBarCall];
//        [self makeVeryUnsafeBarCall];
    }
}

@end
