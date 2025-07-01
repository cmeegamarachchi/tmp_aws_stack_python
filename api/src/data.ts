import { Contact, Country } from "./types";

export const mockContacts: Contact[] = [
  {
    id: "1",
    first_name: "John",
    last_name: "Doe",
    email: "john.doe@example.com",
    street_address: "123 Main St",
    city: "New York",
    country: "United States",
  },
  {
    id: "2",
    first_name: "Jane",
    last_name: "Smith",
    email: "jane.smith@example.com",
    street_address: "456 Oak Ave",
    city: "Toronto",
    country: "Canada",
  },
  {
    id: "3",
    first_name: "Carlos",
    last_name: "Rodriguez",
    email: "carlos.rodriguez@example.com",
    street_address: "789 Pine Rd",
    city: "Madrid",
    country: "Spain",
  },
  {
    id: "4",
    first_name: "Marie",
    last_name: "Dubois",
    email: "marie.dubois@example.com",
    street_address: "321 Elm St",
    city: "Paris",
    country: "France",
  },
  {
    id: "5",
    first_name: "Yuki",
    last_name: "Tanaka",
    email: "yuki.tanaka@example.com",
    street_address: "654 Cherry Blvd",
    city: "Tokyo",
    country: "Japan",
  },
];

export const mockCountries: Country[] = [
  { id: "1", name: "United States" },
  { id: "2", name: "Canada" },
  { id: "3", name: "United Kingdom" },
  { id: "4", name: "France" },
  { id: "5", name: "Germany" },
  { id: "6", name: "Spain" },
  { id: "7", name: "Italy" },
  { id: "8", name: "Japan" },
  { id: "9", name: "Australia" },
  { id: "10", name: "Brazil" },
];
