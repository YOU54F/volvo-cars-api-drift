-- Helper function to get the operation ID from Drift's event data

local global_vin = nil

local function get_global_vin()
    return global_vin
end

local json = require("dkjson")

local function process_vin_from_response(data)
-- returns the first vin from the body if present
-- and stores in global_vin
  local response_body = data and data["body"] and data["body"]
  if not response_body then
    return nil
  end
  print(json.encode (response_body, { indent = true }))
  if response_body["data"][0] and response_body["data"][0]["vin"] then
    global_vin = response_body["data"][0]["vin"]
  end
  return global_vin
end


local exports = {
  event_handlers = {
    -- this event handler allows us to introspect the response on a test case operation 
    ["operation:invoked"] = function(event, data)
      -- Here we want store a variable from the response for use in later requests
        -- data[0] is the test case operation id, which is unique
        if data[0] == "GetVehicleList_Success" then
          -- data[1] is the response object
          local vin = process_vin_from_response(data[1])
          print("Vin set to " .. global_vin)
        end
    end
  },
  
  exported_functions = {
    get_global_vin = get_global_vin
  }
}

return exports