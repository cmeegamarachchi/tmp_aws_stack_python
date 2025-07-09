# Contact Management API

This directory contains the Lambda functions and layers for the Contact Management API.

## Structure

```
backend/
├── src/
│   ├── layers/
│   │   └── contact_layer/
│   │       ├── __init__.py
│   │       └── contact_service.py    # Business logic and data models
│   └── lambda_functions/
│       ├── list_contacts.py          # GET /contacts
│       ├── get_contact.py           # GET /contacts/{id}
│       ├── create_contact.py        # POST /contacts
│       ├── update_contact.py        # PUT /contacts/{id}
│       └── delete_contact.py        # DELETE /contacts/{id}
├── template.yaml                    # SAM template for testing
└── requirements.txt                 # Python dependencies
```

## Testing with SAM

### Prerequisites
- AWS CLI configured
- SAM CLI installed
- Docker running

### Commands

1. **Build the application:**
   ```bash
   sam build
   ```

2. **Start local API:**
   ```bash
   sam local start-api --port 3001
   ```

3. **Test individual functions:**
   ```bash
   # Test list contacts
   sam local invoke ListContactsFunction

   # Test create contact
   echo '{"body": "{\"first_name\":\"Test\",\"last_name\":\"User\",\"email\":\"test@example.com\",\"street_address\":\"123 Test St\",\"city\":\"Test City\",\"country\":\"Test Country\"}"}' | sam local invoke CreateContactFunction
   ```

### API Endpoints

When running locally with SAM:

- `GET http://localhost:3001/contacts` - List all contacts
- `GET http://localhost:3001/contacts/{id}` - Get a specific contact
- `POST http://localhost:3001/contacts` - Create a new contact
- `PUT http://localhost:3001/contacts/{id}` - Update a contact
- `DELETE http://localhost:3001/contacts/{id}` - Delete a contact

## Layer Architecture

The contact layer (`contact_layer`) contains:

- **Contact Model**: Data structure for contacts
- **ContactRepository**: Abstract interface for data access
- **InMemoryContactRepository**: Implementation using in-memory storage
- **ContactService**: Business logic for CRUD operations

This layered architecture allows for easy testing and future database integration.
