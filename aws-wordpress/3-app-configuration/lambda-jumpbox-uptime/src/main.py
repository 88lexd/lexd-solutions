import sys
def handler(event, context):
    print("Hello AWS! Using updated 2022.01.20! 1")
    print("event = {}".format(event))
    return { 'statusCode': 200 }
