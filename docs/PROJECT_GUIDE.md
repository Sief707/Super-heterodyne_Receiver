# AM Superheterodyne Receiver Project

## Architecture
- main.m → orchestrator
- config/ → system parameters
- data/ → input signals
- src/ → system blocks
- utils/ → reusable tools
- tests/ → validation
- results/ → outputs

## Design Philosophy
- Modular functions
- No logic in main
- Clear naming
- Test each block independently

## Workflow
1. Load config
2. Load signals
3. Transmitter
4. Receiver
5. Visualization
6. Testing

## Rules
- No magic numbers
- No long scripts
- One responsibility per function