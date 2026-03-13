-- Helper function to get the operation ID from Drift's event data

local global_vin = nil

local function get_global_vin()
    return global_vin
end

local function get_vin(data)
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
    ["operation:invoked"] = function(event, data)
        local vin = get_vin(data)
        print("Vin set to " .. global_vin)
    end
  },
  
  exported_functions = {
    bearer_token = bearer_token,
    get_global_vin = get_global_vin
  }
}

return exports