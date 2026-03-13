# Testing API Provider Drift with Volvo's Cars APIs

This repository contains a sample project to demonstrate how to test for API provider drift using Volvo's Cars APIs. 

1. Sign up to a Volvo Cars Developer account, create an application, and obtain your demo API key.
   1. https://developer.volvocars.com/apis/docs/getting-started/#overview
   2. `export VCC_TOKEN=<your Connected Vehicle API token>`
   3. `export VCC_API_KEY=<your application API key>`
2. Clone this repository and navigate to the project directory.
3. [Install drift](https://pactflow.github.io/drift-docs/docs/tutorials/getting-started#1-install-drift)
   1. `npm install -g @pactflow/drift`
4. Run the drift test to check for API provider drift.
   1. `drift verifier --server-url https://api.volvocars.com/connected-vehicle/v2 --test-files drift/drift.yaml`

Not working? Ensure you have set your environment variables correctly and that you have access to the Volvo Cars APIs. The `VCC_TOKEN` is short-lived, so you may need to refresh it if you encounter authentication issues.