require 'aws-sdk-elasticache'
require 'aws-sdk-sns'
require 'json'
require 'logger'
require 'pp'

def lambda_handler(event:, context:)
  logger = Logger.new($stdout)

  elasticache = Aws::ElastiCache::Client.new
  clusters = elasticache.describe_cache_clusters

  node_names_without_tag = []
  clusters.cache_clusters.each do |cache_cluster|
    resource_arn = "arn:aws:elasticache:#{ENV.fetch('AWS_REGION')}:#{ENV.fetch('ACCOUNT_ID')}:cluster:#{cache_cluster.cache_cluster_id}"
    tags = elasticache.list_tags_for_resource(
      resource_name: resource_arn,
    )

    if tags.tag_list.empty? || tags.tag_list.none? { |t| t.key == ENV.fetch('TAG') }
      node_names_without_tag << cache_cluster.cache_cluster_id
    end
  end

  if node_names_without_tag.empty?
    logger.info("There are no ElastiCache nodes without #{ENV.fetch('TAG')} tag.")
  else
    logger.info(node_names_without_tag.join("\n"))

    sns = Aws::SNS::Client.new
    sns_publish_params = {
      topic_arn: ENV.fetch('SNS_TOPIC_ARN'),
      subject: ENV['SNS_SUBJECT'],
      message: node_names_without_tag.join("\n"),
    }
    if ENV['SNS_MESSAGE_ATTRIBUTES']
      sns_publish_params[:message_attributes] = JSON.parse(ENV['SNS_MESSAGE_ATTRIBUTES'], symbolize_names: true)
    end

    sns.publish(sns_publish_params)
  end
end
