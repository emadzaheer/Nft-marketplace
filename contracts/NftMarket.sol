// SPDX-License-Identifier:MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";             //lib to count the num of nfts
import "hardhat/console.sol";
 
contract DeMarketplace is ERC721URIStorage{    
    using Counters for Counters.Counter;                         //how to use a library

    event MarketItemCreated (uint256 indexed tokenId, address owner, uint price, address payable seller, bool sold  );
    
    Counters.Counter private _tokenIds;      //track of tokens
    Counters.Counter private _tokensSold;    //track of token sold
    uint256 listingPrice = 0.00075 ether;     //listing price charged at every listing
    address payable owner;

    struct S_MarketItem{
        uint256 tokenId;
        address owner;
        uint price;
        address payable seller;
        bool sold;
    } 
    mapping(uint256 => S_MarketItem) private m_marketItems;         //id to market item struct- record of market items and their details     


    constructor () ERC721("DeMarkt", "DMT") {
        owner = payable(msg.sender);   
    }

    modifier isOwner(){
        require(msg.sender == owner, "only the owner can modify this");
        _;
    }


    function updateListingPrice(uint256 _listingPrice) public payable isOwner {
        listingPrice = _listingPrice; 
    }    


    function getListingPrice() public view returns(uint256){ 
        return listingPrice;
    }


    function getLatestListedToken() public view returns(S_MarketItem memory){
        return m_marketItems[_tokenIds.current()];
    }

    
    function createToken(string memory _tokenURI, uint256 _tokenPrice ) public returns (uint256) {
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();                                                                                   //tip: dont forget the brackets
        _mint(msg.sender, newTokenId );
        _setTokenURI(newTokenId, _tokenURI);

        createMarketItem(newTokenId, _tokenPrice);
        return newTokenId;
    }


    function createMarketItem(uint256 _tokenId, uint256 _price) private {          //used by the create token func
        require( _price >= listingPrice, "price shoud be greater than listing price");

        m_marketItems[_tokenId] = S_MarketItem(
            _tokenId, 
            payable( address(this) ),       //owner
            _price,
            payable(msg.sender),            //seller
            false
        );

        _transfer(msg.sender, address(this), _tokenId);                                               //we send the asset to the contract when we create it.
        
        emit MarketItemCreated (_tokenId, address(this), _price, payable(msg.sender), false  );   
    }
    

    function buyMarketItem(uint256 _tokenId) public payable {
        
        uint256 price = m_marketItems[_tokenId].price;
        address seller = m_marketItems[_tokenId].seller;
        require( msg.sender != seller, "seller cannot buy");
        require( msg.value >= price + listingPrice, "insufficient funds" );
        
        m_marketItems[_tokenId].sold    = true;
        m_marketItems[_tokenId].owner   = payable(msg.sender);     //function caller who buys the item is now the owner
        m_marketItems[_tokenId].seller  = payable(msg.sender);   //seller does not exist now 
        
        _tokensSold.increment();
        _transfer(address(this), msg.sender, _tokenId);     //

        payable(owner).transfer(listingPrice);              //comission charged by the main owner of marketplace
        payable(seller).transfer(price); 
    }

    /////////////////////////////////////////////////////////////
    function resellMarketItem(uint256 _tokenId, uint256 _price ) public payable {
        require(_price > 0);
        require(msg.sender == m_marketItems[_tokenId].owner, "you should be the owner to resell this item");
        require(m_marketItems[_tokenId].sold == true, "you can't resell an item that is already on sale");

        m_marketItems[_tokenId].sold    = false;
        m_marketItems[_tokenId].owner   = payable(address(this));
        m_marketItems[_tokenId].seller  = payable(msg.sender);
        m_marketItems[_tokenId].price   = _price;

        _tokensSold.decrement();

        _transfer(msg.sender, address(this), _tokenId);    
    }


    function getUnsoldItems() public view returns( S_MarketItem[] memory ) {
        uint256 totalNFTs = _tokenIds.current();                                    //total tokens created so far
        uint256 totalUnsoldNFTs = _tokenIds.current()  - _tokensSold.current();     //total unsold
        uint256 curPtr = 0;

        S_MarketItem[] memory unsoldItems = new S_MarketItem[](totalUnsoldNFTs);    // array with size of unsold nfts

        for (uint i=0; i < totalNFTs; i++){                                         // run loop till < unsolditems
            if (m_marketItems[i+1].owner == address(this)) {                        // if struct has owner == contract, then 
                uint256 currentId = i + 1;                                          // 
                S_MarketItem storage currentItem = m_marketItems[currentId];
                unsoldItems[curPtr] = currentItem;
                curPtr += 1; 
            }
        }
        return unsoldItems;
    }

    function purchased_items() public view returns(S_MarketItem[] memory) {
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint i= 0 ; i < totalCount; i++ ){
            if( m_marketItems[i+1].owner == msg.sender){
                itemCount += 1;
            }
        }

        S_MarketItem[] memory Items = new S_MarketItem[](itemCount);
        for (uint256 i= 0 ; i < totalCount; i++){
            if (m_marketItems[i+1].owner == msg.sender){
                uint256 currentId = i + 1;
                S_MarketItem storage currentItem = m_marketItems[currentId];
                Items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }       
        return Items;
    }

    function get_seller_items() public view returns(S_MarketItem[] memory) {
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint i= 0 ; i < totalCount; i++ ){
            if( m_marketItems[i+1].seller == msg.sender){
                itemCount += 1;
            }
        }

        S_MarketItem[] memory Items = new S_MarketItem[](itemCount);
        for (uint256 i= 0 ; i < totalCount; i++){
            if (m_marketItems[i+1].seller == msg.sender){
                uint256 currentId = i + 1;
                S_MarketItem storage currentItem = m_marketItems[currentId];
                Items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }       
        return Items;
    }
}
