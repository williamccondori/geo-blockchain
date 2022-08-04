const RegistersContract = artifacts.require("RegistersContract");

contract("RegistersContract", () => {
  before(async () => {
    this.contractInstance = await RegistersContract.deployed();
  });

  it("contract should be deployed", async () => {
    assert.ok(this.contractInstance.address);
  });

  it("contract should not be null", async () => {
    assert.notEqual(this.contractInstance.address, null);
  });

  it("contract should not be undefined", async () => {
    assert.notEqual(this.contractInstance.address, undefined);
  });
});
