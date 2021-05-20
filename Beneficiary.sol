//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Beneficiary is Ownable {

    event BeneficiaryAdded(address _identifier, uint _allowance);
    event BeneficiaryRemoved(address _identifier);
    event AllowanceChanged(uint _amount);
    
    modifier onlyOwnerOrBeneficiary {
        require(isOwner() || beneficiaries[msg.sender].id != address(0), "You are not allowed!");
        _;
    }
    
    struct Beneficiary {
        uint allowance;
        address id;
        //... future possible fields.
    }
    
    mapping (address => Beneficiary) public beneficiaries;

    function isOwner() public view returns (bool) {
        require(msg.sender == owner());
    }

    /**
    * Adds a beneficiary to the Wallet.
    * 
    * @param _identifier the EoA address of the new beneficiary.
    * @param _allowance the max allowance of the new beneficiary.
    */
    function addBeneficiary(address _identifier, uint _allowance) public onlyOwner {
        emit BeneficiaryAdded(_identifier, _allowance);
        beneficiaries[_identifier].allowance = _allowance;
        beneficiaries[_identifier].id = _identifier;
    }
    
    /**
    * Removes a beneficiary to the Wallet.
    *
    * @param _identifier the EoA address of the new beneficiary.
    */
    function removeBeneficiary(address _identifier) public onlyOwner {
        emit BeneficiaryRemoved(_identifier);
        beneficiaries[_identifier].allowance = 0;
        beneficiaries[_identifier].id = address(0);
    }

    /**
    * Change the allowance of a given beneficiary.
    * 
    * @param _id the address of a beneficiary.
    * @param _allowance the new allowance amount.
    */
    function changeAllowance(address _id, uint _allowance) public onlyOwner {
        require(_allowance >= 0);
        beneficiaries[_id].allowance = _allowance;
    }
}