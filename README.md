# Foundry Chainlink PriceFeed Vault

A robust Web3 Vault smart contract built with **Foundry** and **Solidity**. The vault accepts Ether (ETH) deposits while maintaining internal balance accounting referenced in **USD** using **Chainlink Data Feeds**.

---

## 🏛️ Features

* **ETH Deposits & Conversions:** Deposit ETH and automatically log internal user balance in USD using standard 18-decimal precision.
* **Chainlink Integration:** Real-time ETH/USD price conversion via Chainlink's `AggregatorV3Interface`.
* **Security & Gas Optimization:**
  * Custom Errors (`VaultConverter__NotOwner`, `VaultConverter__DepositZero`, etc.) for gas efficiency.
  * Access control restricting withdrawal capability exclusively to the contract owner.
  * Safe contract design preventing unhandled ETH transfers via `receive()` and `fallback()` functions.
* **Comprehensive Testing Suite:**
  * **Unit Tests with Mocks:** Offline testing leveraging `MockV3Aggregator`.
  * **Integration Tests:** Forking Ethereum Mainnet using real Chainlink Oracles.

---

## 📐 Architecture & Design Patterns

This project implements key Web3 smart contract design patterns:

1. **Pull over Push:** Prevents Denial of Service (DoS) attacks by decoupling deposit accounting from automated external execution. Users or owners interact directly with isolated withdrawal logic.
2. **Oracle Aggregator Pattern:** Decouples price feed data ingestion from internal execution logic by receiving `AggregatorV3Interface` addresses dynamically via constructor injection.
3. **Immutable Storage & Custom Errors:** Gas optimization techniques ensuring fixed state references (`i_owner`, `i_priceFeed`) are stored directly in bytecode and error handling uses selectors instead of expensive string reverts.

---

## 🛠️ Prerequisites & Installation

### Prerequisites
* [Git](https://git-scm.com/)
* [Foundry / Forge](https://getfoundry.sh/)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/Foundry-Chainlink-PriceFeed-Vault.git
   cd Foundry-Chainlink-PriceFeed-Vault
   ```

2. **Install dependencies:**
    ```bash
    git clone https://github.com/smartcontractkit/chainlink-brownie-contracts lib/chainlink-brownie-contracts
    ```

3. **Build the project:**
    ```bash
    forge build
    ```

---

## ⚙️ Environment Setup
To run integration tests using Mainnet Forking, create a .env file in the root directory:
```bash 
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_KEY
```

Then load the environment variables before testing:
```bash 
source .env
```

---

## 🧪 Running Tests

1. **Unit Tests (Using Mocks):** Run unit tests locally using the mock price feed without requiring an internet connection or RPC endpoint:
```bash 
  forge test --match-contract MockVaultConverterTest -vvv
```

2. **Integration Tests (Mainnet Forking):** Execute integration tests against a local fork of Ethereum Mainnet fetching real live Chainlink price feeds:
```bash 
  forge test --fork-url $MAINNET_RPC_URL --match-contract ForkVaultConverterTest -vvv
```

3. **Run All Tests**

```bash 
  forge test -vvv
```

---

## 📂 Project Structure
```text 
├── src/
│   └── VaultConverter.sol          # Main Vault logic & Chainlink integration
├── test/
│   ├── MockVaultConverter.t.sol    # Unit tests using Mock Aggregator
│   ├── ForkVaultConverter.t.sol    # Mainnet fork integration tests
│   └── mock/
│       └── MockV3Aggregator.sol    # Chainlink Mock implementation
├── .env.example                    # Sample environment variables
├── remappings.txt                  # Import mappings for Solidity compiler
└── foundry.toml                    # Foundry configuration file
```

---

## 📄 License

This project is licensed under the MIT License.