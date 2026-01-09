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
                Scopes = new List<string> { "catalog" },
                UserClaims = new List<string> { "role", "email", "name" }
            },
            new ApiResource("basket", "Basket Service")
            {
                Scopes = new List<string> { "basket" },
                UserClaims = new List<string> { "role", "email", "name", "sub" }
            },
            new ApiResource("ordering", "Ordering Service")
            {
                Scopes = new List<string> { "ordering" },
                UserClaims = new List<string> { "role", "email", "name", "sub" }
            },
            new ApiResource("shopping", "Shopping Web App")
            {
                Scopes = new List<string> { "shopping" },
                UserClaims = new List<string> { "role", "email", "name", "sub" }
            },
            new ApiResource("gateway", "API Gateway")
            {
                Scopes = new List<string> { "catalog", "basket", "ordering" },
                UserClaims = new List<string> { "role", "email", "name", "sub" }
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

                RedirectUris = {
                    "http://localhost:5000/signin-oidc",
                    "http://shopping.web:8080/signin-oidc"
                },
                PostLogoutRedirectUris = {
                    "http://localhost:5000/signout-callback-oidc",
                    "http://localhost:5000/",
                    "http://shopping.web:8080/signout-callback-oidc",
                    "http://shopping.web:8080/"
                },
                AllowedCorsOrigins = {
                    "http://localhost:5000",
                    "http://shopping.web:8080"
                },

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
