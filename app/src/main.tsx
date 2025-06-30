import React from 'react'
import ReactDOM from 'react-dom/client'
import { authService } from './services/auth'
import App from './App.tsx'
import './index.css'

// Configure authentication
const authConfig = {
  userPoolId: import.meta.env.VITE_USER_POOL_ID || '',
  clientId: import.meta.env.VITE_USER_POOL_CLIENT_ID || '',
  cognitoDomain: import.meta.env.VITE_OAUTH_DOMAIN || '',
  redirectUri: window.location.origin + '/',
  apiGatewayUrl: import.meta.env.VITE_API_GATEWAY_URL || ''
}

authService.init(authConfig)

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
