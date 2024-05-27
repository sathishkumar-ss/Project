

const Web3 = require('web3');
const contract = require('truffle-contract');
const healthContract = require('./Health.json'); // Load the contract ABI and address from health.json

// Connect to a local Ethereum node using Web3.js
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545')); // Replace with your Ethereum node URL

// Create a contract object
const HealthContract = contract(healthContract);
HealthContract.setProvider(web3.currentProvider);

// Set the default account (the account that will initiate the transaction)
web3.eth.defaultAccount = '0xC0AA6dD25EA7caF83D07E59904D324299f752CAF'; // Replace with the address of the default authorized person (admin)

// Function to add a doctor
async function addDoctor() {
    const doctorAddress = '0xC0AA6dD25EA7caF83D07E59904D324299f752CAF'; // Replace with the doctor's Ethereum address
    const doctorName = 'Doctor Mohan';
    const hospital = 'Madurai GH';
    const specialization = 'GENERAL';
    const age = 35;
    const password = '123456789';

    try {
        // Get the deployed contract instance
        const healthInstance = await HealthContract.deployed();

        // Call the add_doctor function
        await healthInstance.add_doctor(
            doctorAddress,
            doctorName,
            hospital,
            specialization,
            age,
            password,
            { from: web3.eth.defaultAccount }
        );

        console.log('Doctor added successfully.');
    } catch (error) {
        console.error('Error adding doctor:', error);
    }
}

// Call the addDoctor function to add a doctor
addDoctor();
