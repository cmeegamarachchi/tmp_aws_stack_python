# Local Development with SAM

This setup allows you to test your Lambda functions locally using SAM CLI. The TypeScript code from `api/src` is compiled and executed for local testing.

## Prerequisites

- AWS SAM CLI installed
- Node.js 22.x
- npm dependencies installed (`npm install`)

## Local Development Commands

### Start Local API Gateway
```bash
npm run sam:local
# This will build TypeScript and start local API at http://localhost:3000
```

This will start a local API Gateway at `http://localhost:3000` with the following endpoints:
- GET `http://localhost:3000/contacts`
- GET `http://localhost:3000/countries`

### Invoke Individual Functions

#### Test Contacts Function
```bash
npm run sam:invoke:contacts
```

#### Test Countries Function
```bash
npm run sam:invoke:countries
```

### Development Workflow

1. **Make changes** to your TypeScript files in `src/`
2. **Run tests** using the npm scripts above (they automatically build)
3. **Code is automatically compiled** from TypeScript to JavaScript before testing

### Manual Commands

If you want to run SAM commands directly:
```bash
# Build TypeScript first
npm run build

# Then run SAM commands
sam build
sam local start-api
sam local invoke ContactsFunction -e test-events/contacts.json
sam local invoke CountriesFunction -e test-events/countries.json
```

## How It Works

1. **TypeScript Compilation**: Your TypeScript code in `src/` is compiled to JavaScript in `dist/`
2. **SAM Build**: SAM builds the functions from the `dist/` folder 
3. **Local Execution**: SAM runs the compiled JavaScript with all dependencies
4. **Hot Development**: Use `npm run sam:*` commands that rebuild automatically

## File Structure

```
api/
├── src/
│   ├── handlers/
│   │   ├── contacts.ts          # Your TypeScript handlers
│   │   └── countries.ts
│   ├── data.ts
│   └── types.ts
├── dist/                        # Compiled JavaScript (auto-generated)
│   ├── handlers/
│   │   ├── contacts.js
│   │   └── countries.js
│   └── package.json             # Dependencies for SAM
├── test-events/
│   ├── contacts.json            # Test events
│   └── countries.json
├── template.yaml                # SAM template
├── samconfig.toml              # SAM configuration
└── package.json                # Build scripts and dependencies
```

## Development Tips

- Use `npm run build:watch` to automatically recompile TypeScript on changes
- The `npm run sam:*` scripts automatically build before running SAM commands
- Test events in `test-events/` simulate API Gateway requests
- Source code changes require a rebuild (automatic with npm scripts)

## Example Test Results

Running `npm run sam:invoke:contacts` successfully returns:
```json
{
  "statusCode": 200,
  "headers": {...},
  "body": "{\"success\":true,\"data\":[...]}"
}
```
