// MROperation.m
//
// Copyright (c) 2013 Héctor Marqués
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MROperation.h"


static NSString *const kMROperationLockName = @"me.mrhector.operation.lock";

NSString *const MROperationDidStartNotification = @"me.mrhector.operation.start";
NSString *const MROperationDidFinishNotification = @"me.mrhector.operation.finish";


typedef NS_ENUM(NSInteger, MROperationState) {
    MROperationReadyState     = 1,
    MROperationExecutingState = 2,
    MROperationFinishedState  = 3,
};


#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
typedef UIBackgroundTaskIdentifier MRBackgroundTaskIdentifier;
#else
typedef id MRBackgroundTaskIdentifier;
#endif


@interface MROperation () <MRExecutingOperation>
@property (readwrite, nonatomic) MROperationState state;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, strong) NSError *error;
@property (readwrite, nonatomic) MRBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (readwrite, nonatomic, copy) void (^operationBlock)(id<MRExecutingOperation>);
@end


@implementation MROperation

#pragma mark Private class methods

+ (BOOL)stateTransitionIsValidFrom:(MROperationState const)fromState
                                to:(MROperationState const)toState
                         cancelled:(BOOL const)isCancelled
{
    switch (fromState) {
        case MROperationReadyState:
            switch (toState) {
                case MROperationExecutingState:
                    return YES;
                case MROperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case MROperationExecutingState:
            switch (toState) {
                case MROperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case MROperationFinishedState:
            return NO;
            
        default:
            return YES;
    }
}

+ (NSString *)keyPathFromOperationState:(MROperationState const)state
{
    switch (state) {
        case MROperationReadyState:
            return @"isReady";
        case MROperationExecutingState:
            return @"isExecuting";
        case MROperationFinishedState:
            return @"isFinished";
        default:
            return @"state";
    }
}

#pragma mark Public class methods

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

+ (instancetype)layerOperation:(void (^const)(NSError **))transactionAnimations
{
    return [(MROperation *)[self alloc] initWithBlock:
            ^(id<MRExecutingOperation>const operation) {
                [CATransaction begin];
                NSError *error;
                transactionAnimations(&error);
                CATransaction.completionBlock = ^{
                    [operation finishWithError:error];
                };
                [CATransaction commit];
            }];
}

#endif

#pragma mark Private instance methods

- (void)postNotificationWithName:(NSString *const)name
{
    dispatch_async(self.notificationQueue ?: dispatch_get_main_queue(), ^{
        NSNotificationCenter *const center = NSNotificationCenter.defaultCenter;
        [center postNotificationName:name object:self];
    });
}

#pragma mark Public instance methods

- (instancetype)initWithBlock:(void (^const)(id<MRExecutingOperation>))block
{
    NSParameterAssert(block);
    self = [self init];
    if (!self) {
		return nil;
    }
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kMROperationLockName;
    self.operationBlock = block;
    self.state = MROperationReadyState;
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^const)(MROperation *))success
                              failure:(void (^const)(MROperation *, NSError *error))failure
{
    [self.lock lock];
    __weak __typeof(self) const weakSelf = self;
    [super setCompletionBlock:^ {
        __strong __typeof(weakSelf) const strongSelf = weakSelf;
        strongSelf.completionBlock = nil;
        NSError *const error = strongSelf.error;
        if (error || strongSelf.isCancelled) {
            if (failure) {
                dispatch_async(strongSelf.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                    failure(strongSelf, error);
                });
            }
        } else if (success) {
            dispatch_async(strongSelf.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                success(strongSelf);
            });
        }
    }];
    [self.lock unlock];
}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^const)(void))handler
{
    [self.lock lock];
    if (!self.backgroundTaskIdentifier) {
        UIApplication *const application = UIApplication.sharedApplication;
        __weak __typeof(self) const weakSelf = self;
        self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(weakSelf) const strongSelf = weakSelf;
            if (handler) {
                handler();
            }
            if (strongSelf) {
                [strongSelf cancel];
                [application endBackgroundTask:strongSelf.backgroundTaskIdentifier];
                strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            }
        }];
    }
    [self.lock unlock];
}
#endif

#pragma mark Accessors

- (void)setState:(MROperationState const)toState
{
    [self.lock lock];
    Class const selfClass = self.class;
    BOOL const isCancelled = self.isCancelled;
    if ([selfClass stateTransitionIsValidFrom:self.state to:toState cancelled:isCancelled]) {
        MROperationState fromState = self.state;
        NSString *const fromKey = [selfClass keyPathFromOperationState:fromState];
        NSString *const toKey = [selfClass keyPathFromOperationState:toState];
        [self willChangeValueForKey:toKey];
        [self willChangeValueForKey:fromKey];
        _state = toState;
        [self didChangeValueForKey:fromKey];
        [self didChangeValueForKey:toKey];
    }
    [self.lock unlock];
}

- (void)setOnCancelBlock:(void (^const)(id<MRExecutingOperation>))block
{
    [self.lock lock];
    [self willChangeValueForKey:@"onCancelBlock"];
    if (block) {
        __weak __typeof(self) const weakSelf = self;
        _onCancelBlock = ^(id<MRExecutingOperation>const operation) {
            __strong __typeof(weakSelf) const strongSelf = weakSelf;
            strongSelf.onCancelBlock = nil;
            dispatch_async(strongSelf.onCancelCallbackQueue ?: dispatch_get_main_queue(), ^{
                block(strongSelf);
            });
        };
    } else {
        _onCancelBlock = nil;
    }
    [self didChangeValueForKey:@"onCancelBlock"];
    [self.lock unlock];
}

