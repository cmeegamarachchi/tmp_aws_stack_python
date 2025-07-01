import React from 'react';
import type { Contact } from '../types';

interface ContactCardProps {
  contact: Contact;
}

const ContactCard: React.FC<ContactCardProps> = ({ contact }) => {
  return (
    <div className="contact-card">
      <div className="contact-header">
        <h3>{contact.first_name} {contact.last_name}</h3>
        <span className="contact-id">ID: {contact.id}</span>
      </div>
      <div className="contact-details">
        <p><strong>Email:</strong> {contact.email}</p>
        <p><strong>Address:</strong> {contact.street_address}</p>
        <p><strong>City:</strong> {contact.city}</p>
        <p><strong>Country:</strong> {contact.country}</p>
      </div>
    </div>
  );
};

export default ContactCard;
