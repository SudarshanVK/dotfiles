# Pulumi F5 Project Memory

## Configuration File Structure Migration (2026-03-26)

### What Changed
Successfully retrofitted the project to use new file structure:

**File Movements:**
- `data/host_list.yml` → `host_inventory.yml` (root level)
- `data/config.yml` → Split into `config_data/` directory:
  - `config_data/nodes.yml`
  - `config_data/pools.yml`
  - `config_data/irules.yml`
  - `config_data/ciphers.yml`

### Changes Made
1. **utils/helpers/helpers.py**
   - Updated `HOST_LIST_PATH` to point to `host_inventory.yml`
   - Added new `load_config_data()` function that:
     - Loads all YAML files from `config_data/`
     - Merges them into single dictionary
     - Returns config with keys: `nodes`, `pools`, `irules`, `cipher_rules`, `cipher_groups`

2. **utils/resources/stack.py**
   - Removed hardcoded `data/config.yml` paths from both `create_pulumi_program()` and `create_pulumi_import_program()`
   - Imported `load_config_data` from helpers
   - Removed unused `yaml` import

### Verification Results
- ✓ load_config_data() loads all 4 config files correctly
- ✓ Merges into proper config dict with all expected keys
- ✓ load_hosts() loads 2 hosts from host_inventory.yml
- ✓ No breaking changes to resource creation functions

### Key Design Decisions
- Used glob pattern to discover YAML files (sorted alphabetically for consistency)
- Added validation for config_dir and empty configs with proper logging
- Centralized config loading in helpers.py for code reusability
- Removed work_dir dependency from load_config_data (uses project root relative path)
