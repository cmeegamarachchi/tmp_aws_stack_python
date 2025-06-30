import React from 'react'
import { authService } from '../services/auth'

function Login() {
  const handleLogin = () => {
    authService.login()
  }

  return (
    <div className="login-container">
      <div className="login-card">
        <h1>AWS Stack App</h1>
        <p>A secure web application with AWS Cognito authentication</p>
        
        <div className="login-content">
          <h2>Sign In</h2>
          <p>Click below to authenticate with AWS Cognito.</p>
          <p>You'll be redirected to a secure AWS-hosted login page.</p>
          
          <button onClick={handleLogin} className="btn btn-primary login-btn">
            Sign In with AWS Cognito
          </button>
        </div>

        <div className="features">
          <h3>🔐 Secure Authentication</h3>
          <ul>
            <li>✅ AWS Cognito User Pools</li>
            <li>✅ OAuth 2.0 / OpenID Connect</li>
            <li>✅ API Gateway protection</li>
            <li>✅ No passwords stored locally</li>
          </ul>
        </div>
      </div>
    </div>
  )
}

export default Login
