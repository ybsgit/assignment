
def get_value(obj,keys):
    keys = keys.split("/")
    for key in keys:
         value = obj[key]
         obj = value 
    return value
    
    
print(get_value({'x':{'y':{'z':'a'}}},"x/y/z"))