- (void)setSuccessCallbackQueue:(dispatch_queue_t const)successCallbackQueue
{
    [self.lock lock];
    [self willChangeValueForKey:@"successCallbackQueue"];
    if (successCallbackQueue != _successCallbackQueue) {
        if (_successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_successCallbackQueue);
#endif
            _successCallbackQueue = NULL;
        }
        if (successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(successCallbackQueue);
#endif
            _successCallbackQueue = successCallbackQueue;
        }
    }
    [self didChangeValueForKey:@"successCallbackQueue"];
    [self.lock unlock];
}

- (void)setFailureCallbackQueue:(dispatch_queue_t const)failureCallbackQueue
{
    [self.lock lock];
    [self willChangeValueForKey:@"failureCallbackQueue"];
    if (failureCallbackQueue != _failureCallbackQueue) {
        if (_failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_failureCallbackQueue);
#endif
            _failureCallbackQueue = NULL;
        }
        if (failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(failureCallbackQueue);
#endif
            _failureCallbackQueue = failureCallbackQueue;
        }
    }
    [self didChangeValueForKey:@"failureCallbackQueue"];
    [self.lock unlock];
}

- (void)setOnCancelCallbackQueue:(dispatch_queue_t const)onCancelCallbackQueue
{
    [self.lock lock];
    [self willChangeValueForKey:@"onCancelCallbackQueue"];
    if (onCancelCallbackQueue != _onCancelCallbackQueue) {
        if (_onCancelCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_onCancelCallbackQueue);
#endif
            _onCancelCallbackQueue = NULL;
        }
        if (onCancelCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(onCancelCallbackQueue);
#endif
            _onCancelCallbackQueue = onCancelCallbackQueue;
        }
    }
    [self didChangeValueForKey:@"onCancelCallbackQueue"];
    [self.lock unlock];
}

- (void)setNotificationQueue:(dispatch_queue_t const)notificationQueue
{
    [self.lock lock];
    [self willChangeValueForKey:@"notificationQueue"];
    if (notificationQueue != _notificationQueue) {
        if (_notificationQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_release(_notificationQueue);
#endif
            _notificationQueue = NULL;
        }
        if (notificationQueue) {
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(notificationQueue);
#endif
            _notificationQueue = notificationQueue;
        }
    }
    [self didChangeValueForKey:@"notificationQueue"];
    [self.lock unlock];
}

#pragma mark - MRExecutingOperation

- (void)finishWithError:(NSError *const)error
{
    [self.lock lock];
    if (error) {
        self.error = error;
    }
    self.state = MROperationFinishedState;
    [self.lock unlock];
    [self postNotificationWithName:MROperationDidFinishNotification];
}

#pragma mark - NSOperation

- (void)setCompletionBlock:(void (^const)(void))block
{
    [self.lock lock];
    if (block) {
        __weak __typeof(self) const weakSelf = self;
        [super setCompletionBlock:^ {
            __strong __typeof(weakSelf) const strongSelf = weakSelf;
            strongSelf.completionBlock = nil;
            block();
        }];
    } else {
        [super setCompletionBlock:nil];
    }
    [self.lock unlock];
}

- (BOOL)isReady
{
    return self.state == MROperationReadyState && [super isReady];
}

- (BOOL)isExecuting
{
    return self.state == MROperationExecutingState;
}

- (BOOL)isFinished
{
    return self.state == MROperationFinishedState;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    [self.lock lock];
    if (!self.isCancelled && self.isReady) {
        self.state = MROperationExecutingState;
        void (^const block)(id<MRExecutingOperation>) = self.operationBlock;
        [self.lock unlock];
        if (block) {
            block(self);
            [self postNotificationWithName:MROperationDidStartNotification];
        }
    } else {
        [self.lock unlock];
    }
}

- (void)cancel
{
    [self.lock lock];
    if (!self.isFinished && !self.isCancelled) {
        MRErrorBuilder *const builder =
        [MRErrorBuilder builderWithDomain:NSCocoaErrorDomain code:NSUserCancelledError];
        self.error = builder.error;
        [super cancel];
        void (^const block)(id<MRExecutingOperation>) = self.onCancelBlock;
        [self.lock unlock];
        if (block) {
            block(self);
        }
    } else {
        [self.lock unlock];
    }
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, state: %@, cancelled: %@>"
            , NSStringFromClass(self.class)
            , self
            , [self.class keyPathFromOperationState:self.state]
            , (self.isCancelled ? @"YES" : @"NO")];
}

- (void)dealloc
{
    if (_successCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_successCallbackQueue);
#endif
        _successCallbackQueue = NULL;
    }
    if (_failureCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_failureCallbackQueue);
#endif
        _failureCallbackQueue = NULL;
    }
    if (_onCancelCallbackQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_onCancelCallbackQueue);
#endif
        _onCancelCallbackQueue = NULL;
    }
    if (_notificationQueue) {
#if !OS_OBJECT_USE_OBJC
        dispatch_release(_notificationQueue);
#endif
        _notificationQueue = NULL;
    }
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    if (_backgroundTaskIdentifier) {
        UIApplication *const application = UIApplication.sharedApplication;
        [application endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
}

@end
