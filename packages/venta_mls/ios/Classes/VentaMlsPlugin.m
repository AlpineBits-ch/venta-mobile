// This file exists so the Rust engine's exported symbols survive linking.
//
// Nothing in Swift or Objective-C calls the MLS engine - Dart looks its symbols
// up at runtime by name. To the linker that makes every one of them dead code.
// Referencing one symbol from a compiled translation unit is what stops the
// whole archive being dropped; `-force_load` in the podspec is the other half.

#import <Foundation/Foundation.h>

extern int64_t venta_mls_dummy_keep_symbols(void);

__attribute__((used)) static int64_t venta_mls_keep_alive(void) {
  return venta_mls_dummy_keep_symbols();
}
