#[starknet::interface]
trait IERC<ContractState>{
    fn minting(ref self: ContractState,recipient:starknet::ContractAddress,token_uri:Span<felt252>);
}



#[starknet::contract]
mod MyNFTcompo {
    use ERC721Component::InternalTrait;
use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;
      

    impl ERC721MetadataImpl = ERC721Component::ERC721MetadataImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
      token_id:u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress
    ) {
        let name = "MyNFT";
        let symbol = "NFT";
        let base_uri = "https://gateway.pinata.cloud/ipfs/bafybeihhaivmosip2cjsmitl7c4kravijycx7vcroi6khymgmykn2oc6m4";
        let token_id = 1;

        self.erc721.initializer(name, symbol, base_uri);
        self.erc721.mint(recipient, token_id);
        self.token_id.write(token_id);
        
    }

    #[abi(embed_v0)]
    impl t of super::IERC<ContractState>{
            fn minting(ref self: ContractState,recipient:ContractAddress,token_uri:Span<felt252>){
            
                let token_id = self.token_id.read();
                let updated_token_id = token_id + 1;
                self.erc721.safe_mint(recipient, updated_token_id, token_uri);
                self.token_id.write(updated_token_id);
                
            }

    }
}