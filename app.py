import json

def hbrVal(YourAge):
    YourAge = int(YourAge)
    global maxHBR
    if (YourAge > 0) and (YourAge < 220):
        maxHBR = (220 - YourAge)
    else:
        return "Please enter a valid age"

    a = round(maxHBR * 0.64)
    b = round(maxHBR * 0.74)
    c = round(maxHBR * 0.77)
    d = round(maxHBR * 0.93)

    jsonOutput = {
        "MHBR": {
            "Max heart beat rate":f"{maxHBR} bpm",    
        }, 
        "Activity": {
        "Moderate-intensity physical activity":f"{a}-{b} bpm",
        "Vigorous-intensity physical activity":f"{c}-{d} bpm"
        }
    }
    return json.dumps(jsonOutput)

def lambda_handler(event, context):
    age = event['age']
    return hbrVal(age)
