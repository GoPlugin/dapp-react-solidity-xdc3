# Dapp Sample Implementation using npm package react-solidity-xdc3

## Powered by Plugin (A decentralized Oracle)

  

This guide will give you a clear direction on how to deploy your smart contracts, create react components and wire Web3 packages to push and pull the data onto/from the blockchain.

  

For any queries or comments, feel free to raise an issue.

  

# Table of Contents

- Pre-requisites

- How it works

- How to deploy

- How to create a component

- How to steup a function to submit txn to Blockchain

- How to query data from blockchain

- How to query events

  

## Pre-requisites

- nvm version 0.37.2

- npm version 7.24.0

- node version 16.10.0

- Do setup XDCPay Chrome Extension in your chrome

- Setup Hardhat (https://www.npmjs.com/package/hardhat)

  

## How it works?

- This project uses react-solidity-xdc3 npm package

- Copy down your contract in the contracts folder

- Update deployment.js script under scripts folder to refer to your contract name

- Pass the necessary constructor parameters (if any)

- If you have more than one contract to deploy, refer those accordingly

- Pass your PRIVATE_KEY in .env to deploy your contract against a specific network (Apothem or Mainnet)

- After successful deployment, copy down the output.json into the App folder

- Go to the App folder, create your component and call execute function for write, and queryData function for read

  

## .env should have following parameters

- PRIVATE_KEY (of your account) to migrate the contract

  

## How to Run

- do git clone & npm install

  

```

npm install

```

## How to deploy sample contract

```

yarn deploy --network apothem

```

This will deploy the contract on apothem network and the contract address will be stored in output.json

  

Copy down this contract address in the App folder, under the same output.json

  

## How to run client application

- After copying the contract address, run react application using following command in the App folder

```

yarn install

yarn start

```

This will start the application in http://localhost:3000

- When you click "Register", it writes the data onto the blockchain

- When you click "Fetch", it pulls the data from the blockchain

  

## How to Create a new component and implement this react-solidity-xdc3 / react-solidity-web3 at ease

- Go to app/src/components/

- Clone "Sample" folder and name your components (let's say - Flights)

- Rename new component Sample.js -> Flights.js

- Rename new component Sample.css -> Flights.css

- Update the app.js to have this Flights component

```

import Flights from './Flights/Flights';

```

- Create an instance for flight contract and abi

```

const flight = await createInstance(flightaddress, flightabi, provider);

```

"flightabi" and "flightaddress" is read from respective paths

- Set the flight instance in ethereum context like below

```

setethereumContext({ provider, sample,flght, account })

```

  

- Update the app.js to have Flights component added under EthereumContext like below

```

<section className="App-content">

  <EthereumContext.Provider value={ethereumContext}>

	<Sample />

	<Flights />

  </EthereumContext.Provider>

</section>

```

- Go to Flights.js file and implement this

- Create functions say - "registerFlights", "fetchFlight"

- Update "sample" reference to flight

- executeTxn() function expects 4 parameters : "contractInstance, provider, functionName, [params separated by comma (leave if empty) ]"

- queryData() function also expects the same 4 parameters : "contractInstance, provider, functionName, [params separated by comma (leave if empty) ] "

  

All Set, now you should be able to write data onto the blockchain & read from it.