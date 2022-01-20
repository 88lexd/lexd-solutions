import sys
def handler(event, context):
    print("Hello AWS! Using updated 2022.01.19! 22")
    print("event = {}".format(event))
    return { 'statusCode': 200 }
