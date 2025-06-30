import React, { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { authService } from './services/auth'
import Home from './components/Home'
import Dashboard from './components/Dashboard'
import Login from './components/Login'
import './App.css'

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [user, setUser] = useState(null)

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Handle OAuth callback if present
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('code')) {
          const success = await authService.handleCallback();
          if (success) {
            // Redirect to clean URL after successful auth
            window.history.replaceState({}, document.title, '/dashboard');
          }
        }

        // Check authentication status
        const authenticated = authService.isAuthenticated();
        setIsAuthenticated(authenticated);
        
        if (authenticated) {
          const currentUser = authService.getCurrentUser();
          setUser(currentUser);
        }
      } catch (error) {
        console.error('Auth check failed:', error);
        setIsAuthenticated(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, []);

  const handleLogout = () => {
    authService.logout();
  };

  if (isLoading) {
    return (
      <div className="App">
        <div className="loading">
          <div className="spinner"></div>
          <span>Loading...</span>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <Router>
        <div className="App">
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="*" element={<Navigate to="/login" replace />} />
          </Routes>
        </div>
      </Router>
    );
  }

  return (
    <Router>
      <div className="App">
        <nav className="navbar">
          <h1>AWS Stack App</h1>
          <div className="nav-items">
            <span>Welcome, {user?.username || user?.email}</span>
            <button onClick={handleLogout}>Sign out</button>
          </div>
        </nav>
        <main>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

export default App
