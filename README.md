# elasticache-tag-watcher

## About

This AWS Lambda function publishes an SNS message when it founds some ElastiCache nodes which have no specified tag by TAG environment variable.

This function is designed to be used with other Lambda function like lambda-slack-notifier (https://github.com/mozamimy/lambda-slack-notifier) through an SNS topic you like. Also, you can invoke this periodically with CloudWatch Events.

## Run locally with SAM CLI

```
bundle install --path vendor/bundle
echo '{}' | ec sam local invoke -t template.example.yml ElastiCacheTagWatcher
```

## Build a package for release

```
zip -r pkg/elasticache-tag-watcher.zip ./
```

## License

MIT
