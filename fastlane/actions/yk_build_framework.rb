module Fastlane
  module Actions
    class YkBuildFrameworkAction < Action
      def self.run(params)
        build_target = params[:project]
        current_path = Dir.pwd
        # 删除当前目录旧的framework和dsym文件
        framework = "#{current_path}/fmk/#{build_target}.xcframework"
        if File.exist?(framework)
          FileUtils.rm_rf(framework)
        end
        dsym = "#{current_path}/fmk/#{build_target}.xcframework.dSYM"
        if File.exist?(dsym)
          FileUtils.rm_rf(dsym)
        end

        build_path = "#{current_path}/build"
        Actions.sh("rm -rf #{build_path}/")

        build_project = "#{current_path}/Example/Pods/Pods.xcodeproj"

        # 编译configuration，默认为Release
        build_config = "Release"
        
        clean_command = "xcodebuild clean -project #{build_project} -scheme #{build_target} -configuration #{build_config}"
        Actions.sh(clean_command)

        # 构建真机xcarchive
        iphoneos_command = "xcodebuild archive -project #{build_project} -scheme #{build_target} -configuration Release -destination 'generic/platform=iOS' -archivePath ./build/#{build_target}-iphoneos.xcarchive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
        Actions.sh(iphoneos_command)

        # 构建模拟器xcarchive
        simulator_command = "xcodebuild archive -project #{build_project} -scheme #{build_target} -configuration Release -destination 'generic/platform=iOS Simulator' -archivePath ./build/#{build_target}-iphonesimulator.xcarchive SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES"
        Actions.sh(simulator_command)

        # 构建xcframework
        xcframework_command = "xcodebuild -create-xcframework -framework ./build/#{build_target}-iphoneos.xcarchive/Products/Library/Frameworks/#{build_target}.framework -framework ./build/#{build_target}-iphonesimulator.xcarchive/Products/Library/Frameworks/#{build_target}.framework -output ./build/#{build_target}.xcframework"
        Actions.sh(xcframework_command)

        copy_command = "cp -R ./build/#{build_target}.xcframework #{current_path}/fmk/"
        Actions.sh(copy_command)

      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Build dynamic framework with full bitcode which support iphoneos and simulator"
      end

      def self.details
        "Build dynamic framework with full bitcode which support iphoneos and simulator"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "FL_YK_BUILD_FRAMEWORK_PROJECT",
                                       description: "The project of the framework. It should be the same with scheme and name in the cocoapods podspec",
                                       is_string: true)
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["wanyakun"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
