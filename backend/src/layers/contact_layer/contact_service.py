import json
import uuid
from typing import List, Dict, Optional
from dataclasses import dataclass, asdict
from abc import ABC, abstractmethod


@dataclass
class Contact:
    """Contact data model"""

    id: str
    first_name: str
    last_name: str
    email: str
    street_address: str
    city: str
    country: str

    @classmethod
    def from_dict(cls, data: Dict) -> "Contact":
        """Create Contact from dictionary"""
        return cls(**data)

    def to_dict(self) -> Dict:
        """Convert Contact to dictionary"""
        return asdict(self)


class ContactRepository(ABC):
    """Abstract base class for contact repository"""

    @abstractmethod
    def get_all_contacts(self) -> List[Contact]:
        pass

    @abstractmethod
    def get_contact_by_id(self, contact_id: str) -> Optional[Contact]:
        pass

    @abstractmethod
    def create_contact(self, contact: Contact) -> Contact:
        pass

    @abstractmethod
    def update_contact(self, contact: Contact) -> Contact:
        pass

    @abstractmethod
    def delete_contact(self, contact_id: str) -> bool:
        pass


class InMemoryContactRepository(ContactRepository):
    """In-memory implementation for development/testing"""

    def __init__(self):
        self.contacts = {
            "1": Contact(
                id="1",
                first_name="John",
                last_name="Doe",
                email="john.doe@example.com",
                street_address="123 Main St",
                city="New York",
                country="United States",
            ),
            "2": Contact(
                id="2",
                first_name="Jane",
                last_name="Smith",
                email="jane.smith@example.com",
                street_address="456 Oak Ave",
                city="Los Angeles",
                country="United States",
            ),
            "3": Contact(
                id="3",
                first_name="Bob",
                last_name="Johnson",
                email="bob.johnson@example.com",
                street_address="789 Pine Rd",
                city="Chicago",
                country="United States",
            ),
        }

    def get_all_contacts(self) -> List[Contact]:
        return list(self.contacts.values())

    def get_contact_by_id(self, contact_id: str) -> Optional[Contact]:
        return self.contacts.get(contact_id)

    def create_contact(self, contact: Contact) -> Contact:
        if not contact.id:
            contact.id = str(uuid.uuid4())
        self.contacts[contact.id] = contact
        return contact

    def update_contact(self, contact: Contact) -> Contact:
        if contact.id not in self.contacts:
            raise ValueError(f"Contact with id {contact.id} not found")
        self.contacts[contact.id] = contact
        return contact

    def delete_contact(self, contact_id: str) -> bool:
        if contact_id in self.contacts:
            del self.contacts[contact_id]
            return True
        return False


class ContactService:
    """Business logic for contact operations"""

    def __init__(self, repository: ContactRepository):
        self.repository = repository

    def list_contacts(self) -> List[Dict]:
        """Get all contacts"""
        contacts = self.repository.get_all_contacts()
        return [contact.to_dict() for contact in contacts]

    def get_contact(self, contact_id: str) -> Optional[Dict]:
        """Get a single contact by ID"""
        contact = self.repository.get_contact_by_id(contact_id)
        return contact.to_dict() if contact else None

    def create_contact(self, contact_data: Dict) -> Dict:
        """Create a new contact"""
        # Validation
        self._validate_contact_data(contact_data)

        # Generate ID if not provided
        if "id" not in contact_data or not contact_data["id"]:
            contact_data["id"] = str(uuid.uuid4())

        contact = Contact.from_dict(contact_data)
        created_contact = self.repository.create_contact(contact)
        return created_contact.to_dict()

    def update_contact(self, contact_id: str, contact_data: Dict) -> Dict:
        """Update an existing contact"""
        # Validation
        self._validate_contact_data(contact_data)

        # Ensure ID matches
        contact_data["id"] = contact_id

        contact = Contact.from_dict(contact_data)
        updated_contact = self.repository.update_contact(contact)
        return updated_contact.to_dict()

    def delete_contact(self, contact_id: str) -> bool:
        """Delete a contact"""
        return self.repository.delete_contact(contact_id)

    def _validate_contact_data(self, contact_data: Dict) -> None:
        """Validate contact data"""
        required_fields = [
            "first_name",
            "last_name",
            "email",
            "street_address",
            "city",
            "country",
        ]

        for field in required_fields:
            if field not in contact_data or not contact_data[field]:
                raise ValueError(f"Missing required field: {field}")

        # Basic email validation
        email = contact_data["email"]
        if "@" not in email or "." not in email.split("@")[1]:
            raise ValueError("Invalid email format")


# Global service instance for Lambda functions
contact_service = ContactService(InMemoryContactRepository())
