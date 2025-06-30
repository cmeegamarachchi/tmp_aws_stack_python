import React, { useState, useEffect } from 'react'
import { authService } from '../services/auth'

interface ApiResponse {
  message: string
  timestamp: string
  user?: {
    id: string
    username: string
    email: string
  }
  [key: string]: any
}

function Dashboard() {
  const [apiData, setApiData] = useState<ApiResponse | null>(null)
  const [userProfile, setUserProfile] = useState<ApiResponse | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const makeAuthenticatedRequest = async (path: string) => {
    setLoading(true)
    setError(null)
    
    try {
      const response = await authService.apiCall(path)
      
      if (!response.ok) {
        if (response.status === 401) {
          throw new Error('Authentication failed - please sign in again')
        }
        throw new Error(`API request failed: ${response.status} ${response.statusText}`)
      }

      const data = await response.json() as ApiResponse
      return data
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Failed to fetch data'
      setError(errorMessage)
      throw err
    } finally {
      setLoading(false)
    }
  }

  const fetchHello = async () => {
    try {
      const data = await makeAuthenticatedRequest('/hello')
      setApiData(data)
    } catch (err) {
      console.error('Failed to fetch hello:', err)
    }
  }

  const fetchUserProfile = async () => {
    try {
      const data = await makeAuthenticatedRequest('/user/profile')
      setUserProfile(data)
    } catch (err) {
      console.error('Failed to fetch user profile:', err)
    }
  }

  const fetchProtected = async () => {
    try {
      const data = await makeAuthenticatedRequest('/protected')
      setApiData(data)
    } catch (err) {
      console.error('Failed to fetch protected data:', err)
    }
  }

  useEffect(() => {
    // Auto-fetch hello data on component mount
    fetchHello()
  }, [])

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <p>This is your secure dashboard. Authentication is handled by API Gateway with Cognito.</p>
      <p>All requests below are automatically authenticated - try them out!</p>
      
      <div className="api-section">
        <h2>API Endpoints</h2>
        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
          <button onClick={fetchHello} disabled={loading} className="btn btn-primary">
            {loading ? 'Loading...' : 'Fetch Hello'}
          </button>
          <button onClick={fetchProtected} disabled={loading} className="btn btn-secondary">
            {loading ? 'Loading...' : 'Fetch Protected Data'}
          </button>
          <button onClick={fetchUserProfile} disabled={loading} className="btn btn-secondary">
            {loading ? 'Loading...' : 'Fetch User Profile'}
          </button>
        </div>
        
        {error && (
          <div className="error">
            <h3>Error:</h3>
            <p>{error}</p>
            <small>Note: If you see authentication errors, try refreshing the page to get a new token.</small>
          </div>
        )}
        
        {apiData && (
          <div className="api-response">
            <h3>API Response:</h3>
            <pre>{JSON.stringify(apiData, null, 2)}</pre>
          </div>
        )}

        {userProfile && (
          <div className="api-response">
            <h3>User Profile:</h3>
            <pre>{JSON.stringify(userProfile, null, 2)}</pre>
          </div>
        )}
      </div>

      <div className="info-section" style={{ marginTop: '2rem', padding: '1rem', backgroundColor: '#e3f2fd', borderRadius: '8px' }}>
        <h3>🔐 How Authentication Works</h3>
        <ul style={{ textAlign: 'left', margin: '0.5rem 0' }}>
          <li><strong>No AWS Amplify</strong> - Pure browser-based OAuth flow</li>
          <li><strong>API Gateway</strong> handles all authentication using Cognito User Pool authorizers</li>
          <li><strong>No manual token validation</strong> in Lambda - AWS does it automatically</li>
          <li><strong>Invalid requests</strong> are rejected at the gateway before reaching your Lambda</li>
          <li><strong>User information</strong> is automatically extracted and passed to Lambda</li>
          <li><strong>Scalable and secure</strong> - perfect for production applications</li>
        </ul>
      </div>
    </div>
  )
}

export default Dashboard

export default Dashboard
