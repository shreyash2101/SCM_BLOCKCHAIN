const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require('web3');
const CompiledProductManagement = require('./build/ProductManagement.json');
const CompiledChangeOwnership = require("./build/ChangeOwnership.json");

const provider = new HDWalletProvider(
  "usual unlock sudden silk space clog maple cart album vintage insane glad",
  "https://rinkeby.infura.io/v3/85c2bf080bdb4901b6f09db036499d74"
);
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy Product Management contract from account', accounts[0]);

  const result1 = await new web3.eth.Contract(JSON.parse(CompiledProductManagement.interface))
    .deploy({ data: "0x" + CompiledProductManagement.bytecode })
    .send({ from: accounts[0] });

  console.log('Contract deployed to', result1.options.address);

  console.log(
    "Attempting to deploy Change Ownership contract from account",
    accounts[0]
  );

  const result2 = await new web3.eth.Contract(
    JSON.parse(CompiledChangeOwnership.interface)
  )
    .deploy({
      data: "0x" + CompiledChangeOwnership.bytecode,
      arguments: [result1.options.address]
    })
    .send({ from: accounts[0] });

  console.log("Contract deployed to", result2.options.address);
};
deploy();