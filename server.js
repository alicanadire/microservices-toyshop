const express = require("express");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from wwwroot
app.use(
  "/css",
  express.static(path.join(__dirname, "src/WebApps/Shopping.Web/wwwroot/css")),
);
app.use(
  "/lib",
  express.static(path.join(__dirname, "src/WebApps/Shopping.Web/wwwroot/lib")),
);
app.use(
  "/images",
  express.static(
    path.join(__dirname, "src/WebApps/Shopping.Web/wwwroot/images"),
  ),
);

// Mock data for development
const mockProducts = [
  {
    id: 1,
    name: "IPhone X",
    category: "Electronics",
    description:
      "This phone is the company's biggest change to its flagship smartphone in years. It includes a borderless.",
    imageFile: "product-1.png",
    price: 950.0,
  },
  {
    id: 2,
    name: "Samsung 10",
    category: "Electronics",
    description:
      "This phone is the company's biggest change to its flagship smartphone in years. It includes a borderless.",
    imageFile: "product-2.png",
    price: 840.0,
  },
  {
    id: 3,
    name: "Huawei Plus",
    category: "Electronics",
    description:
      "This phone is the company's biggest change to its flagship smartphone in years. It includes a borderless.",
    imageFile: "product-3.png",
    price: 650.0,
  },
  {
    id: 4,
    name: "Xiaomi Mi 9",
    category: "Electronics",
    description:
      "This phone is the company's biggest change to its flagship smartphone in years. It includes a borderless.",
    imageFile: "product-4.png",
    price: 470.0,
  },
];

