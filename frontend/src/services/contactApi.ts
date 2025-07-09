import axios from "axios";
import type { Contact, ApiResponse } from "../types/contact";

// This will be configurable for different environments
const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:3001/dev";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

export const contactApi = {
  // Get all contacts
  getContacts: async (): Promise<Contact[]> => {
    const response = await api.get<ApiResponse<Contact[]>>("/contacts");
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    throw new Error(response.data.error || "Failed to fetch contacts");
  },

  // Get a single contact
  getContact: async (id: string): Promise<Contact> => {
    const response = await api.get<ApiResponse<Contact>>(`/contacts/${id}`);
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    throw new Error(response.data.error || "Failed to fetch contact");
  },

  // Create a new contact
  createContact: async (contact: Omit<Contact, "id">): Promise<Contact> => {
    const response = await api.post<ApiResponse<Contact>>("/contacts", contact);
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    throw new Error(response.data.error || "Failed to create contact");
  },

  // Update an existing contact
  updateContact: async (id: string, contact: Omit<Contact, "id">): Promise<Contact> => {
    const response = await api.put<ApiResponse<Contact>>(`/contacts/${id}`, contact);
    if (response.data.success && response.data.data) {
      return response.data.data;
    }
    throw new Error(response.data.error || "Failed to update contact");
  },

  // Delete a contact
  deleteContact: async (id: string): Promise<void> => {
    const response = await api.delete<ApiResponse<any>>(`/contacts/${id}`);
    if (!response.data.success) {
      throw new Error(response.data.error || "Failed to delete contact");
    }
  },
};
