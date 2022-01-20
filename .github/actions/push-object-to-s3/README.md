# Local GitHub Docker Container Action
This is a custom GitHub Docker Container action which I've created myself. It will upload a single zip object to S3.

It is initially created so when I push code for my Lambda function, it will automatically upload a zipped version onto S3 for me.

# How it works
In the GitHub Workflow (../workflows/lambda-to-s3-jumpbox-uptime.yml), it triggers this action by calling `uses: ./.github/actions/push-object-to-s3`

Note: For the local action to work, we must first use `actions/checkout@v2`