// Utility function to render basic HTML template
function renderTemplate(title, body, req) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${title} - EShop Microservices</title>
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" rel="stylesheet" type="text/css">
    <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">
    <link href="//fonts.googleapis.com/css?family=Open+Sans:400,300,600" rel="stylesheet" type="text/css">
    <link href="/css/style.css" rel="stylesheet" type="text/css">
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-md navbar-dark bg-dark">
            <div class="container">
                <a class="navbar-brand" href="/">EShop Microservices</a>
                <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse justify-content-end" id="navbarsExampleDefault">
                    <ul class="navbar-nav m-auto">
                        <li class="nav-item ${req.path === "/" ? "active" : ""}">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                        <li class="nav-item ${req.path === "/products" ? "active" : ""}">
                            <a class="nav-link" href="/products">Products</a>
                        </li>
                        <li class="nav-item ${req.path === "/cart" ? "active" : ""}">
                            <a class="nav-link" href="/cart">Cart</a>
                        </li>
                        <li class="nav-item ${req.path === "/orders" ? "active" : ""}">
                            <a class="nav-link" href="/orders">Orders</a>
                        </li>
                        <li class="nav-item ${req.path === "/contact" ? "active" : ""}">
                            <a class="nav-link" href="/contact">Contact</a>
                        </li>
                    </ul>
                    <form class="form-inline my-2 my-lg-0">
                        <div class="input-group input-group-sm">
                            <input type="text" class="form-control" placeholder="Search...">
                            <div class="input-group-append">
                                <button type="button" class="btn btn-secondary btn-number">
                                    <i class="fa fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <a class="btn btn-success btn-sm ml-3" href="/cart">
                            <i class="fa fa-shopping-cart"></i> Cart
                            <span class="badge badge-light">0</span>
                        </a>
                    </form>
                </div>
            </div>
        </nav>
    </header>
    <div class="container">
        <main role="main" class="pb-3">
            ${body}
        </main>
    </div>
    <footer class="text-light">
        <div class="container">
            <div class="row">
                <div class="col-md-3 col-lg-4 col-xl-3">
                    <h5>About</h5>
                    <hr class="bg-white mb-2 mt-0 d-inline-block mx-auto w-25">
                    <p class="mb-0">EShop Microservices - A modern e-commerce platform built with .NET 8 microservices architecture.</p>
                </div>
                <div class="col-md-2 col-lg-2 col-xl-2 mx-auto">
                    <h5>Information</h5>
                    <hr class="bg-white mb-2 mt-0 d-inline-block mx-auto w-25">
                    <ul class="list-unstyled">
                        <li><a href="/about">About Us</a></li>
                        <li><a href="/privacy">Privacy Policy</a></li>
                        <li><a href="/terms">Terms of Service</a></li>
                        <li><a href="/support">Support</a></li>
                    </ul>
                </div>
                <div class="col-md-3 col-lg-2 col-xl-2 mx-auto">
                    <h5>Quick Links</h5>
                    <hr class="bg-white mb-2 mt-0 d-inline-block mx-auto w-25">
                    <ul class="list-unstyled">
                        <li><a href="/">Home</a></li>
                        <li><a href="/products">Products</a></li>
                        <li><a href="/cart">Cart</a></li>
                        <li><a href="/orders">Orders</a></li>
                    </ul>
                </div>
                <div class="col-md-4 col-lg-3 col-xl-3">
                    <h5>Contact</h5>
                    <hr class="bg-white mb-2 mt-0 d-inline-block mx-auto w-25">
                    <ul class="list-unstyled">
                        <li><i class="fa fa-home mr-2"></i> EShop Company</li>
                        <li><i class="fa fa-envelope mr-2"></i> contact@eshop.com</li>
                        <li><i class="fa fa-phone mr-2"></i> +1 234 567 8900</li>
                    </ul>
                </div>
                <div class="col-12 copyright mt-3">
                    <p class="text-right text-muted">EShop Microservices | Development Mode</p>
                </div>
            </div>
        </div>
    </footer>
    <script src="//code.jquery.com/jquery-3.2.1.slim.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"></script>
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function () {
            $('.quantity-right-plus').click(function (e) {
                e.preventDefault();
                var quantity = parseInt($('#quantity').val());
                $('#quantity').val(quantity + 1);
            });
            $('.quantity-left-minus').click(function (e) {
                e.preventDefault();
                var quantity = parseInt($('#quantity').val());
                if (quantity > 1) {
                    $('#quantity').val(quantity - 1);
                }
            });
        });
        (function () {
            'use strict';
            window.addEventListener('load', function () {
                var forms = document.getElementsByClassName('needs-validation');
                var validation = Array.prototype.filter.call(forms, function (form) {
                    form.addEventListener('submit', function (event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();
    </script>
</body>
</html>`;
}

// Product card component
function renderProductCard(product) {
  return `<div class="card">
        <div class="card-body">
            <h4 class="card-title">
                <a href="/products/${product.id}" title="View Product">${product.name}</a>
            </h4>
            <h5>$${product.price.toFixed(2)}</h5>
            <p class="card-text">${product.description}</p>
            <div class="row">
                <div class="col-sm">
                    <a href="/products/${product.id}" class="btn btn-light btn-block">View Details</a>
                </div>
                <div class="col-sm">
                    <button class="btn btn-success btn-block" onclick="addToCart(${product.id})">Add to Cart</button>
                </div>
            </div>
        </div>
    </div>`;
}

// Routes
app.get("/", (req, res) => {
  const lastProducts = mockProducts.slice(0, 4);
  const bestProducts = mockProducts.slice(-4);

  const body = `<hr />
        <div class="container">
            <div class="row">
                <div class="col-8">
                    <div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
                        <ol class="carousel-indicators">
                            <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
                            <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
                            <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
                        </ol>
                        <div class="carousel-inner">
                            <div class="carousel-item active">
                                <div style="height: 300px; background: linear-gradient(45deg, #007bff, #6610f2); display: flex; align-items: center; justify-content: center; color: white;">
                                    <h2>Welcome to EShop Microservices</h2>
                                </div>
                            </div>
                            <div class="carousel-item">
                                <div style="height: 300px; background: linear-gradient(45deg, #28a745, #20c997); display: flex; align-items: center; justify-content: center; color: white;">
                                    <h2>Latest Technology Products</h2>
                                </div>
                            </div>
                            <div class="carousel-item">
                                <div style="height: 300px; background: linear-gradient(45deg, #dc3545, #fd7e14); display: flex; align-items: center; justify-content: center; color: white;">
                                    <h2>Best Deals Available</h2>
                                </div>
                            </div>
                        </div>
                        <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
                            <span class="carousel-control-prev-icon"></span>
                        </a>
                        <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
                            <span class="carousel-control-next-icon"></span>
                        </a>
                    </div>
                </div>
                <div class="col-4">
                    <div class="card">
                        <div class="card-header bg-success text-white">
                            <h5><i class="fa fa-star"></i> Featured Product</h5>
                        </div>
                        <div class="card-body">
                            ${renderProductCard(mockProducts[0])}
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="container mt-3">
            <div class="row">
                <div class="col-sm">
                    <div class="card">
                        <div class="card-header bg-primary text-white text-uppercase">
                            <i class="fa fa-star"></i> Latest Products
                        </div>
                        <div class="card-body">
                            <div class="row">
                                ${lastProducts.map((product) => `<div class="col-md-3 mb-3">${renderProductCard(product)}</div>`).join("")}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="container mt-3 mb-4">
            <div class="row">
                <div class="col-sm">
                    <div class="card">
                        <div class="card-header bg-primary text-white text-uppercase">
                            <i class="fa fa-trophy"></i> Best Products
                        </div>
                        <div class="card-body">
                            <div class="row">
                                ${bestProducts.map((product) => `<div class="col-md-3 mb-3">${renderProductCard(product)}</div>`).join("")}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            function addToCart(productId) {
                alert('Product added to cart! (Mock functionality)');
            }
        </script>`;

  res.send(renderTemplate("Home", body, req));
});

app.get("/products", (req, res) => {
  const body = `<div class="container mt-3">
            <h2>All Products</h2>
            <div class="row">
                ${mockProducts.map((product) => `<div class="col-md-4 mb-4">${renderProductCard(product)}</div>`).join("")}
            </div>
        </div>
        <script>
            function addToCart(productId) {
                alert('Product added to cart! (Mock functionality)');
            }
        </script>`;

  res.send(renderTemplate("Products", body, req));
});

app.get("/products/:id", (req, res) => {
  const productId = parseInt(req.params.id);
  const product = mockProducts.find((p) => p.id === productId);

  if (!product) {
    return res
      .status(404)
      .send(
        renderTemplate("Product Not Found", "<h2>Product Not Found</h2>", req),
      );
  }

  const body = `<div class="container mt-3">
            <div class="row">
                <div class="col-md-6">
                    <div style="height: 400px; background: #f8f9fa; display: flex; align-items: center; justify-content: center; border: 1px solid #dee2e6;">
                        <span>Product Image</span>
                    </div>
                </div>
                <div class="col-md-6">
                    <h2>${product.name}</h2>
                    <h4 class="text-success">$${product.price.toFixed(2)}</h4>
                    <p class="lead">${product.description}</p>
                    <p><strong>Category:</strong> ${product.category}</p>
                    
                    <div class="form-group">
                        <label for="quantity">Quantity:</label>
                        <div class="input-group">
                            <div class="input-group-prepend">
                                <button class="btn btn-outline-secondary quantity-left-minus" type="button">
                                    <i class="fa fa-minus"></i>
                                </button>
                            </div>
                            <input type="number" id="quantity" name="quantity" class="form-control text-center" value="1" min="1">
                            <div class="input-group-append">
                                <button class="btn btn-outline-secondary quantity-right-plus" type="button">
                                    <i class="fa fa-plus"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                    
                    <button class="btn btn-success btn-lg" onclick="addToCart(${product.id})">
                        <i class="fa fa-shopping-cart"></i> Add to Cart
                    </button>
                    <a href="/products" class="btn btn-secondary btn-lg ml-2">
                        <i class="fa fa-arrow-left"></i> Back to Products
                    </a>
                </div>
            </div>
        </div>
        <script>
            function addToCart(productId) {
                const quantity = document.getElementById('quantity').value;
                alert('Added ' + quantity + ' item(s) to cart! (Mock functionality)');
            }
        </script>`;

  res.send(renderTemplate(product.name, body, req));
});

app.get("/cart", (req, res) => {
  const body = `<div class="container mt-3">
            <h2>Shopping Cart</h2>
            <div class="alert alert-info">
                <i class="fa fa-info-circle"></i> This is a development preview. 
                The cart functionality requires the backend microservices to be running.
            </div>
            <div class="row">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h4>Cart Items</h4>
                        </div>
                        <div class="card-body">
                            <p>Your cart is empty. <a href="/products">Continue shopping</a></p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h4>Order Summary</h4>
                        </div>
                        <div class="card-body">
                            <p><strong>Subtotal: $0.00</strong></p>
                            <p><strong>Shipping: $0.00</strong></p>
                            <hr>
                            <p><strong>Total: $0.00</strong></p>
                            <button class="btn btn-success btn-block" disabled>Proceed to Checkout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>`;

  res.send(renderTemplate("Cart", body, req));
});

app.get("/orders", (req, res) => {
  const body = `<div class="container mt-3">
            <h2>Order History</h2>
            <div class="alert alert-info">
                <i class="fa fa-info-circle"></i> This is a development preview. 
                Order functionality requires the backend microservices to be running.
            </div>
            <div class="card">
                <div class="card-header">
                    <h4>Your Orders</h4>
                </div>
                <div class="card-body">
                    <p>No orders found. <a href="/products">Start shopping</a></p>
                </div>
            </div>
        </div>`;

  res.send(renderTemplate("Orders", body, req));
});

app.get("/contact", (req, res) => {
  const body = `<div class="container mt-3">
            <h2>Contact Us</h2>
            <div class="row">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h4>Send us a message</h4>
                        </div>
                        <div class="card-body">
                            <form class="needs-validation" novalidate>
                                <div class="form-group">
                                    <label for="name">Full Name</label>
                                    <input type="text" class="form-control" id="name" required>
                                    <div class="invalid-feedback">Please provide a valid name.</div>
                                </div>
                                <div class="form-group">
                                    <label for="email">Email</label>
                                    <input type="email" class="form-control" id="email" required>
                                    <div class="invalid-feedback">Please provide a valid email.</div>
                                </div>
                                <div class="form-group">
                                    <label for="subject">Subject</label>
                                    <input type="text" class="form-control" id="subject" required>
                                    <div class="invalid-feedback">Please provide a subject.</div>
                                </div>
                                <div class="form-group">
                                    <label for="message">Message</label>
                                    <textarea class="form-control" id="message" rows="5" required></textarea>
                                    <div class="invalid-feedback">Please provide a message.</div>
                                </div>
                                <button class="btn btn-primary" type="submit">Send Message</button>
                            </form>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h4>Contact Information</h4>
                        </div>
                        <div class="card-body">
                            <p><i class="fa fa-home"></i> <strong>Address:</strong><br>
                            123 EShop Street<br>
                            Tech City, TC 12345</p>
                            
                            <p><i class="fa fa-phone"></i> <strong>Phone:</strong><br>
                            +1 (234) 567-8900</p>
                            
                            <p><i class="fa fa-envelope"></i> <strong>Email:</strong><br>
                            contact@eshop.com</p>
                            
                            <p><i class="fa fa-clock-o"></i> <strong>Business Hours:</strong><br>
                            Mon-Fri: 9:00 AM - 6:00 PM<br>
                            Sat-Sun: 10:00 AM - 4:00 PM</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>`;

  res.send(renderTemplate("Contact", body, req));
});

// API endpoints for future integration
app.get("/api/products", (req, res) => {
  res.json(mockProducts);
});

app.get("/api/products/:id", (req, res) => {
  const productId = parseInt(req.params.id);
  const product = mockProducts.find((p) => p.id === productId);

  if (!product) {
    return res.status(404).json({ error: "Product not found" });
  }

  res.json(product);
});

// Development notice for other routes
app.get("*", (req, res) => {
  const body = `<div class="container mt-3">
            <div class="alert alert-warning">
                <h4><i class="fa fa-exclamation-triangle"></i> Development Mode</h4>
                <p>This page is not yet implemented in development mode.</p>
                <p><strong>Note:</strong> This is a .NET microservices application. 
                To run the full application, you need:</p>
                <ul>
                    <li>.NET 8 SDK</li>
                    <li>Docker & Docker Compose</li>
                    <li>SQL Server, PostgreSQL, Redis, and RabbitMQ</li>
                </ul>
                <p>For development setup, please refer to the PowerShell setup script: <code>setup.ps1</code></p>
                <a href="/" class="btn btn-primary">Go to Home</a>
            </div>
        </div>`;

  res.send(renderTemplate("Page Not Found", body, req));
});

// Start server
app.listen(PORT, () => {
  console.log("====================================");
  console.log("EShop Microservices - Development Server");
  console.log("====================================");
  console.log("");
  console.log("Server running at: http://localhost:" + PORT);
  console.log("");
  console.log("This is a development preview of the frontend interface.");
  console.log("The actual application is a .NET 8 microservices architecture.");
  console.log("");
  console.log("Available routes:");
  console.log("- Home: http://localhost:" + PORT + "/");
  console.log("- Products: http://localhost:" + PORT + "/products");
  console.log("- Cart: http://localhost:" + PORT + "/cart");
  console.log("- Orders: http://localhost:" + PORT + "/orders");
  console.log("- Contact: http://localhost:" + PORT + "/contact");
  console.log("");
  console.log("API endpoints:");
  console.log("- GET /api/products");
  console.log("- GET /api/products/:id");
  console.log("");
  console.log("Note: Full functionality requires the .NET backend services.");
  console.log("====================================");
});
