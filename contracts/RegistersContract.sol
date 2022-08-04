// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract RegistersContract {
    constructor() {}

    uint256 public registerCounter = 0;

    event RegisterCreated(
        uint256 id,
        string name,
        string lastName,
        string contractNumber,
        string geojson,
        uint256 createdAt,
        string createdBy
    );

    event RegisterUpdated(
        uint256 id,
        string name,
        string lastName,
        string contractNumber,
        string geojson,
        uint256 updatedAt,
        string updatedBy
    );

    struct Register {
        uint256 id;
        string name;
        string lastName;
        string contractNumber;
        string geojson;
        uint256 createdAt;
        string createdBy;
        uint256 updatedAt;
        string updatedBy;
    }

    mapping(uint256 => Register) public registers;

    function createRegister(
        string memory _name,
        string memory _lastName,
        string memory _contractNumber,
        string memory _geojson,
        string memory _user
    ) public {
        registerCounter++;
        uint256 date = block.timestamp;
        registers[registerCounter] = Register(
            registerCounter,
            _name,
            _lastName,
            _contractNumber,
            _geojson,
            date,
            _user,
            date,
            _user
        );
        emit RegisterCreated(
            registerCounter,
            _name,
            _lastName,
            _contractNumber,
            _geojson,
            date,
            _user
        );
    }

    function updateRegister(
        uint256 _id,
        string memory _name,
        string memory _lastName,
        string memory _contractNumber,
        string memory _geojson,
        string memory _user
    ) public {
        uint256 date = block.timestamp;
        Register memory _register = registers[_id];
        _register.name = _name;
        _register.lastName = _lastName;
        _register.contractNumber = _contractNumber;
        _register.geojson = _geojson;
        _register.updatedAt = date;
        _register.updatedBy = _user;
        registers[_id] = _register;

        emit RegisterUpdated(
            _id,
            _name,
            _lastName,
            _contractNumber,
            _geojson,
            date,
            _user
        );
    }
}
