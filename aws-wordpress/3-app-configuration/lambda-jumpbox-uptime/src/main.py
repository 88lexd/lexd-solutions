import sys
def handler(event, context):
    print("Hello AWS! Using updated 2022.01.20! 2:18")
    print("event = {}".format(event))
    return { 'statusCode': 200 }
