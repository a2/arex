@import AddressBook;
@import Foundation;

typedef void (^GLVExternalChangeHandler)(ABAddressBookRef __nonnull addressBook, NSDictionary *__nullable info);

/// context must be a pointer to GLVExternalChangeHandler, otherwise the behavior is undefined.
extern const ABExternalChangeCallback __nonnull GLVExternalChangeCallback;
