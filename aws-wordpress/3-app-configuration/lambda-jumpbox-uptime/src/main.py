import sys
def handler(event, context):
    print("Hello AWS! Using updated!")
    print("event = {}".format(event))
    return { 'statusCode': 200 }
