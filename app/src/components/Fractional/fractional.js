import { useState, useContext } from 'react';
import './fractional.css';
const { executeTransaction, EthereumContext, log, queryData } = require('react-solidity-web3');

function Fractional() {
  const [submitting, setSubmitting] = useState(false);
  const { provider, sample } = useContext(EthereumContext);
  console.log("sample", sample)

  const genNFT = async (event) => {
    event.preventDefault();
    setSubmitting(true);
    let _flightId = "1";
    let _flightAddress = "0xA9e6835929f32DD440290b4c81466ff554b82667";
    let response1 = await queryData(sample, provider, 'flights', [_flightId, _flightAddress]);
    log("submitClaim", "hash", response1)
    setSubmitting(false);
  }

  return <div className="Container">
    <div>
      <h1>Property NFT Generator</h1><br></br>
      <form onSubmit={genNFT}>
        <button type="submit" disabled={submitting}>{submitting ? 'Generating..' : 'Generate NFT'}</button>
      </form>
    </div>
  </div>
}



export default Fractional;
