#import "GLVExternalChangeCallbacks.h"

static void _GLVExternalChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    GLVExternalChangeHandler block = (__bridge GLVExternalChangeHandler)context;
    block(addressBook, (__bridge NSDictionary *)info);
}

const ABExternalChangeCallback GLVExternalChangeCallback = _GLVExternalChangeCallback;
