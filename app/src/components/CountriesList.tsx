import React, { useState, useEffect } from 'react';
import { countriesApi } from '../api';
import type { Country } from '../types';

const CountriesList: React.FC = () => {
  const [countries, setCountries] = useState<Country[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCountries = async () => {
      try {
        setLoading(true);
        const data = await countriesApi.getCountries();
        setCountries(data);
      } catch (err) {
        setError('Failed to fetch countries');
        console.error('Error fetching countries:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchCountries();
  }, []);

  if (loading) {
    return <div className="loading">Loading countries...</div>;
  }

  if (error) {
    return <div className="error">{error}</div>;
  }

  return (
    <div className="countries-list">
      <h2>Countries ({countries.length})</h2>
      <div className="countries-grid">
        {countries.map((country) => (
          <div key={country.id} className="country-card">
            <span className="country-id">ID: {country.id}</span>
            <h3>{country.name}</h3>
          </div>
        ))}
      </div>
    </div>
  );
};

export default CountriesList;
