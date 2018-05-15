//mainnet: 0x04f925b8Ff7E457D6dAF6FF677Ba36aC8ff4719d
pragma solidity ^0.4.17;
contract TicketPro
{
    mapping(address => bytes32[]) inventory;
    uint16 ticketIndex = 0; //to track mapping in tickets
    address stormbird;   // the address that calls selfdestruct() and takes fees
    address organiser;
    address paymaster;
    uint transferFee;
    uint numOfTransfers = 0;
    string public name;
    string public symbol;
    uint8 public constant decimals = 0; //no decimals as tickets cannot be split

    event Transfer(address indexed _to, uint16[] _indices);
    event TransferFrom(address indexed _from, address indexed _to, uint16[] _indices);
    event Trade(address indexed seller, uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s);
    event PassTo(uint16[] ticketIndices, uint8 v, bytes32 r, bytes32 s, address indexed recipient);

    modifier organiserOnly()
    {
        if(msg.sender != organiser) revert();
        else _;
    }
    
    modifier payMasterOnly()
    {
        if(msg.sender != paymaster) revert();
        else _;
    }
    
    function() public { revert(); } //should not send any ether directly

    // example: 
    // ["0x1422D6357BCCF004DFBDD0533F200000", "0x1422D6357BCCF004DFBDD0533F200001", "0x1422D6357BCCF004DFBDD0533F200002", "0x1422D6357BCCF004DFBDD0533F200003", "0x1422D6357BCCF004DFBDD0533F200004", "0x1422D6357BCCF004DFBDD0533F200005", "0x1422D6357BCCF004DFBDD0533F200006", "0x1422D6357BCCF004DFBDD0533F200007", "0x1422D6357BCCF004DFBDD0533F200008", "0x1422D6357BCCF004DFBDD0533F200009", "0x1422D6357BCCF004DFBDD0533F20000a", "0x1422D6357BCCF004DFBDD0533F20000b", "0x1422D6357BCCF004DFBDD0533F20000c", "0x1422D6357BCCF004DFBDD0533F20000d", "0x1422D6357BCCF004DFBDD0533F20000e", "0x1422D6357BCCF004DFBDD0533F20000f", "0x1422D6357BCCF004DFBDD0533F200010", "0x1422D6357BCCF004DFBDD0533F200011", "0x1422D6357BCCF004DFBDD0533F200012", "0x1422D6357BCCF004DFBDD0533F200013", "0x1422D6357BCCF004DFBDD0533F200014", "0x1422D6357BCCF004DFBDD0533F200015", "0x1422D6357BCCF004DFBDD0533F200016", "0x1422D6357BCCF004DFBDD0533F200017", "0x1422D6357BCCF004DFBDD0533F200018", "0x1422D6357BCCF004DFBDD0533F200019", "0x1422D6357BCCF004DFBDD0533F20001a", "0x1422D6357BCCF004DFBDD0533F20001b", "0x1422D6357BCCF004DFBDD0533F20001c", "0x1422D6357BCCF004DFBDD0533F20001d", "0x1422D6357BCCF004DFBDD0533F20001e", "0x1422D6357BCCF004DFBDD0533F20001f", "0x1422D6357BCCF004DFBDD0533F200020", "0x1422D6357BCCF004DFBDD0533F200021", "0x1422D6357BCCF004DFBDD0533F200022", "0x1422D6357BCCF004DFBDD0533F200023", "0x1422D6357BCCF004DFBDD0533F200024", "0x1422D6357BCCF004DFBDD0533F200025", "0x1422D6357BCCF004DFBDD0533F200026", "0x1422D6357BCCF004DFBDD0533F200027", "0x1422D6357BCCF004DFBDD0533F200028", "0x1422D6357BCCF004DFBDD0533F200029", "0x1422D6357BCCF004DFBDD0533F20002a", "0x1422D6357BCCF004DFBDD0533F20002b", "0x1422D6357BCCF004DFBDD0533F20002c", "0x1422D6357BCCF004DFBDD0533F20002d", "0x1422D6357BCCF004DFBDD0533F20002e", "0x1422D6357BCCF004DFBDD0533F20002f", "0x1422D6357BCCF004DFBDD0533F200030", "0x1422D6357BCCF004DFBDD0533F200031", "0x1422D6357BCCF004DFBDD0533F200032", "0x1422D6357BCCF004DFBDD0533F200033", "0x1422D6357BCCF004DFBDD0533F200034", "0x1422D6357BCCF004DFBDD0533F200035", "0x1422D6357BCCF004DFBDD0533F200036", "0x1422D6357BCCF004DFBDD0533F200037", "0x1422D6357BCCF004DFBDD0533F200038", "0x1422D6357BCCF004DFBDD0533F200039", "0x1422D6357BCCF004DFBDD0533F20003a", "0x1422D6357BCCF004DFBDD0533F20003b", "0x1422D6357BCCF004DFBDD0533F20003c", "0x1422D6357BCCF004DFBDD0533F20003d", "0x1422D6357BCCF004DFBDD0533F20003e", "0x1422D6357BCCF004DFBDD0533F20003f", "0x1422D6357BCCF004DFBDD0533F200040", "0x1422D6357BCCF004DFBDD0533F200041", "0x1422D6357BCCF004DFBDD0533F200042", "0x1422D6357BCCF004DFBDD0533F200043", "0x1422D6357BCCF004DFBDD0533F200044", "0x1422D6357BCCF004DFBDD0533F200045", "0x1422D6357BCCF004DFBDD0533F200046", "0x1422D6357BCCF004DFBDD0533F200047", "0x1422D6357BCCF004DFBDD0533F200048", "0x1422D6357BCCF004DFBDD0533F200049", "0x1422D6357BCCF004DFBDD0533F20004a", "0x1422D6357BCCF004DFBDD0533F20004b", "0x1422D6357BCCF004DFBDD0533F20004c", "0x1422D6357BCCF004DFBDD0533F20004d", "0x1422D6357BCCF004DFBDD0533F20004e", "0x1422D6357BCCF004DFBDD0533F20004f", "0x1422D6357BCCF004DFBDD0533F200050", "0x1422D6357BCCF004DFBDD0533F200051", "0x1422D6357BCCF004DFBDD0533F200052", "0x1422D6357BCCF004DFBDD0533F200053", "0x1422D6357BCCF004DFBDD0533F200054", "0x1422D6357BCCF004DFBDD0533F200055", "0x1422D6357BCCF004DFBDD0533F200056", "0x1422D6357BCCF004DFBDD0533F200057", "0x1422D6357BCCF004DFBDD0533F200058", "0x1422D6357BCCF004DFBDD0533F200059", "0x1422D6357BCCF004DFBDD0533F20005a", "0x1422D6357BCCF004DFBDD0533F20005b", "0x1422D6357BCCF004DFBDD0533F20005c", "0x1422D6357BCCF004DFBDD0533F20005d", "0x1422D6357BCCF004DFBDD0533F20005e", "0x1422D6357BCCF004DFBDD0533F20005f", "0x1422D6357BCCF004DFBDD0533F200060", "0x1422D6357BCCF004DFBDD0533F200061", "0x1422D6357BCCF004DFBDD0533F200062", "0x1422D6357BCCF004DFBDD0533F200063", "0x1422D6357BCCF004DFBDD0533F200064", "0x1422D6357BCCF004DFBDD0533F200065", "0x1422D6357BCCF004DFBDD0533F200066", "0x1422D6357BCCF004DFBDD0533F200067", "0x1422D6357BCCF004DFBDD0533F200068", "0x1422D6357BCCF004DFBDD0533F200069", "0x1422D6357BCCF004DFBDD0533F20006a", "0x1422D6357BCCF004DFBDD0533F20006b", "0x1422D6357BCCF004DFBDD0533F20006c", "0x1422D6357BCCF004DFBDD0533F20006d", "0x1422D6357BCCF004DFBDD0533F20006e", "0x1422D6357BCCF004DFBDD0533F20006f", "0x1422D6357BCCF004DFBDD0533F200070", "0x1422D6357BCCF004DFBDD0533F200071", "0x1422D6357BCCF004DFBDD0533F200072", "0x1422D6357BCCF004DFBDD0533F200073", "0x1422D6357BCCF004DFBDD0533F200074", "0x1422D6357BCCF004DFBDD0533F200075", "0x1422D6357BCCF004DFBDD0533F200076", "0x1422D6357BCCF004DFBDD0533F200077", "0x1422D6357BCCF004DFBDD0533F200078", "0x1422D6357BCCF004DFBDD0533F200079", "0x1422D6357BCCF004DFBDD0533F20007a", "0x1422D6357BCCF004DFBDD0533F20007b", "0x1422D6357BCCF004DFBDD0533F20007c", "0x1422D6357BCCF004DFBDD0533F20007d", "0x1422D6357BCCF004DFBDD0533F20007e", "0x1422D6357BCCF004DFBDD0533F20007f", "0x1422D6357BCCF004DFBDD0533F200080", "0x1422D6357BCCF004DFBDD0533F200081", "0x1422D6357BCCF004DFBDD0533F200082", "0x1422D6357BCCF004DFBDD0533F200083", "0x1422D6357BCCF004DFBDD0533F200084", "0x1422D6357BCCF004DFBDD0533F200085", "0x1422D6357BCCF004DFBDD0533F200086", "0x1422D6357BCCF004DFBDD0533F200087", "0x1422D6357BCCF004DFBDD0533F200088", "0x1422D6357BCCF004DFBDD0533F200089", "0x1422D6357BCCF004DFBDD0533F20008a", "0x1422D6357BCCF004DFBDD0533F20008b", "0x1422D6357BCCF004DFBDD0533F20008c", "0x1422D6357BCCF004DFBDD0533F20008d", "0x1422D6357BCCF004DFBDD0533F20008e", "0x1422D6357BCCF004DFBDD0533F20008f", "0x1422D6357BCCF004DFBDD0533F200090", "0x1422D6357BCCF004DFBDD0533F200091", "0x1422D6357BCCF004DFBDD0533F200092", "0x1422D6357BCCF004DFBDD0533F200093", "0x1422D6357BCCF004DFBDD0533F200094", "0x1422D6357BCCF004DFBDD0533F200095", "0x1422D6357BCCF004DFBDD0533F200096", "0x1422D6357BCCF004DFBDD0533F200097", "0x1422D6357BCCF004DFBDD0533F200098", "0x1422D6357BCCF004DFBDD0533F200099", "0x1422D6357BCCF004DFBDD0533F20009a", "0x1422D6357BCCF004DFBDD0533F20009b", "0x1422D6357BCCF004DFBDD0533F20009c", "0x1422D6357BCCF004DFBDD0533F20009d", "0x1422D6357BCCF004DFBDD0533F20009e", "0x1422D6357BCCF004DFBDD0533F20009f", "0x1422D6357BCCF004DFBDD0533F2000a0", "0x1422D6357BCCF004DFBDD0533F2000a1", "0x1422D6357BCCF004DFBDD0533F2000a2", "0x1422D6357BCCF004DFBDD0533F2000a3", "0x1422D6357BCCF004DFBDD0533F2000a4", "0x1422D6357BCCF004DFBDD0533F2000a5", "0x1422D6357BCCF004DFBDD0533F2000a6", "0x1422D6357BCCF004DFBDD0533F2000a7", "0x1422D6357BCCF004DFBDD0533F2000a8", "0x1422D6357BCCF004DFBDD0533F2000a9", "0x1422D6357BCCF004DFBDD0533F2000aa", "0x1422D6357BCCF004DFBDD0533F2000ab", "0x1422D6357BCCF004DFBDD0533F2000ac", "0x1422D6357BCCF004DFBDD0533F2000ad", "0x1422D6357BCCF004DFBDD0533F2000ae", "0x1422D6357BCCF004DFBDD0533F2000af", "0x1422D6357BCCF004DFBDD0533F2000b0", "0x1422D6357BCCF004DFBDD0533F2000b1", "0x1422D6357BCCF004DFBDD0533F2000b2", "0x1422D6357BCCF004DFBDD0533F2000b3", "0x1422D6357BCCF004DFBDD0533F2000b4", "0x1422D6357BCCF004DFBDD0533F2000b5", "0x1422D6357BCCF004DFBDD0533F2000b6", "0x1422D6357BCCF004DFBDD0533F2000b7", "0x1422D6357BCCF004DFBDD0533F2000b8", "0x1422D6357BCCF004DFBDD0533F2000b9", "0x1422D6357BCCF004DFBDD0533F2000ba", "0x1422D6357BCCF004DFBDD0533F2000bb", "0x1422D6357BCCF004DFBDD0533F2000bc", "0x1422D6357BCCF004DFBDD0533F2000bd", "0x1422D6357BCCF004DFBDD0533F2000be", "0x1422D6357BCCF004DFBDD0533F2000bf", "0x1422D6357BCCF004DFBDD0533F2000c0", "0x1422D6357BCCF004DFBDD0533F2000c1", "0x1422D6357BCCF004DFBDD0533F2000c2", "0x1422D6357BCCF004DFBDD0533F2000c3", "0x1422D6357BCCF004DFBDD0533F2000c4", "0x1422D6357BCCF004DFBDD0533F2000c5", "0x1422D6357BCCF004DFBDD0533F2000c6", "0x1422D6357BCCF004DFBDD0533F2000c7", "0x1422D6357BCCF004DFBDD0533F2000c8", "0x1422D6357BCCF004DFBDD0533F2000c9", "0x1422D6357BCCF004DFBDD0533F2000ca", "0x1422D6357BCCF004DFBDD0533F2000cb", "0x1422D6357BCCF004DFBDD0533F2000cc", "0x1422D6357BCCF004DFBDD0533F2000cd", "0x1422D6357BCCF004DFBDD0533F2000ce", "0x1422D6357BCCF004DFBDD0533F2000cf", "0x1422D6357BCCF004DFBDD0533F2000d0", "0x1422D6357BCCF004DFBDD0533F2000d1", "0x1422D6357BCCF004DFBDD0533F2000d2", "0x1422D6357BCCF004DFBDD0533F2000d3", "0x1422D6357BCCF004DFBDD0533F2000d4", "0x1422D6357BCCF004DFBDD0533F2000d5", "0x1422D6357BCCF004DFBDD0533F2000d6", "0x1422D6357BCCF004DFBDD0533F2000d7", "0x1422D6357BCCF004DFBDD0533F2000d8", "0x1422D6357BCCF004DFBDD0533F2000d9", "0x1422D6357BCCF004DFBDD0533F2000da", "0x1422D6357BCCF004DFBDD0533F2000db", "0x1422D6357BCCF004DFBDD0533F2000dc", "0x1422D6357BCCF004DFBDD0533F2000dd", "0x1422D6357BCCF004DFBDD0533F2000de", "0x1422D6357BCCF004DFBDD0533F2000df", "0x1422D6357BCCF004DFBDD0533F2000e0", "0x1422D6357BCCF004DFBDD0533F2000e1", "0x1422D6357BCCF004DFBDD0533F2000e2", "0x1422D6357BCCF004DFBDD0533F2000e3", "0x1422D6357BCCF004DFBDD0533F2000e4", "0x1422D6357BCCF004DFBDD0533F2000e5", "0x1422D6357BCCF004DFBDD0533F2000e6", "0x1422D6357BCCF004DFBDD0533F2000e7", "0x1422D6357BCCF004DFBDD0533F2000e8", "0x1422D6357BCCF004DFBDD0533F2000e9", "0x1422D6357BCCF004DFBDD0533F2000ea", "0x1422D6357BCCF004DFBDD0533F2000eb", "0x1422D6357BCCF004DFBDD0533F2000ec", "0x1422D6357BCCF004DFBDD0533F2000ed", "0x1422D6357BCCF004DFBDD0533F2000ee", "0x1422D6357BCCF004DFBDD0533F2000ef", "0x1422D6357BCCF004DFBDD0533F2000f0", "0x1422D6357BCCF004DFBDD0533F2000f1", "0x1422D6357BCCF004DFBDD0533F2000f2", "0x1422D6357BCCF004DFBDD0533F2000f3", "0x1422D6357BCCF004DFBDD0533F2000f4", "0x1422D6357BCCF004DFBDD0533F2000f5", "0x1422D6357BCCF004DFBDD0533F2000f6", "0x1422D6357BCCF004DFBDD0533F2000f7", "0x1422D6357BCCF004DFBDD0533F2000f8", "0x1422D6357BCCF004DFBDD0533F2000f9", "0x1422D6357BCCF004DFBDD0533F2000fa", "0x1422D6357BCCF004DFBDD0533F2000fb", "0x1422D6357BCCF004DFBDD0533F2000fc", "0x1422D6357BCCF004DFBDD0533F2000fd", "0x1422D6357BCCF004DFBDD0533F2000fe", "0x1422D6357BCCF004DFBDD0533F2000ff", "0x1422D6357BCCF004DFBDD0533F200100" ], "Generic Tickets", "TICK", "0xFE6d4bC2De2D0b0E6FE47f08A28Ed52F9d052A02", "0xFE6d4bC2De2D0b0E6FE47f08A28Ed52F9d052A02"
    function TicketPro (
        bytes32[] tickets,
        string evName,
        string eventSymbol,
        address organiserAddr,
        address paymasterAddr) public
    {
        //assign some tickets to event organiser
        stormbird = msg.sender;
        organiser = organiserAddr;
        inventory[organiser] = tickets;
        symbol = eventSymbol;
        name = evName;
        paymaster = paymasterAddr;
    }

    function getDecimals() public pure returns(uint)
    {
        return decimals;
    }

    // example: 0, [3, 4], 27, "0x9CAF1C785074F5948310CD1AA44CE2EFDA0AB19C308307610D7BA2C74604AE98", "0x23D8D97AB44A2389043ECB3C1FB29C40EC702282DB6EE1D2B2204F8954E4B451"
    // price is encoded in the server and the msg.value is added to the message digest,
    // if the message digest is thus invalid then either the price or something else in the message is invalid
    function trade(uint256 expiry,
                   uint16[] ticketIndices,
                   uint8 v,
                   bytes32 r,
                   bytes32 s) public payable
    {
        //checks expiry timestamp,
        //if fake timestamp is added then message verification will fail
        require(expiry > block.timestamp || expiry == 0);

        bytes32 message = encodeMessage(msg.value, expiry, ticketIndices);
        address seller = ecrecover(message, v, r, s);

        for(uint i = 0; i < ticketIndices.length; i++)
        { // transfer each individual tickets in the ask order
            uint16 index = ticketIndices[i];
            assert(inventory[seller][index] != bytes32(0)); // 0 means ticket sold.
            inventory[msg.sender].push(inventory[seller][index]);
            // 0 means ticket sold.
            delete inventory[seller][index];
        }
        seller.transfer(msg.value);
        
        emit Trade(seller, ticketIndices, v, r, s);
    }
    
    function loadNewTickets(bytes32[] tickets) public organiserOnly 
    {
        for(uint i = 0; i < tickets.length; i++) 
        {
            inventory[organiser].push(tickets[i]);    
        }
    }

    //anyone can claim this for free, just have to place their address
    function passTo(uint256 expiry,
                    uint16[] ticketIndices,
                    uint8 v,
                    bytes32 r,
                    bytes32 s,
                    address recipient) public payMasterOnly
    {
        require(expiry > block.timestamp || expiry == 0);
        bytes32 message = encodeMessage(0, expiry, ticketIndices);
        address giver = ecrecover(message, v, r, s);
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint16 index = ticketIndices[i];
            //needs to use revert as all changes should be reversed
            //if the user doesnt't hold all the tickets 
            assert(inventory[giver][index] != bytes32(0));
            bytes32 ticket = inventory[giver][index];
            inventory[recipient].push(ticket);
            delete inventory[giver][index];
        }
        
        emit PassTo(ticketIndices, v, r, s, recipient);
    }

    //must also sign in the contractAddress
    function encodeMessage(uint value, uint expiry, uint16[] ticketIndices)
        internal view returns (bytes32)
    {
        bytes memory message = new bytes(84 + ticketIndices.length * 2);
        address contractAddress = getContractAddress();
        for (uint i = 0; i < 32; i++)
        {   // convert bytes32 to bytes[32]
            // this adds the price to the message
            message[i] = byte(bytes32(value << (8 * i)));
        }

        for (i = 0; i < 32; i++)
        {
            message[i + 32] = byte(bytes32(expiry << (8 * i)));
        }

        for(i = 0; i < 20; i++)
        {
            message[64 + i] = byte(bytes20(bytes20(contractAddress) << (8 * i)));
        }

        for (i = 0; i < ticketIndices.length; i++)
        {
            // convert int[] to bytes
            message[84 + i * 2 ] = byte(ticketIndices[i] >> 8);
            message[84 + i * 2 + 1] = byte(ticketIndices[i]);
        }

        return keccak256(message);
    }

    function name() public view returns(string)
    {
        return name;
    }

    function symbol() public view returns(string)
    {
        return symbol;
    }

    function getAmountTransferred() public view returns (uint)
    {
        return numOfTransfers;
    }

    function balanceOf(address _owner) public view returns (bytes32[])
    {
        return inventory[_owner];
    }

    function myBalance() public view returns(bytes32[]){
        return inventory[msg.sender];
    }

    function transfer(address _to, uint16[] ticketIndices) public 
    {
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint index = uint(ticketIndices[i]);
            assert(inventory[msg.sender][index] != bytes32(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[msg.sender][index];
        }
        emit Transfer(_to, ticketIndices);
    }

    function transferFrom(address _from, address _to, uint16[] ticketIndices)
        organiserOnly public
    {
        for(uint i = 0; i < ticketIndices.length; i++)
        {
            uint index = uint(ticketIndices[i]);
            assert(inventory[_from][index] != bytes32(0));
            //pushes each element with ordering
            inventory[_to].push(inventory[msg.sender][index]);
            delete inventory[_from][index];
        }
        
        emit TransferFrom(_from, _to, ticketIndices);
    }

    function endContract() public
    {
        if(msg.sender == stormbird)
        {
            selfdestruct(stormbird);
        }
        else revert();
    }

    function isStormBirdContract() public pure returns (bool) 
    {
        return true; 
    }

    function getContractAddress() public view returns(address)
    {
        return this;
    }

}