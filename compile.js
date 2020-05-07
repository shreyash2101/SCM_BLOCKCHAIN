/*const path = require("path");
const fs = require("fs");
const solc = require("solc");
const productPath = path.resolve(__dirname, "contracts", "ProductManagement.sol");
const source = fs.readFileSync(productPath, "utf8");
//console.log(solc.compile(source,1));
module.exports = solc.compile(source, 1).contracts[":ProductManagement"];*/


const path = require("path");
const fs = require("fs-extra");
const solc = require("solc");

// get a path to build folder
const buildPath = path.resolve(__dirname, "build");

// remove the build folder
fs.removeSync(buildPath);

const ChangeOwnershipPath = path.resolve(
  __dirname,
  "contracts",
  "ChangeOwnership.sol"
);
const ProductManagementPath = path.resolve(
  __dirname,
  "contracts",
  "ProductManagement.sol"
);
//const MigrationsPath = path.resolve(__dirname, "contracts", "Migrations.sol");

const source1 = fs.readFileSync(ChangeOwnershipPath, "utf8");
const source2 = fs.readFileSync(ProductManagementPath, "utf8");
//const source3 = fs.readFileSync(MigrationsPath, "utf8");

// module.exports = solc.compile(source1, 1).contracts[":ChangeOwnership"];
// module.exports = solc.compile(source2, 1).contracts[":ProductManagement"];
// module.exports = solc.compile(source3, 1).contracts[":Migrations"];

// console.log(solc.compile(source1, 1));
// console.log(solc.compile(source2, 1));
// console.log(solc.compile(source3, 1));

// this outputs variables store the compiled version of the solidity files(both interface and bytecode too is stored in this file)
output1 = solc.compile(source1, 1).contracts;
output2 = solc.compile(source2, 1).contracts;
//output3 = solc.compile(source3, 1).contracts;

// to check if build directory is present if not, creates a new directory
fs.ensureDirSync(buildPath);

// this function transfers the contents of outputs into new json files inside the build folder
for (let contract in output1) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(":", "") + ".json"),
    output1[contract]
  );
}

for (let contract in output2) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(":", "") + ".json"),
    output2[contract]
  );
}

/*for (let contract in output3) {
  fs.outputJsonSync(
    path.resolve(buildPath, contract.replace(":", "") + ".json"),
    output3[contract]
  );
}*/


