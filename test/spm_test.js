const assert = require("assert");
const ganache = require("ganache-cli");
const Web3 = require("web3");
const web3 = new Web3(ganache.provider());


const ProductManagement = require("../build/ProductManagement.json");

let accounts;
let product;

beforeEach(async () =>{
  accounts = await web3.eth.getAccounts();

  product = await new web3.eth.Contract(JSON.parse(ProductManagement.interface))
    .deploy({ data: ProductManagement.bytecode })
    .send({ from: accounts[0], gas: "10000000" });
});

describe("Contracts", () => {
  it("Deploys a contract ProductManagement", () =>{
    assert.ok(product.options.address);
  });
  it("should create a wheel and store it", () => {
    const serial_number = "123456";
    const part_type = "wheel";
    return product.methods
      .buildPart(serial_number, part_type)
      .send({
        from: accounts[0],
        value: 0,
      });
  });
});