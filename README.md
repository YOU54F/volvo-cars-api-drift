# Testing API Provider Drift with Volvo's Cars APIs

This repository contains a sample project to demonstrate how to test for API provider drift using Volvo's Cars APIs.

We are going to follow the Volvo Cars Developer getting started guide to set up our environment and run a drift test against the Connected Vehicle API, to get our Vehicles VIN number, and the current engine status.

1. Sign up to a Volvo Cars Developer account, create an application, and obtain your demo API key.
   1. https://developer.volvocars.com/apis/docs/getting-started/#overview
   2. `export VCC_TOKEN=<your Connected Vehicle API token>`
   3. `export VCC_API_KEY=<your application API key>`
2. Clone this repository and navigate to the project directory.
3. [Install drift](https://pactflow.github.io/drift-docs/docs/tutorials/getting-started#1-install-drift)
   1. `npm install -g @pactflow/drift`
4. [Authenticate drift](https://pactflow.github.io/drift-docs/docs/tutorials/getting-started/#2-authenticate) by setting your PactFlow API url and token as an environment variable.
   1. `export PACT_BROKER_TOKEN=<your PactFlow API token>`
   2. `export PACT_BROKER_URL=<your PactFlow API url>`
   3. Run `drift auth login` to authenticate with your PactFlow account.
5. Run the drift test to check for API provider drift.
   1. `drift verify --server-url https://api.volvocars.com/connected-vehicle/v2 --test-files drift/drift.yaml`

Not working? Ensure you have set your environment variables correctly and that you have access to the Volvo Cars APIs. The `VCC_TOKEN` is short-lived (30 mins), so you may need to refresh it if you encounter authentication issues.