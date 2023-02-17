import react, { useEffect, useState, useContext } from "react";
// import { useState, useContext } from 'react';
import './fractional.css';
import { NFTGenerator as nftAddress } from '../../output.json';
const { executeTransaction, EthereumContext, log, queryData } = require('react-solidity-web3');

function Fractional() {
    const [submitting, setSubmitting] = useState(false);
    const [submitting2, setSubmitting2] = useState(false);
    const [submitting3, setSubmitting3] = useState(false);
    const [amount, setAmount] = useState('');
    const [ppt, setPpt] = useState('');
    const [stakeAddr, setStakeAddr] = useState('');
    const [stakeAddr2, setStakeAddr2] = useState('');
    const { provider, sample, estateContract, nftContract } = useContext(EthereumContext);
    console.log("estateContract", estateContract)

    const initializ = async (event) => {
        event.preventDefault();
        setSubmitting(true);
        // console.log(estateContract.address)
        let response1 = await executeTransaction(estateContract, provider, 'initialize', [nftAddress, 1, amount, ppt]);
        log("submitClaim", "hash", response1)
        console.log("response1 : ", response1)
        let response2 = await executeTransaction(nftContract, provider, 'setApprovalForAll', [estateContract.address, 1]);
        console.log("response2 : ", response2)
        setSubmitting(false);
    }

    const addStakeholder = async (event) => {
        event.preventDefault();
        setSubmitting3(true);
        let response1 = await executeTransaction(estateContract, provider, 'addStakeholder', [stakeAddr]);
        // log("submitClaim", "hash", response1)
        console.log("response1 : ", response1)
        setSubmitting3(false);
    }

    const removeStakeholder = async (event) => {
        event.preventDefault();
        setSubmitting2(true);
        let response1 = await executeTransaction(estateContract, provider, 'removeStakeholder', [stakeAddr]);
        // log("submitClaim", "hash", response1)
        console.log("response1 : ", response1)
        setSubmitting2(false);
    }

    return <div className="Container">
        <div>
            <h1>Initialize property (and links NFT)</h1><br></br>
            <form onSubmit={initializ}>
                <input type="text" placeholder="Number of Tokens" onChange={e => setAmount(e.target.value)} />
                <input type="text" placeholder="Price per token" onChange={e => setPpt(e.target.value)} />
                <button type="submit" disabled={submitting}>{submitting ? 'Initializing..' : 'Initialize Property'}</button>
            </form>
            <h1>Add Stakeholder</h1><br></br>
            <form onSubmit={addStakeholder}>
                <input type="text" placeholder="Stakeholder Address" onChange={e => setStakeAddr(e.target.value)} />
                <button type="submit" disabled={submitting2}>{submitting2 ? 'Adding..' : 'Add Stakeholder'}</button>
            </form>
            <h1>Remove Stakeholder</h1><br></br>
            <form onSubmit={removeStakeholder}>
                <input type="text" placeholder="Stakeholder Address" onChange={e => setStakeAddr2(e.target.value)} />
                <button type="submit" disabled={submitting2}>{submitting2 ? 'Removing..' : 'Remove Stakeholder'}</button>
            </form>
        </div>
    </div>
}

export default Fractional;