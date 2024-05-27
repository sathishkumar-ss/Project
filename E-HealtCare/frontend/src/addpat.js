const Web3 = require('web3');
const contract = require('truffle-contract');
const healthContract = require('./Health.json'); // Load the contract ABI and address from health.json

// Connect to a local Ethereum node using Web3.js
const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:7545')); // Replace with your Ethereum node URL

// Create a contract object
const HealthContract = contract(healthContract);
HealthContract.setProvider(web3.currentProvider);

// Set the default account (the account that will initiate the transaction)
web3.eth.defaultAccount = '0x4A3f780800bc1f395acc03F45EAfB94DFd060192'; // Replace with the admin's Ethereum address

// Function to add a patient
async function addPatient() {
    const aadhar = '123456789'; // Replace with the patient's Aadhar
    const name = 'Patient Name';
    const email = 'mmohanasundaram@student.tce.edu';
    const age = 30;
    const password = 'PatientPassword';

    try {
        // Get the deployed contract instance
        const healthInstance = await HealthContract.deployed();

        // Call the add_patient function
        await healthInstance.add_patient(
            aadhar,
            name,
            email,
            age,
            password,
            { from: web3.eth.defaultAccount }
        );

        console.log('Patient added successfully.');
    } catch (error) {
        console.error('Error adding patient:', error);
    }
}

// Call the addPatient function to add a patient
addPatient();
