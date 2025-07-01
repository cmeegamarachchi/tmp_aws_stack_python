export interface Contact {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  street_address: string;
  city: string;
  country: string;
}

export interface Country {
  id: string;
  name: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}
