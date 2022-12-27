
import { useState } from 'react';
import './App.css';
import TokenCreator from "./TokenCreator";
import NavBar from "./NavBar";




function App() {
  const [accounts, setAccounts] = useState([]);
  const isConnected = Boolean(accounts[0]);
  
  return (
    <div className="App">
      <h1> De Market Place</h1>
      <NavBar accounts = {accounts} setAccounts = {setAccounts} />
      <TokenCreator  accounts = {accounts} setAccounts = {setAccounts} />
      
    </div>
  );
}

export default App;
