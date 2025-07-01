import React, { useState, useEffect } from 'react';
import { contactsApi } from '../api';
import type { Contact } from '../types';
import ContactCard from './ContactCard';

const ContactsList: React.FC = () => {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchContacts = async () => {
      try {
        setLoading(true);
        const data = await contactsApi.getContacts();
        setContacts(data);
      } catch (err) {
        setError('Failed to fetch contacts');
        console.error('Error fetching contacts:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchContacts();
  }, []);

  if (loading) {
    return <div className="loading">Loading contacts...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  return (
    <div className="contacts-list">
      <h2>Contacts ({contacts.length})</h2>
      <div className="contacts-grid">
        {contacts.map((contact) => (
          <ContactCard key={contact.id} contact={contact} />
        ))}
      </div>
    </div>
  );
};

export default ContactsList;
