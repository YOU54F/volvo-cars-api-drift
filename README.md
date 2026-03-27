
# Volvo Drift API Demo

This repository demonstrates advanced API testing and documentation practices using the Drift tool against the Volvo Cars APIs. It showcases:

- Response reuse
- Test operation ordering
- Multiple OpenAPI specifications
- Multiple authentication mechanisms with reuse

---

## Quickstart Guide

1. **Sign up for a Volvo Cars Developer account** and obtain your API key and token.
    - <https://developer.volvocars.com/apis/docs/getting-started/#overview>
    - `export VCC_TOKEN=<your Connected Vehicle API token>`
    - `export VCC_API_KEY=<your application API key>`
2. **Clone this repository** and navigate to the project directory.
3. **Install Drift:**
    - `npm install -g @pactflow/drift`
4. **(Optional) Authenticate Drift with your PactFlow account:**
    - `export PACT_BROKER_TOKEN=<your PactFlow API token>`
    - `export PACT_BROKER_BASE_URL=<your PactFlow API url>`
    - `drift auth login`
5. **Run the Drift test:**
    - `drift verify --server-url https://api.volvocars.com/connected-vehicle/v2 --test-files drift/drift.yaml`
6. **Troubleshooting:** Ensure environment variables are set and tokens are valid (`VCC_TOKEN` is short-lived).

## CI Quickstart

1. **Sign up for a Volvo Cars Developer account** and obtain your API key and token.
    - <https://developer.volvocars.com/apis/docs/getting-started/#overview>
    - `export VCC_TOKEN=<your Connected Vehicle API token>`
    - `export VCC_API_KEY=<your application API key>`\
2. **Fork this repository** and navigate to your forked repository.
3. Enable GitHub Actions in your forked repository and add the following secrets:
    - `VCC_API_KEY` (your application API key)
    - `PACT_BROKER_BASE_URL` (your PactFlow API url)
    - `PACT_BROKER_TOKEN` (your PactFlow API token)
4. Enable GitHub Actions in your forked repository and add the following variable:
    - `PACT_BROKER_BASE_URL` (your PactFlow API url)
5. **Run the workflow** in the Actions tab, passing in the `VCC_TOKEN` as a secret input parameter to ensure tests run successfully in CI.

---

## Advanced Features

### Response Reuse

Drift allows you to extract data from one operation and use it in another. For example, after fetching a vehicle list, the VIN is reused in a subsequent engine status request:

```yaml
operations:
   GetVehicleList_Success:
      target: connected-vehicle-c3-oas:GetVehicleList
      sequence: -1
      include:
         - connected-vehicle-auth
      expected:
         response:
            statusCode: 200
   GetEngineStatus_Success:
      target: connected-vehicle-c3-oas:GetEngineStatus
      include:
         - connected-vehicle-auth
      parameters:
         path:
            vin: ${functions:get_global_vin}
      expected:
         response:
            statusCode: 200
```

The function `get_global_vin` is defined in `drift.lua` and is set by `process_vin_from_response` when the `GetVehicleList_Success` operation runs:

```lua
local global_vin = nil
local function get_global_vin()
      return global_vin
end

local function process_vin_from_response(data)
-- returns the first vin from the body if present
-- and stores in global_vin
  local response_body = data and data["body"] and data["body"]
  if not response_body then
    return nil
  end
  if response_body["data"][0] and response_body["data"][0]["vin"] then
    global_vin = response_body["data"][0]["vin"]
  end
  return global_vin
end
-- ...
```

We are provided event lifecycle hooks to set the `global_vin` variable when the `GetVehicleList_Success` operation runs, allowing us to reuse it in the `GetEngineStatus_Success` operation.

```lua
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
```

### Test Operation Ordering

The `sequence: -1` field ensures that `GetVehicleList_Success` runs before other operations, so the VIN is available for reuse.

```yaml
operations:
  GetVehicleList_Success:
    target: connected-vehicle-c3-oas:GetVehicleList
    sequence: -1
```

### Multiple OpenAPI Specs

You can test multiple APIs in a single suite for real-world integration scenarios:

```yaml
sources:
   - name: connected-vehicle-c3-oas
      path: ../specs/connected-vehicle-c3-specification.yaml
   - name: energy-oas
      path: ../specs/energy-api-specification.yaml
   - name: location-oas
      path: ../specs/location-specification.yaml
```

