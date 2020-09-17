module Fastlane
  module Actions

    class YkPodInstallAction < Action
      def self.run(params)
        Actions.sh "pod repo update matteoSpecs && cd Example && pod update"
        UI.message "Successfully pod update ⬆️ ".green
      end

      #####################################################
      # @!group Documentation
      #####################################################
      
      def self.description
        "Update all pods"
      end

      def self.details
        "Update all pods"
      end

      def self.authors
        ["wanyakun"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
