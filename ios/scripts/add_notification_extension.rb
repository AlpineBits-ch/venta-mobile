#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Adds the NotificationService target to Runner.xcodeproj.
#
# A notification service extension is a second binary inside the app bundle, and
# Xcode records that in project.pbxproj - a file nobody should be hand-editing.
# This script does it with the `xcodeproj` gem (which ships with CocoaPods, so
# there is nothing extra to install) and is idempotent: run it again after a
# `flutter clean`, a project regeneration, or a fresh clone.
#
#   cd ios && ruby scripts/add_notification_extension.rb
#
# The sources it wires up live in ios/NotificationService/ and are checked in;
# this only creates the target, its build settings, and the app's dependency on
# it. See docs/push-decryption.md for the rest of the setup (the App Group has to
# exist on the Apple Developer portal, and both provisioning profiles need it).
#

require 'xcodeproj'

PROJECT_PATH = File.expand_path('../Runner.xcodeproj', __dir__)
TARGET_NAME = 'NotificationService'
SOURCE_DIR = File.expand_path('../NotificationService', __dir__)
APP_BUNDLE_ID = 'gg.venta.mobile'
DEPLOYMENT_TARGET = '15.0'

# The MLS engine. The extension links the same static archive the app does - the
# pod's build_rust.sh writes it here - so both are the same openmls build reading
# the same state file.
RUST_ARCHIVE = '$(SRCROOT)/../packages/venta_mls/ios/build/libventa_mls.a'
RUST_BUILD_SCRIPT = '"${SRCROOT}/../packages/venta_mls/ios/build_rust.sh"'

project = Xcodeproj::Project.open(PROJECT_PATH)
app_target = project.targets.find { |t| t.name == 'Runner' }
abort 'Could not find the Runner target' if app_target.nil?

existing = project.targets.find { |t| t.name == TARGET_NAME }
if existing
  puts "#{TARGET_NAME} already exists - refreshing its build settings."
  target = existing
else
  target = project.new_target(
    :app_extension, TARGET_NAME, :ios, DEPLOYMENT_TARGET
  )
end

# ── Sources ──────────────────────────────────────────────────────────────────
group = project.main_group.find_subpath(TARGET_NAME, true)
group.set_source_tree('SOURCE_ROOT')
group.set_path(TARGET_NAME)

%w[NotificationService.swift MlsNotificationDecryptor.swift].each do |name|
  next unless File.exist?(File.join(SOURCE_DIR, name))

  file = group.files.find { |f| f.display_name == name } || group.new_file(name)
  next if target.source_build_phase.files_references.include?(file)

  target.add_file_references([file])
end

# Headers are referenced by the bridging header, not compiled - they only need to
# be in the group so Xcode can resolve them.
%w[VentaMlsEngine.h NotificationService-Bridging-Header.h Info.plist
   NotificationService.entitlements].each do |name|
  next unless File.exist?(File.join(SOURCE_DIR, name))

  group.files.find { |f| f.display_name == name } || group.new_file(name)
end

# ── Build settings ───────────────────────────────────────────────────────────
target.build_configurations.each do |config|
  settings = config.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{APP_BUNDLE_ID}.#{TARGET_NAME}"
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['INFOPLIST_FILE'] = "#{TARGET_NAME}/Info.plist"
  settings['CODE_SIGN_ENTITLEMENTS'] = "#{TARGET_NAME}/#{TARGET_NAME}.entitlements"
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['SWIFT_VERSION'] = '5.0'
  settings['SWIFT_OBJC_BRIDGING_HEADER'] =
    "#{TARGET_NAME}/#{TARGET_NAME}-Bridging-Header.h"
  settings['SKIP_INSTALL'] = 'YES'
  # An extension is dynamically loaded by the system, so it must be built as a
  # position-independent bundle whatever the app is doing.
  settings['MACH_O_TYPE'] = 'mh_execute'
  settings['CLANG_ENABLE_MODULES'] = 'YES'
  # Not -force_load: unlike Dart (which resolves the engine's symbols by name at
  # runtime and so needs the whole archive kept), Swift references them directly,
  # and the linker pulls in exactly what that needs.
  settings['OTHER_LDFLAGS'] = ['$(inherited)', RUST_ARCHIVE]
  settings['ENABLE_BITCODE'] = 'NO'
end

# ── Build the Rust engine before compiling ───────────────────────────────────
# The pod builds the same archive for the app, but nothing orders that against
# this target, and an extension that links a missing archive fails the build with
# no useful explanation. Running the (cargo-cached, therefore near-free on a
# repeat) script here removes the ordering question entirely.
phase_name = 'Build Rust MLS engine'
unless target.shell_script_build_phases.any? { |p| p.name == phase_name }
  phase = target.new_shell_script_build_phase(phase_name)
  phase.shell_script = RUST_BUILD_SCRIPT
  phase.output_paths = [RUST_ARCHIVE]
  # Before the compile phase, which is where the linker needs it.
  target.build_phases.unshift(target.build_phases.delete(phase))
end

# ── Embed into the app ───────────────────────────────────────────────────────
app_target.add_dependency(target)

embed_phase = app_target.copy_files_build_phases.find do |phase|
  phase.symbol_dst_subfolder_spec == :plug_ins
end
embed_phase ||= app_target.new_copy_files_build_phase('Embed App Extensions').tap do |phase|
  phase.symbol_dst_subfolder_spec = :plug_ins
  phase.dst_path = ''
end

unless embed_phase.files_references.include?(target.product_reference)
  build_file = embed_phase.add_file_reference(target.product_reference)
  # Without this the extension is copied but never signed, and the app is
  # rejected at install time.
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

project.save
puts "Wired #{TARGET_NAME} into Runner.xcodeproj."
puts 'Next: open Runner.xcworkspace, select a signing team for the new target,'
puts "and make sure the App Group 'group.gg.venta.mobile' is enabled on both."
