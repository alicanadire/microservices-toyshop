const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.static("."));

// Serve the integration guide
app.get("/", (req, res) => {
  const guide = fs.readFileSync("./IDENTITY_INTEGRATION_GUIDE.md", "utf8");

  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EShop Microservices - Identity Integration</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            margin: 20px auto;
            padding: 30px;
        }
        .alert-info {
            background: linear-gradient(45deg, #667eea, #764ba2);
            border: none;
            color: white;
        }
        pre {
            background: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            border-left: 4px solid #667eea;
        }
        h1, h2, h3 { color: #333; }
        .badge { margin: 2px; }
        code {
            background: #f8f9fa;
            padding: 2px 6px;
            border-radius: 4px;
            color: #e83e8c;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="alert alert-info mb-4">
            <h4 class="alert-heading">🎉 EShop Microservices - .NET Core Project</h4>
            <p class="mb-0">This development server serves documentation for the .NET Core microservices project with IdentityServer4.</p>
        </div>

        <div class="row">
            <div class="col-md-3">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">🏗️ Services</h5>
                        <ul class="list-unstyled">
                            <li><strong>Identity Service</strong><br><small class="text-muted">Port 5001 (HTTPS)</small></li>
                            <li><strong>API Gateway</strong><br><small class="text-muted">Port 6064</small></li>
                            <li><strong>Shopping Web</strong><br><small class="text-muted">Port 5000</small></li>
                            <li><strong>Catalog API</strong><br><small class="text-muted">Port 8080</small></li>
                            <li><strong>Basket API</strong><br><small class="text-muted">Port 8081</small></li>
                            <li><strong>Ordering API</strong><br><small class="text-muted">Port 8082</small></li>
                        </ul>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-body">
                        <h5 class="card-title">🔑 Test Users</h5>
                        <div class="mb-2">
                            <strong>Admin:</strong><br>
                            <small>admin@eshop.com<br>Password123!</small>
                        </div>
                        <div>
                            <strong>Customer:</strong><br>
                            <small>customer@eshop.com<br>Password123!</small>
                        </div>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-body">
                        <h5 class="card-title">⚡ Quick Start</h5>
                        <p class="small">Install .NET 8.0 SDK, then run:</p>
                        <code class="d-block small">cd src/Services/Identity/Identity.API</code>
                        <code class="d-block small">dotnet run</code>
                    </div>
                </div>
            </div>

            <div class="col-md-9">
                <div id="markdown-content"></div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script>
        const markdownContent = \`${guide.replace(/`/g, "\\`").replace(/\$/g, "\\$")}\`;
        document.getElementById('markdown-content').innerHTML = marked.parse(markdownContent);
    </script>
</body>
</html>
  `;

  res.send(html);
});

// API endpoint for project status
app.get("/api/status", (req, res) => {
  res.json({
    project: "EShop Microservices",
    type: ".NET Core 8.0",
    status: "Development Ready",
    authentication: "IdentityServer4 (Duende)",
    services: {
      "Identity Service": {
        port: 6006,
        status: "configured",
        tech: "IdentityServer + MongoDB + JWT Authentication",
      },
      "API Gateway": {
        port: 6064,
        status: "configured",
        tech: "YARP + JWT Authentication + Rate Limiting + Health Checks",
      },
      "Shopping Web": {
        port: 5000,
        status: "configured",
        tech: "ASP.NET Core Razor Pages + OIDC",
      },
      "Catalog API": {
        port: 6000,
        status: "configured",
        tech: "Carter + Marten + PostgreSQL",
      },
      "Basket API": {
        port: 6001,
        status: "configured",
        tech: "Carter + Redis + gRPC + JWT Auth",
      },
      "Ordering API": {
        port: 6003,
        status: "configured",
        tech: "Carter + EF Core + CQRS + JWT Auth",
      },
    },
    features: [
      "IdentityServer4 Authentication",
      "JWT Token Security",
      "Microservices Architecture",
      "API Gateway with YARP",
      "Role-based Authorization",
      "OpenID Connect Flow",
      "Responsive UI",
    ],
  });
});

app.listen(PORT, () => {
  console.log("🚀 EShop Microservices Development Server");
  console.log(`📖 Documentation: http://localhost:${PORT}`);
  console.log(`📊 API Status: http://localhost:${PORT}/api/status`);
  console.log("");
  console.log(
    "💡 This is a .NET Core 8.0 project with the following services:",
  );
  console.log("   🔐 Identity Service (IdentityServer4)");
  console.log("   🌐 API Gateway (YARP)");
  console.log("   🛒 Shopping Web (ASP.NET Core)");
  console.log("   📦 Catalog, Basket, Ordering APIs");
  console.log("");
  console.log("⚡ To run the .NET services:");
  console.log(
    "   cd src/Services/Identity/Identity.API && dotnet run --urls http://localhost:6006",
  );
  console.log(
    "   cd src/ApiGateways/YarpApiGateway && dotnet run --urls http://localhost:6064",
  );
  console.log(
    "   cd src/WebApps/Shopping.Web && dotnet run --urls http://localhost:5000",
  );
  console.log("");
});
