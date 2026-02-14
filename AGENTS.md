# AI Agent Guidelines for Intrusion

Intrusion is a game with a Haxe-based website and client.

Work exclusively in [TDD](.agents/rules/tdd.md).

## Standards
Detailed rules in [`.agents/rules/`](.agents/rules/):
- **Clean code:** [`.agents/rules/clean-code.md`](.agents/rules/clean-code.md)
- **Naming:** [`.agents/rules/naming-conventions.md`](.agents/rules/naming-conventions.md)
- **Testing:** [`.agents/rules/testing-standards.md`](.agents/rules/testing-standards.md), [`.agents/rules/testing-unit.md`](.agents/rules/testing-unit.md), [`.agents/rules/testing-integration.md`](.agents/rules/testing-integration.md)
- **TDD:** [`.agents/rules/tdd.md`](.agents/rules/tdd.md)
- **Debugging:** [`.agents/rules/debug.md`](.agents/skills/debug/SKILL.md)

## Tools
- Stack: Haxe 4.3 + Node.js + Redis.
- Outputs:
  - Browser client bundle: `www/client.js` (from `client.hxml`).
  - Node website server: `website-bin/website.js` (from `website.hxml`).
- Main code roots:
  - Shared game/domain code: `com/`
  - Client code: `client/src/`
  - Website/server code: `website/`

# Commands
Run tests: `mise test`