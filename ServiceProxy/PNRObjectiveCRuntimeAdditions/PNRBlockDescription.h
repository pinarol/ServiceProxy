#import <Foundation/Foundation.h>
#import <objc/runtime.h>

struct PNRBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;	// NULL
    	unsigned long int size;         // sizeof(struct Block_literal_1)
    	void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
    	void (*dispose_helper)(void *src);             // IFF (1<<25)
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
};

enum {
    PNRBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    PNRBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    PNRBlockDescriptionFlagsIsGlobal = (1 << 28),
    PNRBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    PNRBlockDescriptionFlagsHasSignature = (1 << 30)
};
typedef int PNRBlockDescriptionFlags;


@interface PNRBlockDescription : NSObject

@property (nonatomic, readonly) PNRBlockDescriptionFlags flags;
@property (nonatomic, readonly) NSMethodSignature *blockSignature;
@property (nonatomic, readonly) unsigned long int size;
@property (nonatomic, readonly) id block;

- (id)initWithBlock:(id)block;

- (BOOL)isCompatibleForBlockSwizzlingWithMethodSignature:(NSMethodSignature *)methodSignature;

@end
