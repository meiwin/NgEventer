//
//  NgEventerTests.m
//  NgEventerTests
//
//  Created by Meiwin Fu on 11/10/15.
//  Copyright © 2015 blockthirty. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NgEventer.h"

@interface NgEventerTests : XCTestCase
@property (nonatomic, strong) XCTestExpectation   * test1Expectation;
@property (nonatomic, strong) XCTestExpectation   * test2Expectation;
@end

@implementation NgEventerTests

#pragma mark Setup/Tear down
- (void)setUp {
  [super setUp];
}

- (void)tearDown {

  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

#pragma mark Tests
- (void)testObserver {

  NgEventer * eventer = [[NgEventer alloc] init];
  
  XCTestExpectation * e = [self expectationWithDescription:@"Event /test1"];
  self.test1Expectation = e;
  
  [[eventer eventNamed:@"/test1"] addObserver:self];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [eventer send:@"/test1" data:nil error:nil];
  });

  [self waitForExpectationsWithTimeout:.5f handler:^(NSError * _Nullable error) {
    self.test1Expectation = nil;
  }];
}
- (void)testObserverInBackground {
  
  NgEventer * eventer = [[NgEventer alloc] init];
  
  XCTestExpectation * e = [self expectationWithDescription:@"Event /test1"];
  self.test1Expectation = e;
  
  [[eventer eventNamed:@"/test1"] addObserverInBackground:self];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [eventer send:@"/test1" data:nil error:nil];
  });
  
  [self waitForExpectationsWithTimeout:.5f handler:^(NSError * _Nullable error) {
    self.test1Expectation = nil;
  }];
}
- (void)testObserverWithSelector {

  NgEventer * eventer = [[NgEventer alloc] init];

  XCTestExpectation * e1 = [self expectationWithDescription:@"Event /test1"];
  XCTestExpectation * e2 = [self expectationWithDescription:@"Event /test2"];
  
  self.test1Expectation = e1;
  self.test2Expectation = e2;
  
  [[eventer eventNamed:@"/test1"] addObserver:self action:@selector(test1Event:)];
  [[eventer eventNamed:@"/test2"] addObserver:self action:@selector(eventer:test2Event:)];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [eventer send:@"/test1" data:nil error:nil];
    [eventer send:@"/test2" data:nil error:nil];
  });

  [self waitForExpectationsWithTimeout:.5f handler:^(NSError * _Nullable error) {
    self.test1Expectation = nil;
    self.test2Expectation = nil;
  }];
}
- (void)testObserverWithSelectorInBackground {
  
  NgEventer * eventer = [[NgEventer alloc] init];
  
  XCTestExpectation * e1 = [self expectationWithDescription:@"Event /test1"];
  XCTestExpectation * e2 = [self expectationWithDescription:@"Event /test2"];
  
  self.test1Expectation = e1;
  self.test2Expectation = e2;
  
  [[eventer eventNamed:@"/test1"] addObserverInBackground:self action:@selector(test1Event:)];
  [[eventer eventNamed:@"/test2"] addObserverInBackground:self action:@selector(eventer:test2Event:)];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [eventer send:@"/test1" data:nil error:nil];
    [eventer send:@"/test2" data:nil error:nil];
  });
  
  [self waitForExpectationsWithTimeout:.5f handler:^(NSError * _Nullable error) {
    self.test1Expectation = nil;
    self.test2Expectation = nil;
  }];
}
- (void)testRemoveObserver {
  
  NgEventer * eventer = [[NgEventer alloc] init];
  
  dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  
  [[eventer eventNamed:@"/test1"] addObserver:self];
  [[eventer eventNamed:@"/test1"] addObserver:self action:@selector(shouldNotTest1:)];
  [[eventer eventNamed:@"/test1"] removeObserver:self];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [eventer send:@"/test1" data:nil error:nil];
  });

  dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
}
- (void)testPromise {

  NgEventer * eventer = [[NgEventer alloc] init];

  XCTestExpectation * e1 = [self expectationWithDescription:@"/test1"];
  self.test1Expectation = e1;
  
  [[eventer performPromisedBlock:^(id<NgEventerEventPromiseCallback> callback) {
  
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      [callback send:@"/test1" data:nil error:nil];
    });
    
  }] handle:^(NSString * name, id data, NSError * error) {

    [self.test1Expectation fulfill];
    
  }];
  
  [self waitForExpectationsWithTimeout:.5f handler:nil];
}
- (void)testPromiseInBackground {
  
  NgEventer * eventer = [[NgEventer alloc] init];
  
  XCTestExpectation * e1 = [self expectationWithDescription:@"/test1"];
  self.test1Expectation = e1;
  
  [[eventer performPromisedBlock:^(id<NgEventerEventPromiseCallback> callback) {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      [callback send:@"/test1" data:nil error:nil];
    });
    
  }] handleInBackground:^(NSString * name, id data, NSError * error) {
    
    [self.test1Expectation fulfill];
    
  }];
  
  [self waitForExpectationsWithTimeout:.5f handler:nil];
}
- (void)testPromise2 {
  
}
- (void)testCancel {
  
  NgEventer * eventer = [[NgEventer alloc] init];

  dispatch_semaphore_t sema = dispatch_semaphore_create(0);
  
  [[[eventer performPromisedBlock:^(id<NgEventerEventPromiseCallback> callback) {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
      [callback send:@"/test1" data:nil error:nil];
    });
    
  }] handle:^(NSString * name, id data, NSError * error) {
    
    XCTAssertFalse(@"Should not be called as performWithPromise was cancelled.");
    dispatch_semaphore_signal(sema);
    
  }] cancel];
  
  dispatch_semaphore_wait(sema, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
}

#pragma mark Events
- (void)eventer:(NgEventer *)eventer didFireEvent:(NgEvent *)event {

  if (self.test1Expectation || self.test2Expectation) {
    if ([event.name isEqual:@"/test1"]) {
      [self.test1Expectation fulfill];
    } else if ([event.name isEqual:@"/test2"]) {
      [self.test2Expectation fulfill];
    }
  } else {
    XCTAssertFalse(@"Should not be called as observer was removed.");
  }
}
- (void)test1Event:(NgEvent *)event {
  [self.test1Expectation fulfill];
}
- (void)eventer:(NgEventer *)eventer test2Event:(NgEvent *)event {
  [self.test2Expectation fulfill];
}
- (void)shouldNotTest1:(NgEvent *)event {
  XCTAssertFalse(@"Should not be called as observer was removed.");
}
@end
