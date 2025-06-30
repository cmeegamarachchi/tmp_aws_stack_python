import React from 'react'
import { Link } from 'react-router-dom'

function Home() {
  return (
    <div className="home">
      <h1>Welcome to AWS Stack App</h1>
      <p>This is a secure web application built with React, AWS Lambda, and Cognito authentication.</p>
      <div className="home-actions">
        <Link to="/dashboard" className="btn btn-primary">
          Go to Dashboard
        </Link>
      </div>
    </div>
  )
}

export default Home
