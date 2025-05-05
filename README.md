<p align="center">
  <h3>Bump. Survive. Win.</h3>
</p>

## Setup

1. Clone the repository with submodules:
```bash
git clone --recurse-submodules https://github.com/your-org/bump-fam-sdk.git
```

If you've already cloned the repository without submodules, you can initialize them with:
```bash
git submodule update --init --recursive
```

2. Install dependencies:
```bash
npm install
```

3. Build the project:
```bash
npm run build
```

## Development

### Running Tests
```bash
npm test
```

### Building
```bash
npm run build
```

## Project Structure

- `contracts/` - Move contracts (git submodule)
- `sdk/` - TypeScript SDK
  - `src/` - Source code
  - `test/` - Test files
  - `dist/` - Build output (not in git)

## Contributing

1. Make sure submodules are up to date:
```bash
git submodule update --remote
```

2. Create a new branch for your changes
3. Make your changes
4. Run tests
5. Submit a pull request