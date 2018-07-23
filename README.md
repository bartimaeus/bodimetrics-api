# BodiMetrics API for Ruby

A sample repository to test BodiMetrics API using Ruby


## Setup

1. Create .env file for docker

        cp .env.example .env

    **NOTE**: make sure to update the .env with valid client_id and client_secret before starting the docker container

2. Build the docker image

        docker-compose build

3. Start the docker image

        docker-compose up -d

4. Connect to the docker image

        docker exec -it bodimetrics-ruby sh -l

## Running the Code

1. Conenct to the docker image *(see step 4 of Setup)*

        docker exec -it bodimetrics-ruby sh -l

2. Open up an interactive ruby session:

        irb

3. Include the BodiMetrics file:

        require './lib/bodi_metrics.rb'

4. Create a new instance of the BodiMetrics API

        api = BodiMetrics.new

5. Make an API call

        api.get_patients

