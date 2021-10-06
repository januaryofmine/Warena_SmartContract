const Ware = artifacts.require("Ware");
const Rena = artifacts.require("Rena");
const MintableToken = artifacts.require("MintableToken");
const Marketplace = artifacts.require("Marketplace");
const Faucet = artifacts.require("Faucet");

module.exports = function (deployer) {
  // deployer.deploy(Ware, "1000000000000000000000000000"); // ERC20
  // deployer.deploy(Rena, "1000000000000000000000000000"); // ERC20
  // deployer.deploy(MintableToken); // ERC721
  deployer.deploy(
    Marketplace,
    "0xB5bfF68D951938e156d67acc5f92a26de9505873",
    "0x775c8194867B2B332F590F947eE6069665871E6e"
  ); // Marketplace
  // deployer.deploy(Faucet, "0x7bC299AD2ABB57D2bDAc08f80A2909f3a2bBB20D", "50000000000000000000");
};