We can reference operations from all these sources in the same test suite, allowing for comprehensive testing across multiple APIs.

```yaml
operations:
  GetVehicleList_Success:
    target: connected-vehicle-c3-oas:GetVehicleList
```

### Multiple Authentication Mechanisms with Reuse

Define and reuse different auth configs for different APIs or endpoints:

```yaml
global:
   connected-vehicle-auth:
      parameters:
         headers:
            vcc-api-key: ${env:VCC_API_KEY}
            authorization: Bearer ${env:VCC_TOKEN}
   energy-vehicle-auth:
      parameters:
         headers:
            vcc-api-key: ${env:VCC_API_KEY}
            authorization: Bearer ${env:VCC_TOKEN}
   location-auth:
      parameters:
         headers:
            vcc-api-key: ${env:VCC_API_KEY}
            authorization: Bearer ${env:VCC_TOKEN}
```

This can be used across operations targeting different APIs or endpoints, ensuring consistent and maintainable authentication handling.

```yaml
operations:
  GetVehicleList_Success:
    target: connected-vehicle-c3-oas:GetVehicleList
    sequence: -1
    description: "Get vehicles"
    include:
      - connected-vehicle-auth
    expected:
      response:
        statusCode: 200
```

### Cross-Platform CI Testing

The included GitHub Actions workflow runs tests across multiple OS environments, ensuring compatibility and reliability in CI. You can pass in the short-lived `VCC_TOKEN` as a secret input parameter to ensure tests run successfully in CI.

The following machine combinations are covered:

```yaml
      matrix:
        os: [
            ubuntu-latest,
            ubuntu-22.04-arm,
            windows-latest,
            windows-11-arm,
            macos-15-intel,
            macos-15
          ]      
```

### Extending Lua scripting with LuaRocks

Drift's lua scripting can be extended with pure Lua libraries using LuaRocks. For example, you could use the `dkjson` library to handle complex JSON parsing in your event handlers or functions.

This project shows how to include luarocks cross platform, in CI.

#### Installing LuaRocks

```yaml
      - name: Install luarocks (windows)
        if: runner.os == 'Windows'
        run: choco install -y luarocks
      - name: Install luarocks (linux)
        if: runner.os == 'Linux'
        run: sudo apt install luarocks
      - name: Install luarocks (macos)
        if: runner.os == 'MacOS'
        run: brew install luarocks
```

#### Installing LuaRocks Dependencies

```yaml
      - name: Install luarocks deps
        if: runner.os == 'Linux' || matrix.os == 'macos-15-intel'
        run: sudo luarocks install dkjson
      - name: Install luarocks deps
        if: runner.os != 'Linux' && matrix.os != 'macos-15-intel'
        run: luarocks install dkjson
```

#### Setting LuaRocks Environment Variables

```yaml
      - name: Set lua path env vars
        if: runner.os != 'windows'
        run: |
          eval $(luarocks path)
          echo LUA_PATH=$LUA_PATH >> $GITHUB_ENV
          echo LUA_CPATH=$LUA_CPATH >> $GITHUB_ENV

      - name: Set lua path env vars
        if: runner.os == 'windows'
        shell: cmd
        run: |
          for /f "tokens=*" %%i in ('luarocks path') do %%i
          ECHO LUA_PATH=%LUA_PATH% >> %GITHUB_ENV%
          ECHO LUA_CPATH=%LUA_PATH% >> %GITHUB_ENV%
```

#### Use of LuaRocks Library in Drift

```lua
local json = require("dkjson")

  event_handlers = {
    ["operation:invoked"] = function(event, data)
      print(json.encode (data, { indent = true }))
    end
  },
  
```

---

## Volvo Cars API Documentation

The project uses the following Volvo Cars APIs:

- **Connected Vehicle API**: Retrieve vehicle VINs and engine status.
- **Energy API**: Access the most recent energy state of a vehicle.
- **Location API**: Get the latest known location of a connected vehicle.

Each API is defined by an OpenAPI specification in the `specs/` directory. Authentication is handled via API key and OAuth token, as described in the official [Volvo Cars Developer documentation](https://developer.volvocars.com/apis/docs/getting-started/#overview).

---

## CI Integration

This project includes a GitHub Actions workflow to run Drift tests across multiple OS environments. See `.github/workflows/test.yml` for details. You can pass in the short-lived `VCC_TOKEN` as a secret input parameter to ensure tests run successfully in CI.
