require "fastlane_core"
require "credentials_manager"

module Gym
  class Options
    def self.available_options
      return @options if @options

      @options = plain_options
    end

    def self.legacy_api_note!
      UI.important "Unfortunately the legacy build API was removed with Xcode 8.3."
      UI.important "Please make sure to remove use_legacy_build_api from your ./fastlane/Fastfile"
      UI.important "and update the gym call to include the export method like this:"
      UI.important "== App Store Builds =="
      UI.error '     gym(scheme: "MyScheme", export_method: "app-store")'
      UI.important "==  Ad Hoc Builds =="
      UI.error '     gym(scheme: "MyScheme", export_method: "ad-hoc")'
      UI.important "== Development Builds =="
      UI.error '     gym(scheme: "MyScheme", export_method: "development")'
      UI.important "== In-House Enterprise Builds =="
      UI.error '     gym(scheme: "MyScheme", export_method: "enterprise")'
      UI.important "If you run into a code signing error, please check out our troubleshooting guide for more information on how to solve the most common issues"
      UI.error "    https://docs.fastlane.tools/codesigning/troubleshooting/ 🚀"
      UI.important ""
      UI.user_error! "legacy_build_api removed!"
    end

    def self.plain_options
      [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     env_name: "GYM_WORKSPACE",
                                     optional: true,
                                     description: "Path the workspace file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       UI.user_error!("Workspace file not found at path '#{v}'") unless File.exist?(v)
                                       UI.user_error!("Workspace file invalid") unless File.directory?(v)
                                       UI.user_error!("Workspace file is not a workspace, must end with .xcworkspace") unless v.include?(".xcworkspace")
                                     end,
                                     conflicting_options: [:project],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can only pass either a 'workspace' or a '#{value.key}', not both")
                                     end),
        FastlaneCore::ConfigItem.new(key: :project,
                                     short_option: "-p",
                                     optional: true,
                                     env_name: "GYM_PROJECT",
                                     description: "Path the project file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       UI.user_error!("Project file not found at path '#{v}'") unless File.exist?(v)
                                       UI.user_error!("Project file invalid") unless File.directory?(v)
                                       UI.user_error!("Project file is not a project file, must end with .xcodeproj") unless v.include?(".xcodeproj")
                                     end,
                                     conflicting_options: [:workspace],
                                     conflict_block: proc do |value|
                                       UI.user_error!("You can only pass either a 'project' or a '#{value.key}', not both")
                                     end),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     optional: true,
                                     env_name: "GYM_SCHEME",
                                     description: "The project's scheme. Make sure it's marked as `Shared`"),
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     env_name: "GYM_CLEAN",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "GYM_OUTPUT_DIRECTORY",
                                     description: "The directory in which the ipa file should be stored in",
                                     default_value: "."),
        FastlaneCore::ConfigItem.new(key: :output_name,
                                     short_option: "-n",
                                     env_name: "GYM_OUTPUT_NAME",
                                     description: "The name of the resulting ipa file",
                                     optional: true,
                                     verify_block: proc do |value|
                                       value.gsub!(".ipa", "")
                                       value.gsub!(File::SEPARATOR, "_")
                                     end),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     short_option: "-q",
                                     env_name: "GYM_CONFIGURATION",
                                     description: "The configuration to use when building the app. Defaults to 'Release'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :silent,
                                     short_option: "-a",
                                     env_name: "GYM_SILENT",
                                     description: "Hide all information that's not necessary while building",
                                     default_value: false,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :codesigning_identity,
                                     short_option: "-i",
                                     env_name: "GYM_CODE_SIGNING_IDENTITY",
                                     description: "The name of the code signing identity to use. It has to match the name exactly. e.g. 'iPhone Distribution: SunApps GmbH'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_package_ipa,
                                     env_name: "GYM_SKIP_PACKAGE_IPA",
                                     description: "Should we skip packaging the ipa?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :include_symbols,
                                     short_option: "-m",
                                     env_name: "GYM_INCLUDE_SYMBOLS",
                                     description: "Should the ipa file include symbols?",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :include_bitcode,
                                     short_option: "-z",
                                     env_name: "GYM_INCLUDE_BITCODE",
                                     description: "Should the ipa include bitcode?",
                                     is_string: false,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :use_legacy_build_api,
                                     deprecated: "Don't use this option any more, as it's deprecated by Apple",
                                     env_name: "GYM_USE_LEGACY_BUILD_API",
                                     description: "Don't use this option any more, as it's deprecated by Apple",
                                     default_value: false,
                                     is_string: false,
                                     verify_block: proc do |value|
                                       if value
                                         UI.important "Don't use this option any more, as it's deprecated by Apple"
                                       end
                                       if Gym::Xcode.legacy_api_deprecated?
                                         Gym::Options.legacy_api_note!
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :export_method,
                                     short_option: "-j",
                                     env_name: "GYM_EXPORT_METHOD",
                                     description: "Method used to export the archive. Valid values are: app-store, ad-hoc, package, enterprise, development, developer-id",
                                     is_string: true,
                                     optional: true,
                                     verify_block: proc do |value|
                                       av = %w(app-store ad-hoc package enterprise development developer-id)
                                       UI.user_error!("Unsupported export_method, must be: #{av}") unless av.include?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :export_options,
                                     env_name: "GYM_EXPORT_OPTIONS",
                                     description: "Specifies path to export options plist. User xcodebuild -help to print the full set of available options",
                                     is_string: false,
                                     optional: true,
                                     conflicting_options: [:use_legacy_build_api],
                                     conflict_block: proc do |value|
                                       UI.user_error!("'#{value.key}' must be false to use 'export_options'")
                                     end),
        FastlaneCore::ConfigItem.new(key: :export_xcargs,
                                     env_name: "GYM_EXPORT_XCARGS",
                                     description: "Pass additional arguments to xcodebuild for the package phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS=\"-ObjC -lstdc++\"",
                                     optional: true,
                                     conflicting_options: [:use_legacy_build_api],
                                     conflict_block: proc do |value|
                                       UI.user_error!("'#{value.key}' must be false to use 'export_xcargs'")
                                     end,
                                     type: :shell_string),
        FastlaneCore::ConfigItem.new(key: :skip_build_archive,
                                     env_name: "GYM_SKIP_BUILD_ARCHIVE",
                                     description: "Export ipa from previously build xarchive. Uses archive_path as source",
                                     is_string: false,
                                     optional: true),
        # Very optional
        FastlaneCore::ConfigItem.new(key: :build_path,
                                     env_name: "GYM_BUILD_PATH",
                                     description: "The directory in which the archive should be stored in",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :archive_path,
                                     short_option: "-b",
                                     env_name: "GYM_ARCHIVE_PATH",
                                     description: "The path to the created archive",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                     short_option: "-f",
                                     env_name: "GYM_DERIVED_DATA_PATH",
                                     description: "The directory where build products and other derived data will go",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :result_bundle,
                                     short_option: "-u",
                                     env_name: "GYM_RESULT_BUNDLE",
                                     is_string: false,
                                     description: "Produce the result bundle describing what occurred will be placed",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :buildlog_path,
                                     short_option: "-l",
                                     env_name: "GYM_BUILDLOG_PATH",
                                     description: "The directory where to store the build log",
                                     default_value: "#{FastlaneCore::Helper.buildlog_path}/gym"),
        FastlaneCore::ConfigItem.new(key: :sdk,
                                     short_option: "-k",
                                     env_name: "GYM_SDK",
                                     description: "The SDK that should be used for building the application",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :toolchain,
                                     env_name: "GYM_TOOLCHAIN",
                                     description: "The toolchain that should be used for building the application (e.g. com.apple.dt.toolchain.Swift_2_3, org.swift.30p620160816a)",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :provisioning_profile_path,
                                     short_option: "-e",
                                     env_name: "GYM_PROVISIONING_PROFILE_PATH",
                                     description: "The path to the provisioning profile (optional)",
                                     optional: true,
                                     deprecated: 'Use target specific provisioning profiles instead',
                                     verify_block: proc do |value|
                                       UI.user_error!("Provisioning profile not found at path '#{File.expand_path(value)}'") unless File.exist?(File.expand_path(value))
                                     end),
        FastlaneCore::ConfigItem.new(key: :destination,
                                     short_option: "-d",
                                     env_name: "GYM_DESTINATION",
                                     description: "Use a custom destination for building the app",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :export_team_id,
                                     short_option: "-g",
                                     env_name: "GYM_EXPORT_TEAM_ID",
                                     description: "Optional: Sometimes you need to specify a team id when exporting the ipa file",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :xcargs,
                                     short_option: "-x",
                                     env_name: "GYM_XCARGS",
                                     description: "Pass additional arguments to xcodebuild for the build phase. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS=\"-ObjC -lstdc++\"",
                                     optional: true,
                                     type: :shell_string),
        FastlaneCore::ConfigItem.new(key: :xcconfig,
                                     short_option: "-y",
                                     env_name: "GYM_XCCONFIG",
                                     description: "Use an extra XCCONFIG file to build your app",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("File not found at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :suppress_xcode_output,
                                     short_option: "-r",
                                     env_name: "SUPPRESS_OUTPUT",
                                     description: "Suppress the output of xcodebuild to stdout. Output is still saved in buildlog_path",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :disable_xcpretty,
                                     env_name: "DISABLE_XCPRETTY",
                                     description: "Disable xcpretty formatting of build output",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :xcpretty_test_format,
                                     env_name: "XCPRETTY_TEST_FORMAT",
                                     description: "Use the test (RSpec style) format for build output",
                                     optional: true,
                                     is_string: false),
        FastlaneCore::ConfigItem.new(key: :xcpretty_formatter,
                                     env_name: "XCPRETTY_FORMATTER",
                                     description: "A custom xcpretty formatter to use",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Formatter file not found at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :xcpretty_report_junit,
                                     env_name: "XCPRETTY_REPORT_JUNIT",
                                     description: "Have xcpretty create a JUnit-style XML report at the provided path",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Report output location not found at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :xcpretty_report_html,
                                     env_name: "XCPRETTY_REPORT_HTML",
                                     description: "Have xcpretty create a simple HTML report at the provided path",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Report output location not found at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :xcpretty_report_json,
                                     env_name: "XCPRETTY_REPORT_JSON",
                                     description: "Have xcpretty create a JSON compilation database at the provided path",
                                     optional: true,
                                     verify_block: proc do |value|
                                       UI.user_error!("Report output location not found at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :xcpretty_utf,
                                     env_name: "XCPRETTY_UTF",
                                     description: "Have xcpretty use unicode encoding when reporting builds",
                                     optional: true,
                                     is_string: false)
      ]
    end
  end
end
