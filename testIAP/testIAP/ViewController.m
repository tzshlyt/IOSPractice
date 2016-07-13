//
//  ViewController.m
//  testIAP
//
//  Created by lan on 16/7/12.
//  Copyright © 2016年 lan. All rights reserved.
//

#import "ViewController.h"
#import <StoreKit/StoreKit.h>

NSString *const kProductIDPro = @"com.testIAP.pro";
NSString *const kProcuctIDAdvPro = @"com.testIAP.advPro";

@interface ViewController ()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *products;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
}

- (IBAction)payClick:(id)sender {
    NSLog(@"%s", __func__);
    
    if ([SKPaymentQueue canMakePayments]) {
        
        NSSet *productsID = [NSSet setWithArray:@[kProductIDPro, kProcuctIDAdvPro]];
        
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productsID];
        request.delegate = self;
        [request start];
        
    }else {
        NSLog(@"不允许内购");
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    
    NSLog(@"products: %@", myProduct);
    if (myProduct.count <= 0) {
        NSLog(@"无法获取产品，购买失败");
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)requestDidFinish:(SKRequest *)request {
     NSLog(@"%s", __func__);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s --- error:%@", __func__, error);
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased://交易完成
                NSLog(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:      //商品添加进列表
                NSLog(@"商品添加进列表");
                break;
            default:
                break;
        }
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    // Your application should implement these two methods.
    NSString * productIdentifier = transaction.payment.productIdentifier;
//    NSString * receipt = [transaction.transactionReceipt base64EncodedString];
    if ([productIdentifier length] > 0) {
        // 向自己的服务器验证购买凭证
    }
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSLog(@"receiptData Size : %lu", receiptData.length);
    
    NSString *str = [[NSString alloc] initWithData:receiptData encoding:NSUTF8StringEncoding];
    NSLog(@"str : %@", str);
    
    
    NSError *error;
    NSDictionary *requestContents = @{
                                       @"receipt-data": [receiptData base64EncodedStringWithOptions:0]
                                       };
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    if (requestData == nil) {
        NSLog(@"requestData 为空");
    }
    
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   /* ... Handle error ... */
                                   NSLog(@"%s --- error:%@", __func__, connectionError);
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                   
                                   if (error) {
                                       NSLog(@"%s --- error:%@", __func__, error);
                                   }
                                   
                                   
                                   if (jsonResponse != nil) {
                                       NSLog(@"json: %@", jsonResponse);
                                   
                                   }
                               }
                           }];

    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"购买失败");
    }else {
        NSLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

@end
