// Authentication service for Cognito OAuth flow
export interface AuthConfig {
  userPoolId: string;
  clientId: string;
  cognitoDomain: string;
  redirectUri: string;
  apiGatewayUrl: string;
}

export interface UserInfo {
  sub: string;
  email?: string;
  username?: string;
  given_name?: string;
  family_name?: string;
}

class AuthService {
  private config: AuthConfig | null = null;
  private tokenCheckInterval: number | null = null;

  init(config: AuthConfig) {
    this.config = config;
    this.startTokenRefreshCheck();
  }

  // Redirect to Cognito login
  login() {
    if (!this.config) throw new Error('Auth service not initialized');
    
    const params = new URLSearchParams({
      client_id: this.config.clientId,
      response_type: 'code',
      scope: 'openid email profile',
      redirect_uri: this.config.redirectUri,
    });

    const loginUrl = `https://${this.config.cognitoDomain}/login?${params.toString()}`;
    window.location.href = loginUrl;
  }

  // Redirect to Cognito logout
  logout() {
    if (!this.config) throw new Error('Auth service not initialized');
    
    // Clear local tokens
    this.clearTokens();
    
    const params = new URLSearchParams({
      client_id: this.config.clientId,
      logout_uri: this.config.redirectUri,
    });

    const logoutUrl = `https://${this.config.cognitoDomain}/logout?${params.toString()}`;
    window.location.href = logoutUrl;
  }

  // Handle OAuth callback (exchange code for tokens)
  async handleCallback(): Promise<boolean> {
    if (!this.config) throw new Error('Auth service not initialized');
    
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get('code');
    const error = urlParams.get('error');

    if (error) {
      console.error('OAuth error:', error);
      return false;
    }

    if (!code) {
      return false;
    }

    try {
      // Exchange code for tokens
      const tokenResponse = await fetch(`https://${this.config.cognitoDomain}/oauth2/token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          grant_type: 'authorization_code',
          client_id: this.config.clientId,
          code: code,
          redirect_uri: this.config.redirectUri,
        }),
      });

      if (!tokenResponse.ok) {
        throw new Error('Failed to exchange code for tokens');
      }

      const tokens = await tokenResponse.json();
      
      // Store tokens
      localStorage.setItem('access_token', tokens.access_token);
      localStorage.setItem('id_token', tokens.id_token);
      localStorage.setItem('refresh_token', tokens.refresh_token);
      
      // Calculate expiry time
      const expiryTime = Date.now() + (tokens.expires_in * 1000);
      localStorage.setItem('token_expiry', expiryTime.toString());

      // Clean up URL
      window.history.replaceState({}, document.title, window.location.pathname);
      
      return true;
    } catch (error) {
      console.error('Error exchanging code for tokens:', error);
      return false;
    }
  }

  // Check if user is authenticated
  isAuthenticated(): boolean {
    const token = localStorage.getItem('id_token');
    const expiry = localStorage.getItem('token_expiry');
    
    if (!token || !expiry) {
      return false;
    }

    return Date.now() < parseInt(expiry);
  }

  // Get current user info from ID token
  getCurrentUser(): UserInfo | null {
    const idToken = localStorage.getItem('id_token');
    if (!idToken) return null;

    try {
      // Decode JWT payload (we don't need to verify since API Gateway does that)
      const payload = JSON.parse(atob(idToken.split('.')[1]));
      return {
        sub: payload.sub,
        email: payload.email,
        username: payload['cognito:username'],
        given_name: payload.given_name,
        family_name: payload.family_name,
      };
    } catch (error) {
      console.error('Error decoding token:', error);
      return null;
    }
  }

  // Get access token for API calls
  getAccessToken(): string | null {
    if (!this.isAuthenticated()) return null;
    return localStorage.getItem('id_token'); // Use ID token for API Gateway
  }

  // Make authenticated API call
  async apiCall(path: string, options: RequestInit = {}): Promise<Response> {
    if (!this.config) throw new Error('Auth service not initialized');
    
    const token = this.getAccessToken();
    if (!token) {
      throw new Error('No valid authentication token');
    }

    const url = `${this.config.apiGatewayUrl}${path}`;
    
    return fetch(url, {
      ...options,
      headers: {
        ...options.headers,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });
  }

  // Refresh tokens if needed
  private async refreshTokens(): Promise<boolean> {
    if (!this.config) return false;
    
    const refreshToken = localStorage.getItem('refresh_token');
    if (!refreshToken) return false;

    try {
      const response = await fetch(`https://${this.config.cognitoDomain}/oauth2/token`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          grant_type: 'refresh_token',
          client_id: this.config.clientId,
          refresh_token: refreshToken,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to refresh tokens');
      }

      const tokens = await response.json();
      
      // Update stored tokens
      localStorage.setItem('access_token', tokens.access_token);
      localStorage.setItem('id_token', tokens.id_token);
      
      // Calculate new expiry time
      const expiryTime = Date.now() + (tokens.expires_in * 1000);
      localStorage.setItem('token_expiry', expiryTime.toString());

      return true;
    } catch (error) {
      console.error('Error refreshing tokens:', error);
      this.clearTokens();
      return false;
    }
  }

  // Clear all stored tokens
  private clearTokens() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('id_token');
    localStorage.removeItem('refresh_token');
    localStorage.removeItem('token_expiry');
  }

  // Start checking for token expiry
  private startTokenRefreshCheck() {
    if (this.tokenCheckInterval) {
      clearInterval(this.tokenCheckInterval);
    }

    this.tokenCheckInterval = setInterval(() => {
      if (this.isAuthenticated()) {
        const expiry = localStorage.getItem('token_expiry');
        if (expiry) {
          const timeUntilExpiry = parseInt(expiry) - Date.now();
          // Refresh if token expires in less than 5 minutes
          if (timeUntilExpiry < 5 * 60 * 1000) {
            this.refreshTokens();
          }
        }
      }
    }, 60000) as unknown as number; // Check every minute
  }

  // Cleanup
  destroy() {
    if (this.tokenCheckInterval) {
      clearInterval(this.tokenCheckInterval);
      this.tokenCheckInterval = null;
    }
  }
}

// Export singleton instance
export const authService = new AuthService();
