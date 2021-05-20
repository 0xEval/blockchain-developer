pragma solidity ^0.8.1;

/**
 * @author Eval (0xeval)
 * @title A simple shared wallet contract
 */

contract Wallet {
    
        event Deposit(address _from, uint _amount);
        event Withdrawal(address _to, uint _amount);
        event NewBeneficiary(address _identifier);
        
        modifier onlyOwner {
            require(msg.sender == owner, "You are not the owner.");
            _;
        }
        
        modifier onlyBeneficiary {
            require(beneficiaries[msg.sender].id != address(0), "You are not a beneficiary.");
            _;
        }
    
        struct Beneficiary {
            uint allowance;
            uint balance;
            address id;
        }
        
        mapping (address => Beneficiary) public beneficiaries;
        
        address public owner;
        uint private totalBalance;
        uint private defaultAllowance = 0.1 ether;
        
    
        constructor() {
            owner = msg.sender;
            beneficiaries[msg.sender].id = owner;
            beneficiaries[msg.sender].allowance = type(uint256).max;
            beneficiaries[msg.sender].balance = 0;
            
        }
        
        /**
         * Deposits money in the Wallet.
         */
        function deposit() public payable {
            totalBalance += msg.value;
            emit Deposit(msg.sender, msg.value);
        }
        
        /**
         * Adds a beneficiary to the Wallet.
         * 
         * @param _identifier the EoA address of the new beneficiary
         */
        function addBeneficiary(address _identifier) public onlyOwner {
            beneficiaries[_identifier].allowance = defaultAllowance;
            beneficiaries[_identifier].balance = 0;
            beneficiaries[_identifier].id = _identifier;
            emit NewBeneficiary(_identifier);
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
        
        /**
         * Withdraw a given amount of money from the Wallet.
         * The max withdrawal amount is determined by the pre-defined allowance variable
         * associated to the address.
         * 
         * @param _amount the withdrawal amount
        */
        function withdraw(uint _amount) public onlyBeneficiary {
            require(beneficiaries[msg.sender].balance + _amount <= beneficiaries[msg.sender].allowance, "Withdrawal amount above allowance.");
            beneficiaries[msg.sender].balance += _amount;
            payable(msg.sender).transfer(_amount);
            emit Withdrawal(msg.sender, _amount);
        }
        
        /**
         * Withdraw the total balance stored in the wallet.
         * Must be called by _owner_.
         */
        function withdrawAll() public onlyOwner {
            withdraw(address(this).balance);
        }
        

}