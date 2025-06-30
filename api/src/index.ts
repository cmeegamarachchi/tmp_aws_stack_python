import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  // CORS headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS,PUT,DELETE'
  };

  // Handle preflight requests
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: ''
    };
  }

  try {
    // API Gateway handles authentication - user info is available in request context
    const userInfo = event.requestContext.authorizer;
    const claims = userInfo?.claims || {};
    
    // Extract user information from the authorizer context
    const userId = claims.sub || userInfo?.principalId;
    const username = claims['cognito:username'] || claims.username;
    const email = claims.email;
    
    console.log('Authenticated user:', { userId, username, email });

    // Route handling
    const path = event.path;
    const method = event.httpMethod;

    if (path === '/hello' && method === 'GET') {
      return {
        statusCode: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: 'Hello from AWS Lambda!',
          timestamp: new Date().toISOString(),
          user: {
            id: userId,
            username: username,
            email: email
          },
          path: path,
          method: method,
          authContext: userInfo // Include full auth context for debugging
        })
      };
    }

    if (path === '/protected' && method === 'GET') {
      return {
        statusCode: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: 'This is a protected endpoint - authentication handled by API Gateway!',
          timestamp: new Date().toISOString(),
          user: {
            id: userId,
            username: username,
            email: email
          },
          claims: claims, // All JWT claims
          requestId: event.requestContext.requestId
        })
      };
    }

    if (path === '/user/profile' && method === 'GET') {
      return {
        statusCode: 200,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: 'User profile data',
          profile: {
            userId: userId,
            username: username,
            email: email,
            emailVerified: claims.email_verified,
            groups: claims['cognito:groups'] || [],
            roles: claims['cognito:roles'] || []
          },
          metadata: {
            lastLogin: new Date().toISOString(),
            requestSource: event.requestContext.identity.sourceIp
          }
        })
      };
    }

    // Route not found
    return {
      statusCode: 404,
      headers: corsHeaders,
      body: JSON.stringify({ 
        error: 'Route not found',
        availableRoutes: [
          'GET /hello',
          'GET /protected', 
          'GET /user/profile'
        ]
      })
    };

  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({ 
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error'
      })
    };
  }
};
