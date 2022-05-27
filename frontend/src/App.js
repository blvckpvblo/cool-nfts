import './styles/App.css';
import twitterLogo from './assets/twitter-logo.svg';
import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import myCoolNFT from "./utils/MyCoolNFT.json";

// Constants
const CONTRACT_ADDRESS = "0xB0Cc89636B762B8a7A424a77365A13b54dB4122a";
const TWITTER_HANDLE = 'blvckpvblo';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

const App = () => {
  // State variable to store user's public wallet
  const [currentAccount, setCurrentAccount] = useState("");
  const [totalNFTMinted, setTotalNFTMinted] = useState(0);
  const [isMining, setIsMining] = useState(false);

  // Check if we have access to Eth wallet
  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log('Make sure you have metamask!');
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account:", account);
      setCurrentAccount(account);
      getTotalMintedNFTs();
      setupEventListener();
    } else {
      console.log("No authorized account found.");
    }
  };

  const getTotalMintedNFTs = async () => {
    try {
      const { ethereum } = window;
  
      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(CONTRACT_ADDRESS, myCoolNFT.abi, signer);

        let count = await contract.getTotalNFTsMintedSoFar();
        console.log("Total NFT Minted:", count.toNumber());
        setTotalNFTMinted(count.toNumber());
      }
    } catch (error) {
      console.log(error);
    }
  };

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get metamask!");
        return;
      }

      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);

      setupEventListener();
    } catch (error) {
      console.log(error);
    }
  };

  // Setup our listener.
  const setupEventListener = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myCoolNFT.abi, signer);

        connectedContract.on('NewCoolNFTMinted', (from, tokenId, totalNFT) => {
          console.log(from, tokenId.toNumber(), totalNFT.toNumber());
          setTotalNFTMinted(totalNFT.toNumber());
          alert(`Hey there! We've minted your NFT and sent it to your wallet. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: https://testnets.opensea.io/assets/${CONTRACT_ADDRESS}/${tokenId.toNumber()}`);
        });

        console.log("Setup event listener!");
      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error);
    }
  };

  // Render Methods
  const renderNotConnectedContainer = () => (
    <button onClick={connectWallet} className="cta-button connect-wallet-button">
      Connect to Wallet
    </button>
  );

  const renderButton = () => {
    if (currentAccount === "") {
      renderNotConnectedContainer();
    } else if (currentAccount !== "") {
      if (isMining === false) {
        return(<button onClick={askContractToMintNft} className="cta-button connect-wallet-button">Mint NFT</button>);
      } else {
        return(<button onClick={null} className="cta-button connect-wallet-button">Mining...</button>);
      }
    }
  };

  const askContractToMintNft = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(CONTRACT_ADDRESS, myCoolNFT.abi, signer);

        console.log("Going to pop wallet now to pay gas...");
        let nftTxn = await connectedContract.makeACoolNFT();

        setIsMining(true);

        console.log("Mining...please wait...");
        await nftTxn.wait();

        setIsMining(false);

        console.log(`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);
      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">My NFT Collection</p>
          <p className="sub-text">
            Each unique. Each beautiful. Discover your NFT today.
          </p>
          <p style={{color: 'white'}}>{totalNFTMinted}/50 NFTs Minted</p>
          {renderButton()}
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built on @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;
