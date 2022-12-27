import React from 'react'

const Navbar = ({accounts, setAccounts}) => {
    const isConnected = Boolean(accounts[0]);

    async function connectAccount(){    //this func updates the acc state in app.js 
        if (window.ethereum) {    //metamask injects with window.ethereum
            const accounts =  await window.ethereum.request({ method : 'eth_requestAccounts'});
            setAccounts(accounts);                                                                 
        }
    }
    
    return (
    <div>
        
    

        {/* Right side of navbar */}
        <div>About</div>
        <div>Mint</div>
        <div>Team</div>


        {/*  Connected button*/}
        {isConnected ?
            <p>Connected</p>
        : <button onClick={connectAccount}> Connect </button> }

    </div>
  )
};

export default Navbar
