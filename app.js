// @TODO: Update this address to match your deployed BlockEstateMarket contract!
const contractAddress = "0x52238B55d5d47D5DcED057eE141936b1cd0E8207";
main: async function() {
    // Initialize web3
    if (!this.ethEnabled()) {
      alert("Please install MetaMask to use this dApp!");
    }

    this.accounts = await window.web3.eth.getAccounts();
    this.contractAddress = contractAddress;

    this.BlockEstateMarket = await (await fetch("./BlockEstateMarket.json")).json();
    this.BlockEstateAuction = await (await fetch("./BlockEstateAuction.json")).json();

    this.BlockEstateContract = new window.web3.eth.Contract(
      this.BlockEstateMarket,
      this.contractAddress,
      { defaultAccount: this.accounts[0] }
    );
    console.log("Contract object", this.BlockEstateContract);

    this.isAdmin = this.accounts[0] == await this.BlockEstateContract.methods.owner().call();

    await this.updateUI();
  }
};

dApp.main();
