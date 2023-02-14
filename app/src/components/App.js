import { ethers } from 'ethers';
import './App.css';
import Sample from './Sample/Sample';
import Fractional from './Fractional/fractional';
import Header from './Header/Header';
import { abi as abi0 } from '../artifacts/contracts/SampleContract.sol/SampleContract.json';
import { abi as abi2 } from '../artifacts/contracts/NFTGenerator.sol/NFTGenerator.json';
import { SampleContract as address0 } from '../output0.json';
// import { RealEstateContract as address1 } from '../output1.json';
import { NFTGenerator as address2 } from '../output2.json';

import { useState } from 'react';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

const { connectWallet, EthereumContext, createContractInstance, log } = require('react-solidity-web3');

var connectOptions = {
  rpcObj: {
    50: "https://rpc.xinfin.network",
    51: "https://rpc.apothem.network"
  },
  network: "mainnet",
  toDisableInjectedProvider: true
}

function App() {
  const [connecting, setconnecting] = useState(false);
  const [ethereumContext, setethereumContext] = useState({});

  const connect = async (event) => {
    event.preventDefault();
    const instance = await connectWallet(connectOptions);
    const provider = new ethers.providers.Web3Provider(instance);
    const signer = provider.getSigner();
    const sample = await createContractInstance(address0, abi0, provider);
    const nft = await createContractInstance(address2, abi2, provider);
    const account = signer.getAddress();
    setethereumContext({ provider, sample, account })
    log("Connect", "Get Address", await signer.getAddress());
    setconnecting(true);
  }
  return (
    <div className="App">
      <Header />
      <header className="App-header">
        <h1>Sample Decentralized Application </h1>
        <p>Powered by react-solidity-xdc3 Package</p>
        <p>Contributed by GoPlugin(www.goplugin.co)</p>
        <form onSubmit={connect}>
          <button type="submit" disabled={connecting}>{connecting ? 'Connecting...' : 'Connect'}</button>
        </form>
      </header>
      <section className="App-content">
        <EthereumContext.Provider value={ethereumContext}>
          <Sample />
          <Fractional />
        </EthereumContext.Provider>
      </section>
      <ToastContainer hideProgressBar={true} />
    </div>
  );
}

export default App;
