const RegistersContract = artifacts.require("RegistersContract");

module.exports = function (deployer) {
  deployer.deploy(RegistersContract);
};
