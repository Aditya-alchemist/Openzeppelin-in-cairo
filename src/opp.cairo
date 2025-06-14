#[starknet::interface]
trait IERC<ContractState> {
    #[abi(embed_v0)]
    fn minting(
        ref self: ContractState,
        recipient: starknet::ContractAddress,
        amount: u256
    );
}

#[starknet::contract]
mod MyERC20Token {
    // NOTE: If you added the entire library as a dependency,
    // use `openzeppelin::token` instead.
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20Impl<ContractState>;
        

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        
        fixed_supply: u256,
        recipient: ContractAddress
    ) {
        let name = "Test";
        let symbol = "TST";
        self.erc20.initializer(name, symbol);
        self.erc20.mint(recipient, fixed_supply);
    }

    #[abi(embed_v0)]
    impl t of super::IERC<ContractState> {
        fn minting(
            ref self: ContractState,
            recipient: ContractAddress,
            amount: u256
        ) {
            self.erc20.mint(recipient, amount);
        }
    }
}