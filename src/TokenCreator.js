import { ethers, BigNumber } from 'ethers';
import React, { useState } from 'react';
import deMarketPlace from "./DeMarketPlace.json";

const deMarketPlaceAddress = "0x303AB349f0E21B66A15dd86BE98Baf64D8E9BF3D";

const TokenCreator = ({ accounts, setAccount }) => {

  const [tokenUri, SetTokenUri] = useState('www.abc.com');
  const [tokenPrice, SetTokenPrice] = useState(1000000000000000);
  const [tokenId, SetTokenId] = useState(1);
  const [Newprice, setNewPrice] = useState(2000000000000000)
 
  
  const isConnected = Boolean(accounts[0]);
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const contract = new ethers.Contract(deMarketPlaceAddress, deMarketPlace.abi, signer);

  async function handleTokenCreation() {

    if (window.ethereum) {
      try {
        console.log(tokenPrice);
        const response = await contract.createToken(tokenUri, `${tokenPrice}`);               //we call a function in the contract like this and the response is what that func returns. Amount always sent in wei(BigNumber)
        console.log("response", response);
      } catch (err) {
        console.log("error", err);
      }
    }
  }

  async function handleTokenBuying() {
    if (window.ethereum) {
      try {
        console.log(tokenId);
        const response = await contract.buyMarketItem(tokenId, { value: ethers.utils.parseEther("0.00275") });               //we call a function in the contract like this and the response is what that func returns. Amount always sent in wei(BigNumber)
        console.log("response", response);
      } catch (err) {
        console.log("error", err);
      }
    }
  }

  async function handleTokenReselling() {
    if (window.ethereum) {
      try {
        console.log(tokenId);
        const response = await contract.resellMarketItem(tokenId, `${Newprice}`);               //we call a function in the contract like this and the response is what that func returns. Amount always sent in wei(BigNumber)
        console.log("response", response);
      } catch (err) {
        console.log("error", err);
      }
    }
  }
  

  return (
    <div>

      <div >
        <h3>Create Token</h3>
        {isConnected ? (
          <div>
            <div>
              <input type="number" value={tokenPrice} />
              <input type="text" value={tokenUri} />
            </div>
            <button onClick={handleTokenCreation}> Create Your Token </button>
          </div>
        )
        : (
            <p>you must be connected if you wish to Mint</p>
        )}
      </div>

      <div>
        <h3>Buy Token </h3>
        {isConnected ? (
          <div>
            <input type="number" value={tokenId} />
            <button onClick={handleTokenBuying}> Buy Token Now </button>
          </div>
        ): (
          <p> you must be connected if you wish to Buy a Token </p>
        )}
      </div>


      <div>
      <h3>Resell token </h3>
        {isConnected ? (
          <div>
            <input type="number" value={tokenId} />
            <input type="number" value={Newprice} />
            <button onClick={handleTokenReselling}> Relist Token Now </button>
          </div>
        ): (
          <p> you must be connected if you wish to resell your Token </p>
        )}    
      </div>

    </div>
  );
};


export default TokenCreator
