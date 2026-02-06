# EShop Identity Service

This is the central identity and authentication service for the EShop microservices application. It provides:

## Features

- **User Management**: Registration, login, profile management
- **OAuth 2.0 / OpenID Connect**: Industry-standard authentication protocols
- **JWT Tokens**: Secure API access tokens
- **Role-based Authorization**: Admin and Customer roles
- **Microservices Integration**: Centralized authentication for all services

## Technology Stack

- **ASP.NET Core 8.0**
- **Duende IdentityServer 6.3**
- **ASP.NET Core Identity**
- **Entity Framework Core** (In-Memory for demo)
- **Bootstrap 5** for UI

## Default Users

The service comes with pre-configured test users:

### Admin User

- **Email**: admin@eshop.com
- **Password**: Password123!
- **Role**: Admin

### Customer User

- **Email**: customer@eshop.com
- **Password**: Password123!
- **Role**: Customer

## Configuration

### Client Applications

The service is configured to work with:

1. **Shopping Web Application** (`shopping-web`)

   - OpenID Connect flow with PKCE
   - Supports refresh tokens
   - Access to all API scopes

2. **API Gateway** (`api-gateway`)

   - Client credentials flow
   - Machine-to-machine communication

3. **SPA Applications** (`shopping-spa`)
   - Authorization code flow with PKCE
   - CORS enabled for local development

### API Scopes

- `catalog` - Catalog Service access
- `basket` - Basket Service access
- `ordering` - Ordering Service access
- `shopping` - Shopping Web App access

## Development

### Running the Service

```bash
cd src/Services/Identity/Identity.API
dotnet run
```

The service will be available at:

- **HTTPS**: https://localhost:5001
- **HTTP**: http://localhost:5000

### Important URLs

- **Login**: `/Account/Login`
- **Register**: `/Account/Register`
- **Discovery Document**: `/.well-known/openid_configuration`
- **Token Endpoint**: `/connect/token`
- **User Info**: `/connect/userinfo`

## Integration with Other Services

### API Gateway Integration

The API Gateway is configured to:

1. Validate JWT tokens from this Identity Service
2. Route identity-related requests to this service
3. Protect other microservices with JWT authentication

### Shopping Web Application

The web application:

1. Redirects users to this service for authentication
2. Receives ID tokens and access tokens
3. Uses access tokens to call protected APIs through the gateway

## Security Considerations

- Uses in-memory database for demo purposes
- In production, replace with persistent database
- Configure proper signing certificates
- Enable HTTPS in production
- Review and adjust token lifetimes
- Implement proper password policies
