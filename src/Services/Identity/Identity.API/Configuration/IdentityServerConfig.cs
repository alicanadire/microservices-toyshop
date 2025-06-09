namespace Identity.API.Configuration;

public static class IdentityServerConfig
{
    public static IEnumerable<IdentityResource> IdentityResources =>
        new IdentityResource[]
        {
            new IdentityResources.OpenId(),
            new IdentityResources.Profile(),
            new IdentityResources.Email(),
            new IdentityResource
            {
                Name = "roles",
                UserClaims = new List<string> {"role"}
            }
        };

    public static IEnumerable<ApiScope> ApiScopes =>
        new ApiScope[]
        {
            new ApiScope("catalog", "Catalog Service"),
            new ApiScope("basket", "Basket Service"),
            new ApiScope("ordering", "Ordering Service"),
            new ApiScope("shopping", "Shopping Web App")
        };

    public static IEnumerable<ApiResource> ApiResources =>
        new ApiResource[]
        {
            new ApiResource("catalog", "Catalog Service")
            {
                Scopes = new List<string> { "catalog" }
            },
            new ApiResource("basket", "Basket Service")
            {
                Scopes = new List<string> { "basket" }
            },
            new ApiResource("ordering", "Ordering Service")
            {
                Scopes = new List<string> { "ordering" }
            },
            new ApiResource("shopping", "Shopping Web App")
            {
                Scopes = new List<string> { "shopping" }
            }
        };

    public static IEnumerable<Client> Clients =>
        new Client[]
        {
            // Shopping Web Application
            new Client
            {
                ClientId = "shopping-web",
                ClientName = "Shopping Web Application",
                AllowedGrantTypes = GrantTypes.Code,
                RequireClientSecret = false,
                RequirePkce = true,
                AllowOfflineAccess = true,
                
                RedirectUris = { "https://localhost:5001/signin-oidc", "http://localhost:5000/signin-oidc" },
                PostLogoutRedirectUris = { "https://localhost:5001/signout-callback-oidc", "http://localhost:5000/signout-callback-oidc" },
                
                AllowedScopes =
                {
                    IdentityServerConstants.StandardScopes.OpenId,
                    IdentityServerConstants.StandardScopes.Profile,
                    IdentityServerConstants.StandardScopes.Email,
                    "roles",
                    "catalog",
                    "basket",
                    "ordering",
                    "shopping"
                }
            },
            // API Gateway
            new Client
            {
                ClientId = "api-gateway",
                ClientName = "API Gateway",
                AllowedGrantTypes = GrantTypes.ClientCredentials,
                ClientSecrets =
                {
                    new Secret("gateway_secret".Sha256())
                },
                AllowedScopes =
                {
                    "catalog",
                    "basket",
                    "ordering"
                }
            },
            // Mobile/SPA Client
            new Client
            {
                ClientId = "shopping-spa",
                ClientName = "Shopping SPA",
                AllowedGrantTypes = GrantTypes.Code,
                RequireClientSecret = false,
                RequirePkce = true,
                AllowOfflineAccess = true,
                
                RedirectUris = { "http://localhost:3000/callback" },
                PostLogoutRedirectUris = { "http://localhost:3000" },
                AllowedCorsOrigins = { "http://localhost:3000" },
                
                AllowedScopes =
                {
                    IdentityServerConstants.StandardScopes.OpenId,
                    IdentityServerConstants.StandardScopes.Profile,
                    IdentityServerConstants.StandardScopes.Email,
                    "roles",
                    "shopping"
                }
            }
        };
}
