import axios from "axios";
import type { Contact, Country, ApiResponse } from "./types";

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:3001";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

export const contactsApi = {
  getContacts: async (): Promise<Contact[]> => {
    const response = await api.get<ApiResponse<Contact[]>>("/contacts");
    return response.data.data;
  },
};

export const countriesApi = {
  getCountries: async (): Promise<Country[]> => {
    const response = await api.get<ApiResponse<Country[]>>("/countries");
    return response.data.data;
  },
};

export default api;
