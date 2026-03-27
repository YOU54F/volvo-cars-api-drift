-- Helper function to get the operation ID from Drift's event data

local global_vin = nil

local function get_global_vin()
    return global_vin
end

local function process_vin_from_response(data)
-- returns the first vin from the body if present
-- and stores in global_vin
  if data then
    if data["body"] then
        local body = data["body"]
        if body and type(body) == "table" then
            for key, value in pairs(body["data"]) do
                if type(value) == "table" and value["vin"] then
                global_vin = tostring(value["vin"])
                return tostring(value["vin"])
                end
            end
        end
    end
  end
  return nil
end


local exports = {
  event_handlers = {
    -- this event handler allows us to introspect the response on a test case operation 
    ["operation:invoked"] = function(event, data)
      -- Here we want store a variable from the response for use in later requests
        local json = require("dkjson")
        local payload = {status = "ok"}
        print(json.encode(payload))
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