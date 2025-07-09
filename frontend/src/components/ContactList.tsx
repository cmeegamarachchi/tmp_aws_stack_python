import React, { useState, useEffect } from 'react';
import { Plus, Search, Edit, Trash2, User } from 'lucide-react';
import type { Contact } from '../types/contact';
import { contactApi } from '../services/contactApi';
import ContactForm from './ContactForm';
import ContactCard from './ContactCard';

const ContactList: React.FC = () => {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [filteredContacts, setFilteredContacts] = useState<Contact[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingContact, setEditingContact] = useState<Contact | null>(null);

  useEffect(() => {
    loadContacts();
  }, []);

  useEffect(() => {
    filterContacts();
  }, [contacts, searchTerm]);

  const loadContacts = async () => {
    try {
      setLoading(true);
      const data = await contactApi.getContacts();
      setContacts(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load contacts');
    } finally {
      setLoading(false);
    }
  };

  const filterContacts = () => {
    if (!searchTerm) {
      setFilteredContacts(contacts);
      return;
    }

    const filtered = contacts.filter(contact =>
      contact.first_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contact.last_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contact.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contact.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
      contact.country.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredContacts(filtered);
  };

  const handleCreateContact = async (contactData: Omit<Contact, 'id'>) => {
    try {
      const newContact = await contactApi.createContact(contactData);
      setContacts(prev => [...prev, newContact]);
      setShowForm(false);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create contact');
    }
  };

  const handleUpdateContact = async (contactData: Omit<Contact, 'id'>) => {
    if (!editingContact) return;

    try {
      const updatedContact = await contactApi.updateContact(editingContact.id, contactData);
      setContacts(prev => prev.map(c => c.id === editingContact.id ? updatedContact : c));
      setEditingContact(null);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update contact');
    }
  };

  const handleDeleteContact = async (id: string) => {
    if (!confirm('Are you sure you want to delete this contact?')) return;

    try {
      await contactApi.deleteContact(id);
      setContacts(prev => prev.filter(c => c.id !== id));
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to delete contact');
    }
  };

  const handleEditContact = (contact: Contact) => {
    setEditingContact(contact);
  };

  const handleCancelEdit = () => {
    setEditingContact(null);
    setShowForm(false);
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Contact Manager</h1>
        <p className="text-gray-600">Manage your contacts with ease</p>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-6">
          {error}
        </div>
      )}

      {(showForm || editingContact) && (
        <div className="mb-8">
          <ContactForm
            contact={editingContact}
            onSubmit={editingContact ? handleUpdateContact : handleCreateContact}
            onCancel={handleCancelEdit}
          />
        </div>
      )}

      {!showForm && !editingContact && (
        <div className="mb-6">
          <div className="flex flex-col sm:flex-row gap-4 items-center justify-between">
            <div className="relative flex-1 max-w-lg">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-5 w-5" />
              <input
                type="text"
                placeholder="Search contacts..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
            <button
              onClick={() => setShowForm(true)}
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition-colors"
            >
              <Plus className="h-5 w-5" />
              Add Contact
            </button>
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        {filteredContacts.length === 0 ? (
          <div className="text-center py-12">
            <User className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No contacts found</h3>
            <p className="text-gray-600 mb-4">
              {searchTerm ? 'Try adjusting your search criteria.' : 'Get started by adding your first contact.'}
            </p>
            {!searchTerm && (
              <button
                onClick={() => setShowForm(true)}
                className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg inline-flex items-center gap-2"
              >
                <Plus className="h-5 w-5" />
                Add First Contact
              </button>
            )}
          </div>
        ) : (
          <div className="divide-y divide-gray-200">
            {filteredContacts.map((contact) => (
              <ContactCard
                key={contact.id}
                contact={contact}
                onEdit={handleEditContact}
                onDelete={handleDeleteContact}
              />
            ))}
          </div>
        )}
      </div>

      <div className="mt-6 text-sm text-gray-500 text-center">
        {filteredContacts.length > 0 && (
          <p>Showing {filteredContacts.length} of {contacts.length} contacts</p>
        )}
      </div>
    </div>
  );
};

export default ContactList;
