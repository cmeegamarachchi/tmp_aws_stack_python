import { useState } from 'react';
import ContactsList from './components/ContactsList';
import CountriesList from './components/CountriesList';
import './App.css';

function App() {
  const [activeTab, setActiveTab] = useState<'contacts' | 'countries'>('contacts');

  return (
    <div className="app">
      <header className="app-header">
        <h1>Contact Management System</h1>
        <nav className="nav-tabs">
          <button
            className={`tab ${activeTab === 'contacts' ? 'active' : ''}`}
            onClick={() => setActiveTab('contacts')}
          >
            Contacts
          </button>
          <button
            className={`tab ${activeTab === 'countries' ? 'active' : ''}`}
            onClick={() => setActiveTab('countries')}
          >
            Countries
          </button>
        </nav>
      </header>
      <main className="app-main">
        {activeTab === 'contacts' && <ContactsList />}
        {activeTab === 'countries' && <CountriesList />}
      </main>
    </div>
  );
}

export default App;
