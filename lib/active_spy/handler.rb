module ActiveSpy
  module Handler
    extend ActiveSupport::Concern
    include Station

    included do
      include Shoryuken::Worker

      ensure_sqs_queue_subscription!

      shoryuken_options queue: sqs_queue_name, auto_delete: true,
        body_parser: :json

      load_shoryuken_queue!
    end

    def perform(sqs_message, body)
      type    = body.delete('type')
      action  = body.delete('action')
      payload = body.delete('payload')
      actor   = body.delete('actor')

      send(action, type, payload, actor)
    end

    def create(type, payload, actor); end

    def update(type, payload, actor); end

    def destroy(type, payload, actor); end

    module ClassMethods
      private

      def load_shoryuken_queue!
        Shoryuken.queues << sqs_queue_name
      end

      def sqs_queue_name
        @sqs_queue_name ||= "#{app_name}-#{dasherized_name}-#{ActiveSpy.options[:app_env]}"
      end

      def sqs_queue
        @sqs_queue ||= sqs_client.create_queue({
          queue_name: sqs_queue_name,
          attributes: {
            'DelaySeconds'                  => '0',
            'MaximumMessageSize'            => '262144',
            'MessageRetentionPeriod'        => '345600',
            'ReceiveMessageWaitTimeSeconds' => '0',
            'VisibilityTimeout'             => '60'
          }
        })
      end

      def sqs_queue_arn
        @sqs_queue_arn ||= sqs_client.get_queue_attributes({
          queue_url: sqs_queue.queue_url,
          attribute_names: ['QueueArn']
        }).attributes['QueueArn']
      end

      def sns_topic_name
        @sns_topic_name ||=
          "#{dasherized_name.gsub('-handler', '')}-#{ActiveSpy.options[:app_env]}"
      end

      def ensure_sqs_queue_subscription!
        # Rails.logger.debug("[Interceptor] - Configuring Queue's Policy to accept SNS messages")
        sqs_client.set_queue_attributes({
          queue_url: sqs_queue.queue_url,
          attributes: {
            'Policy' => sqs_queue_policy.gsub("\n", '').gsub(/ +/, '')
          }
        })

        # Rails.logger.debug("[Interceptor] - Subscribing SNS Queue #{sqs_queue_name} to SNS Topic #{sns_topic.topic_arn}")
        subscription = sns_client.subscribe({
          topic_arn: sns_topic.topic_arn,
          protocol: 'sqs',
          endpoint: sqs_queue_arn
        })

        # Rails.logger.debug("[Interceptor] - Updating Subscription with arn #{subscription.subscription_arn} for SNS Queue #{sqs_queue_name}")
        sns_client.set_subscription_attributes({
          subscription_arn: subscription.subscription_arn,
          attribute_name: 'RawMessageDelivery',
          attribute_value: 'true',
        })

        # Rails.logger.debug("[Interceptor] - Subscription for SNS Queue #{sqs_queue_name} Ready!")
      end

      def sqs_queue_policy
        %(
        {
          "Version": "2012-10-17",
          "Id": "#{sqs_queue_arn}/SQSDefaultPolicy",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "AWS": "*"
              },
              "Action": "SQS:SendMessage",
              "Resource": "#{sqs_queue_arn}",
              "Condition": {
                "ArnEquals": {
                  "aws:SourceArn": "#{sns_topic.topic_arn}"
                }
              }
            }
          ]
        }
        ).gsub("\n", '').gsub(/ +/, '')
      end

      def delete_sqs_queue
        sqs_client.delete_queue(queue_url: sqs_queue.queue_url)
      end
    end
  end
end
