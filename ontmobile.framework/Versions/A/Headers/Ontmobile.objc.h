// Objective-C API for talking to github.com/o3labs/ont-mobile/ontmobile Go package.
//   gobind -lang=objc github.com/o3labs/ont-mobile/ontmobile
//
// File is generated by gobind. Do not edit.

#ifndef __Ontmobile_H__
#define __Ontmobile_H__

@import Foundation;
#include "Universe.objc.h"


@class OntmobileJsonRpcRequest;
@class OntmobileJsonRpcResponse;
@class OntmobileONTAccount;
@class OntmobileParameterJSONArrayForm;
@class OntmobileParameterJSONForm;
@class OntmobileRawTransaction;

/**
 * JsonRpcRequest object in rpc
 */
@interface OntmobileJsonRpcRequest : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)version;
- (void)setVersion:(NSString*)v;
- (NSString*)id_;
- (void)setId:(NSString*)v;
- (NSString*)method;
- (void)setMethod:(NSString*)v;
// skipped field JsonRpcRequest.Params with unsupported type: []interface{}

@end

/**
 * JsonRpcResponse object response for JsonRpcRequest
 */
@interface OntmobileJsonRpcResponse : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (int64_t)error;
- (void)setError:(int64_t)v;
- (NSString*)desc;
- (void)setDesc:(NSString*)v;
- (NSString*)result;
- (void)setResult:(NSString*)v;
@end

@interface OntmobileONTAccount : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)address;
- (void)setAddress:(NSString*)v;
- (NSString*)wif;
- (void)setWIF:(NSString*)v;
- (NSData*)privateKey;
- (void)setPrivateKey:(NSData*)v;
- (NSData*)publicKey;
- (void)setPublicKey:(NSData*)v;
@end

@interface OntmobileParameterJSONArrayForm : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
// skipped field ParameterJSONArrayForm.A with unsupported type: []github.com/o3labs/ont-mobile/ontmobile.ParameterJSONForm

@end

@interface OntmobileParameterJSONForm : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)t;
- (void)setT:(NSString*)v;
// skipped field ParameterJSONForm.V with unsupported type: interface{}

@end

@interface OntmobileRawTransaction : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) id _ref;

- (instancetype)initWithRef:(id)ref;
- (instancetype)init;
- (NSString*)txid;
- (void)setTXID:(NSString*)v;
- (NSData*)data;
- (void)setData:(NSData*)v;
@end

FOUNDATION_EXPORT const int64_t OntmobileONGDECIMALS;
FOUNDATION_EXPORT NSString* const OntmobileUNBOUND_TIME_OFFSET;

@interface Ontmobile : NSObject
+ (NSData*) ongContractAddress;
+ (void) setONGContractAddress:(NSData*)v;

+ (NSData*) ontContractAddress;
+ (void) setONTContractAddress:(NSData*)v;

// skipped variable OntContractAddress with unsupported type: github.com/ontio/ontology/common.Address

@end

// skipped function BuildInvocationTransaction with unsupported parameter or return types


/**
 * ASi48wqdF9avm91pWwdphcAmaDJQkPNdNt
 */
FOUNDATION_EXPORT void OntmobileGetOffset(NSString* addressBase58, NSString* rpcEndpoint);

FOUNDATION_EXPORT NSString* OntmobileGetTimeFormat(int64_t second, NSString* format);

FOUNDATION_EXPORT OntmobileONTAccount* OntmobileNewONTAccount(void);

FOUNDATION_EXPORT OntmobileONTAccount* OntmobileONTAccountWithWIF(NSString* wif);

FOUNDATION_EXPORT NSString* OntmobileONTAddressFromPublicKey(NSData* publicKeyBytes);

FOUNDATION_EXPORT double OntmobileRoundFixed(double val, long decimals);

FOUNDATION_EXPORT NSString* OntmobileSendRawTransaction(NSString* endpoint, NSString* rawTransactionHex, NSError** error);

// skipped function SendRpcRequest with unsupported parameter or return types


// skipped function Transfer with unsupported parameter or return types


// skipped function WithdrawONG with unsupported parameter or return types


#endif
