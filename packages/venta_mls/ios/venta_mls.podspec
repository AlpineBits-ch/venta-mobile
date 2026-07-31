#
# MLS engine for iOS.
#
# The Rust crate is linked as a static library rather than loaded as a dynamic
# one: iOS refuses to dlopen anything that is not inside the app bundle's
# Frameworks directory, so `DynamicLibrary.open` has nothing to open. Static
# linking puts the symbols in the app binary itself, where
# `DynamicLibrary.process()` finds them - which is what `_openLibrary` in
# lib/src/ffi.dart does on this platform.
#
Pod::Spec.new do |s|
  s.name             = 'venta_mls'
  s.version          = '0.1.0'
  s.summary          = 'MLS (RFC 9420) end-to-end encryption engine for venta_mobile.'
  s.description      = <<-DESC
Wraps the same openmls build the Alpine desktop client uses, so both clients can
join each other's groups and read each other's ciphertext.
                       DESC
  s.homepage         = 'https://venta.gg'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Venta' => 'dev@venta.gg' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # The script phase below writes the archive here; -force_load keeps the
    # exported symbols, which are otherwise stripped because nothing in
    # Swift/ObjC references them - Dart looks them up at runtime by name.
    'OTHER_LDFLAGS' => '-force_load ${PODS_TARGET_SRCROOT}/build/libventa_mls.a',
  }

  s.script_phase = {
    :name => 'Build Rust MLS engine',
    :script => '"${PODS_TARGET_SRCROOT}/build_rust.sh"',
    :execution_position => :before_compile,
    :output_files => ['${PODS_TARGET_SRCROOT}/build/libventa_mls.a'],
  }
end
