// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Health {
    struct user {
        address addr;
        string password;
        uint categ;
    }

    struct record {
        string date;
        address doctor;
        string diagnosis;
        string description;
        string prescription;
        string[] files;
    }

    struct patient {
        string aadhar;
        string name;
        string email;
        uint age;
        address[] doctorAccessList;
        mapping(uint => record) recordMap;
        uint recordSize;
    }

    struct doctor {
        address addr;
        string name;
        string hospital;
        string specialization;
        uint age;
        address[] patientAccessList;
    }

    struct prescription {
        string date;
        address doctor;
        string data;
        string status;
    }

    mapping(address => user) USERS;
    mapping(address => patient) public PATIENTS;
    mapping(address => doctor) public DOCTORS;
    mapping(address => prescription[]) public PHARMACY;

    string[] aadhar;

    string[4] private_keys = [
        "cdbae1ac14aeb734663396a508abe8ce17b61b2facb32228e4225e427d4bf54e",
        "e05b0d8c5ac7c03fdecc1e3118fe4f72b24a82efd95571e412bf75e0810a5259",
        "43d2cb0dba87a71b19910f7b71b732cdf01eda3ac51e8289b0a3b13881a47891",
        "41545ad8334e4e858c895312ec28f9e17b2783bc76a8c240e47fb68e3d547d0a"
    ];
    address[4] addresses = [
        0xaE9C2ad4F3c197c6C8eF8A51143142cf211955cf,
        0xa6657c0c139717D0B063c61dbC387099a0ef39cD,
        0xD875cd818801340fd6de0a21Da812bB9BDeF27CF,
        0xC0AA6dD25EA7caF83D07E59904D324299f752CAF
    ];

    // variable to keep count of patients and doctors
    uint public patientCount = 0;
    uint public doctorCount = 0;

    /* UTILITY FUNCTIONS */

    function compare(
        string memory str1,
        string memory str2
    ) public pure returns (bool) {
        return
            keccak256(abi.encodePacked(str1)) ==
            keccak256(abi.encodePacked(str2));
    }

    function get_count(
        string memory _filter,
        address _addr
    ) private view returns (uint) {
        uint count = 0;
        for (uint k = 0; k < PHARMACY[_addr].length; k++) {
            if (compare(PHARMACY[_addr][k].status, _filter)) {
                count++;
            }
        }
        return count;
    }

    function find_actual_index(
        address _patient,
        uint _index,
        string memory _filter
    ) private view returns (uint) {
        uint count = 0;
        uint pos = 0;
        for (uint p = 0; p < PHARMACY[_patient].length; p++) {
            if (compare(PHARMACY[_patient][p].status, _filter)) {
                count++;
                if ((count - 1) == _index) {
                    pos = p;
                    break;
                }
            }
        }
        return pos;
    }

    /* AUTHENTICATION MODULE */

    function add_doctor(
        address _addr,
        string memory _name,
        string memory _hospital,
        string memory _special,
        uint _age,
        string memory _password
    ) public {
        require(
            USERS[_addr].addr != _addr,
            "This address has already been registered"
        );
        USERS[_addr].addr = _addr;
        USERS[_addr].password = _password;
        USERS[_addr].categ = 1;

        doctorCount++;
        DOCTORS[_addr].addr = _addr;
        DOCTORS[_addr].hospital = _hospital;
        DOCTORS[_addr].specialization = _special;
        DOCTORS[_addr].name = _name;
        DOCTORS[_addr].age = _age;
    }

    function add_pharmacy(address _addr, string memory _password) public {
        USERS[_addr].addr = _addr;
        USERS[_addr].password = _password;
        USERS[_addr].categ = 2;
    }

    function add_patient(
        string memory _aadhar,
        string memory _name,
        string memory _email,
        uint _age,
        string memory _password
    ) public {
        // get available address and private key for the patient
        i = 0;
        while (i < addresses.length) {
            if (compare("", USERS[addresses[i]].password)) {
                break;
            }
            i++;
        }

        require(i < addresses.length, "Out of possible addresses");
        USERS[addresses[i]].addr = addresses[i];
        USERS[addresses[i]].password = _password;
        USERS[addresses[i]].categ = 0;

        patientCount++;
        aadhar.push(_aadhar);
        PATIENTS[addresses[i]].aadhar = _aadhar;
        PATIENTS[addresses[i]].name = _name;
        PATIENTS[addresses[i]].age = _age;
        PATIENTS[addresses[i]].email = _email;
        PATIENTS[addresses[i]].recordSize = 0;

        set_i(i);
    }

    uint i;

    function set_i(uint x) private {
        i = x;
    }

    // to get address and private key of the patient newly created
    function get_addressKey() public view returns (address, string memory) {
        return (addresses[i], private_keys[i]);
    }

    function getPassword() public view returns (string memory) {
        address _addr = msg.sender;
        return USERS[_addr].password;
    }

    function getRole() public view returns (uint) {
        address _addr = msg.sender;
        return USERS[_addr].categ;
    }

    function get_existing_aadhars() public view returns (string[] memory) {
        return aadhar;
    }

    function login(string memory _password) public view returns (uint) {
        address _addr = msg.sender;
        // check if account with given address exists
        require(
            compare("", USERS[_addr].password),
            "Account not found. Register first"
        );
        // check if msg.sender if the owner of the account
        require(
            USERS[_addr].addr == msg.sender,
            "You cannot login to this account"
        );
        // check if the stored and the inputted password match
        require(
            compare(USERS[_addr].password, _password),
            "Password does not match"
        );
        // return category of the user
        return USERS[_addr].categ;
    }

    function get_patient(
        address _addr
    ) public view returns (string memory, uint, string memory email) {
        return (
            PATIENTS[_addr].name,
            PATIENTS[_addr].age,
            PATIENTS[_addr].email
        );
    }

    function get_doctor(
        address _addr
    )
        public
        view
        returns (address, string memory, string memory, string memory, uint)
    {
        return (
            DOCTORS[_addr].addr,
            DOCTORS[_addr].name,
            DOCTORS[_addr].hospital,
            DOCTORS[_addr].specialization,
            DOCTORS[_addr].age
        );
    }

    /* ACCESS MANAGEMENT MODULE */

    function permit_access(address addr) public payable {
        DOCTORS[addr].patientAccessList.push(msg.sender);
        PATIENTS[msg.sender].doctorAccessList.push(addr);
    }

    function revoke_access(address daddr) public payable {
        address patientAddr = msg.sender;
        address doctorAddr = daddr;

        // remove patient's address from within the doctor's accesslist
        address[] storage arr = DOCTORS[doctorAddr].patientAccessList;
        remove_element_from_array(arr, patientAddr);

        //remove doctor's address from within the patients's accesslist
        arr = PATIENTS[patientAddr].doctorAccessList;
        remove_element_from_array(arr, doctorAddr);

        // payable(msg.sender).transfer(2 ether);
    }

    function remove_element_from_array(
        address[] storage arr,
        address addr
    ) private {
        // find index of this addr in the array
        bool found = false;
        uint target_index = 0;
        for (uint j = 0; j < arr.length; j++) {
            if (arr[j] == addr) {
                found = true;
                target_index = j;
                break;
            }
        }
        // if not found, revert
        if (!found) revert("Address not found in list");
        else {
            if (arr.length == 1) arr.pop();
            else {
                arr[target_index] = arr[arr.length - 1];
                arr.pop();
            }
        }
    }

    function get_permitted_doctors() public view returns (address[] memory) {
        address addr = msg.sender;
        return PATIENTS[addr].doctorAccessList;
    }

    function get_accessible_patients() public view returns (address[] memory) {
        address addr = msg.sender;
        return DOCTORS[addr].patientAccessList;
    }

    /* DATA EXCHANGE MODULE */

    function add_patient_record(
        address patientAddr,
        string memory _date,
        string memory _diagnosis,
        string memory _description,
        string memory _prescription,
        string[] memory _files
    ) public {
        patient storage p = PATIENTS[patientAddr];

        p.recordMap[p.recordSize] = record(
            _date,
            msg.sender,
            _diagnosis,
            _description,
            _prescription,
            _files
        );
        p.recordSize++;

        if (!compare("", _prescription)) {
            PHARMACY[patientAddr].push(
                prescription(_date, msg.sender, _prescription, "Pending")
            );
        }
    }

    function get_patient_records(
        address patientAddr
    ) public view returns (record[] memory) {
        record[] memory records = new record[](
            PATIENTS[patientAddr].recordSize
        );
        for (uint k = 0; k < PATIENTS[patientAddr].recordSize; k++) {
            records[k] = PATIENTS[patientAddr].recordMap[k];
        }
        return records;
    }

    /* PHARMACY MODULE */

    // get history of all prescriptions for given patient
    function get_prescriptions(
        address _patient
    ) public view returns (prescription[] memory) {
        return PHARMACY[_patient];
    }

    // get pending prescriptions for given patient
    function get_pending_prescriptions(
        address _patient
    ) public view returns (prescription[] memory) {
        prescription[] memory requests = new prescription[](
            get_count("Pending", _patient)
        );
        uint k = 0;
        for (uint j = 0; j < PHARMACY[_patient].length; j++) {
            if (compare(PHARMACY[_patient][j].status, "Pending")) {
                requests[k] = PHARMACY[_patient][j];
                k++;
            }
        }
        return requests;
    }

    // resolve a prescription for a patient
    function resolve_prescription(address _patient, uint _index) public {
        uint pos = find_actual_index(_patient, _index, "Pending");
        PHARMACY[_patient][pos].status = "Resolved";
    }
}
