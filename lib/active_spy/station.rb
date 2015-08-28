require 'nullobject'

module ActiveSpy
  module Station
    extend ActiveSupport::Concern

    module ClassMethods
      private

      def sns_client
        if ActiveSpy.options[:fake_clients]
          Null::Object.instance
        else
          @sns_client ||= Aws::SNS::Client.new
        end
      end

      def sqs_client
        if ActiveSpy.options[:fake_clients]
          Null::Object.instance
        else
          @sqs_client ||= Aws::SQS::Client.new
        end
      end

      def find_sns_topic(name)
        sns_client.list_topics.topics.each do |topic|
          return topic if name == topic.topic_arn.split(':').last
        end

        return nil
      end

      def create_sns_topic(name)
        sns_client.create_topic(name: name)
      end

      def app_name
        @app_name ||= ActiveSpy.options[:app_name].underscore.dasherize
      end

      def sns_topic
        @sns_topic ||= find_sns_topic(sns_topic_name) || create_sns_topic(sns_topic_name)
      end

      def sns_topic_name
        @sns_topic_name ||= "#{app_name}-#{dasherized_name}-#{ActiveSpy.options[:app_env]}"
      end

      def dasherized_name
        @dasherized_name ||= name.underscore.dasherize
      end
    end

  end
end
