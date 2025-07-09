import React from 'react';
import { Edit, Trash2, Mail, MapPin } from 'lucide-react';
import type { Contact } from '../types/contact';

interface ContactCardProps {
  contact: Contact;
  onEdit: (contact: Contact) => void;
  onDelete: (id: string) => void;
}

const ContactCard: React.FC<ContactCardProps> = ({ contact, onEdit, onDelete }) => {
  return (
    <div className="p-6 hover:bg-gray-50 transition-colors">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-4">
            <div className="flex-shrink-0">
              <div className="h-12 w-12 bg-blue-100 rounded-full flex items-center justify-center">
                <span className="text-blue-600 font-semibold text-lg">
                  {contact.first_name.charAt(0)}{contact.last_name.charAt(0)}
                </span>
              </div>
            </div>
            
            <div className="flex-1 min-w-0">
              <div className="flex items-center space-x-2">
                <h3 className="text-lg font-medium text-gray-900">
                  {contact.first_name} {contact.last_name}
                </h3>
              </div>
              
              <div className="mt-1 flex items-center text-sm text-gray-600">
                <Mail className="h-4 w-4 mr-1 flex-shrink-0" />
                <a 
                  href={`mailto:${contact.email}`}
                  className="hover:text-blue-600 transition-colors truncate"
                >
                  {contact.email}
                </a>
              </div>
              
              <div className="mt-1 flex items-center text-sm text-gray-600">
                <MapPin className="h-4 w-4 mr-1 flex-shrink-0" />
                <span className="truncate">
                  {contact.street_address}, {contact.city}, {contact.country}
                </span>
              </div>
            </div>
          </div>
        </div>
        
        <div className="flex items-center space-x-2 ml-4">
          <button
            onClick={() => onEdit(contact)}
            className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-md transition-colors"
            title="Edit contact"
          >
            <Edit className="h-4 w-4" />
          </button>
          <button
            onClick={() => onDelete(contact.id)}
            className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
            title="Delete contact"
          >
            <Trash2 className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ContactCard;
