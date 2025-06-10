const express = require("express");
const path = require("path");
const fs = require("fs");
const { createProxyMiddleware } = require("http-proxy-middleware");

const app = express();
const PORT = process.env.PORT || 3000;

// Backend services configuration
const BACKEND_SERVICES = {
  GATEWAY_URL: process.env.GATEWAY_URL || "https://localhost:6064",
  CATALOG_API: process.env.CATALOG_API || "http://localhost:6000",
  BASKET_API: process.env.BASKET_API || "http://localhost:6001",
  ORDERING_API: process.env.ORDERING_API || "http://localhost:6003",
};

// Check if backend services are available
const checkBackendService = async (url) => {
  try {
    const fetch = require("node-fetch");
    const response = await fetch(url + "/health", { timeout: 1000 });
    return response.ok;
  } catch (error) {
    return false;
  }
};

let backendAvailable = false;

// Test backend availability on startup
(async () => {
  try {
    backendAvailable = await checkBackendService(BACKEND_SERVICES.CATALOG_API);
    if (backendAvailable) {
      console.log("✅ Backend services detected - API calls will be proxied");
    } else {
      console.log("⚠️  Backend services not available - Using mock data");
    }
  } catch (error) {
    console.log("⚠️  Backend services not available - Using mock data");
  }
})();

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

// Mock data for development - Toy Shop Products
const mockProducts = [
  {
    id: 1,
    name: "LEGO Creator Expert 🏠",
    category: "Building Sets",
    description:
      "Amazing building experience with this detailed Creator Expert set. Perfect for advanced builders and collectors.",
    imageFile: "lego-house.jpg",
    price: 89.99,
    ageRange: "12+",
    brand: "LEGO",
    inStock: true,
    rating: 4.8,
  },
  {
    id: 2,
    name: "Barbie Dreamhouse 🏰",
    category: "Dolls & Accessories",
    description:
      "Three-story dreamhouse with elevator, pool, and over 70 accessories. Perfect for imaginative play.",
    imageFile: "barbie-dreamhouse.jpg",
    price: 199.99,
    ageRange: "3-9",
    brand: "Barbie",
    inStock: true,
    rating: 4.7,
  },
  {
    id: 3,
    name: "Hot Wheels Track Set 🏎️",
    category: "Vehicles & Tracks",
    description:
      "Epic racing track with loops, jumps, and speed boosters. Includes 5 die-cast cars.",
    imageFile: "hotwheels-track.jpg",
    price: 45.99,
    ageRange: "4+",
    brand: "Hot Wheels",
    inStock: true,
    rating: 4.6,
  },
  {
    id: 4,
    name: "Teddy Bear Collection 🧸",
    category: "Plush Toys",
    description:
      "Soft and cuddly teddy bear made with premium materials. Perfect companion for bedtime.",
    imageFile: "teddy-bear.jpg",
    price: 24.99,
    ageRange: "0+",
    brand: "ToyShop",
    inStock: true,
    rating: 4.9,
  },
  {
    id: 5,
    name: "Nintendo Switch Console 🎮",
    category: "Electronic Toys",
    description:
      "Portable gaming console with vibrant OLED screen. Perfect for gaming on the go.",
    imageFile: "nintendo-switch.jpg",
    price: 299.99,
    ageRange: "6+",
    brand: "Nintendo",
    inStock: true,
    rating: 4.8,
  },
  {
    id: 6,
    name: "Educational Tablet 📱",
    category: "Educational Toys",
    description:
      "Interactive learning tablet with games, stories, and educational activities.",
    imageFile: "kids-tablet.jpg",
    price: 79.99,
    ageRange: "3-8",
    brand: "LeapFrog",
    inStock: true,
    rating: 4.5,
  },
  {
    id: 7,
    name: "Art & Craft Set 🎨",
    category: "Arts & Crafts",
    description:
      "Complete art set with crayons, markers, colored pencils, and drawing paper.",
    imageFile: "art-set.jpg",
    price: 34.99,
    ageRange: "5+",
    brand: "Crayola",
    inStock: true,
    rating: 4.7,
  },
  {
    id: 8,
    name: "Remote Control Drone 🚁",
    category: "Remote Control",
    description:
      "Easy-to-fly drone with HD camera and LED lights. Perfect for outdoor adventures.",
    imageFile: "rc-drone.jpg",
    price: 129.99,
    ageRange: "8+",
    brand: "TechToys",
    inStock: true,
    rating: 4.4,
  },
];

// Utility function to render basic HTML template
function renderTemplate(title, body, req) {
  return `<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${title} - ToyShop 🧸</title>
    <link href="//cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="//cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="//fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #FF6B6B;
            --secondary-color: #4ECDC4;
            --accent-color: #FFE66D;
            --purple-color: #A8E6CF;
            --pink-color: #FFB3BA;
            --blue-color: #BFEFFF;
            --text-dark: #2C3E50;
            --text-light: #7F8C8D;
        }

        * {
            font-family: 'Nunito', sans-serif !important;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .navbar {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color)) !important;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }

        .navbar-brand {
            font-weight: 800 !important;
            font-size: 1.8rem !important;
            background: linear-gradient(45deg, #fff, var(--accent-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-link {
            font-weight: 600 !important;
            transition: all 0.3s ease;
            position: relative;
        }

        .nav-link:hover {
            transform: translateY(-2px);
            color: var(--accent-color) !important;
        }

        .nav-link.active {
            color: var(--accent-color) !important;
        }

        .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 50%;
            transform: translateX(-50%);
            width: 30px;
            height: 3px;
            background: var(--accent-color);
            border-radius: 10px;
        }

        .main-container {
            background: white;
            border-radius: 20px;
            margin-top: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .card {
            border: none !important;
            border-radius: 20px !important;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1) !important;
            transition: all 0.3s ease;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.2) !important;
        }

        .card-header {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color)) !important;
            border: none !important;
            color: white !important;
            font-weight: 700 !important;
            padding: 1.5rem !important;
        }

        .btn {
            border-radius: 15px !important;
            font-weight: 600 !important;
            transition: all 0.3s ease;
            border: none !important;
        }

        .btn-primary {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color)) !important;
        }

        .btn-success {
            background: linear-gradient(45deg, var(--secondary-color), var(--purple-color)) !important;
        }

        .btn-warning {
            background: linear-gradient(45deg, var(--accent-color), #FFA726) !important;
            color: var(--text-dark) !important;
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }

        .carousel-item {
            border-radius: 20px;
            overflow: hidden;
        }

        .product-card {
            background: white;
            border-radius: 20px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            position: relative;
        }

        .product-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .product-card .badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: var(--accent-color) !important;
            color: var(--text-dark) !important;
            font-weight: 700;
        }

        .price-tag {
            font-size: 1.5rem;
            font-weight: 800;
            color: var(--primary-color);
        }

        .product-image {
            width: 100%;
            height: 200px;
            background: linear-gradient(135deg, var(--blue-color), var(--pink-color));
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .rating {
            color: #FFC107;
        }

        footer {
            background: linear-gradient(45deg, var(--text-dark), #34495E) !important;
            color: white;
            margin-top: 4rem;
            padding: 3rem 0;
        }

        .search-box {
            border-radius: 25px !important;
            border: none !important;
            background: rgba(255,255,255,0.9) !important;
            backdrop-filter: blur(10px);
        }

        .search-btn {
            border-radius: 0 25px 25px 0 !important;
            background: var(--accent-color) !important;
            color: var(--text-dark) !important;
            border: none !important;
        }

        .cart-btn {
            background: linear-gradient(45deg, var(--secondary-color), var(--purple-color)) !important;
            border-radius: 25px !important;
            font-weight: 700 !important;
        }

        .hero-gradient {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color), var(--accent-color));
            color: white;
            padding: 4rem 2rem;
            text-align: center;
            border-radius: 20px;
            margin-bottom: 2rem;
        }

        .category-badge {
            background: var(--purple-color) !important;
            color: var(--text-dark) !important;
            font-weight: 600;
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
        }

        @keyframes bounce {
            0%, 20%, 60%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            80% { transform: translateY(-5px); }
        }

        .bounce-animation {
            animation: bounce 2s infinite;
        }

        .fade-in {
            animation: fadeIn 1s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
            <div class="container">
                <a class="navbar-brand bounce-animation" href="/">
                    <i class="fas fa-rocket me-2"></i>ToyShop 🧸
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link ${req.path === "/" ? "active" : ""}" href="/">
                                <i class="fas fa-home me-1"></i>Ana Sayfa
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${req.path === "/products" ? "active" : ""}" href="/products">
                                <i class="fas fa-toys me-1"></i>Oyuncaklar
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${req.path === "/cart" ? "active" : ""}" href="/cart">
                                <i class="fas fa-shopping-cart me-1"></i>Sepet
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${req.path === "/orders" ? "active" : ""}" href="/orders">
                                <i class="fas fa-list-alt me-1"></i>Siparişler
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link ${req.path === "/contact" ? "active" : ""}" href="/contact">
                                <i class="fas fa-envelope me-1"></i>İletişim
                            </a>
                        </li>
                    </ul>
                    <form class="d-flex align-items-center">
                        <div class="input-group me-3">
                            <input type="text" class="form-control search-box" placeholder="Oyuncak ara..." style="width: 200px;">
                            <button class="btn search-btn" type="button">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                        <a class="btn cart-btn text-white" href="/cart">
                            <i class="fas fa-shopping-cart me-1"></i>Sepet
                            <span class="badge bg-warning text-dark ms-1">0</span>
                        </a>
                    </form>
                </div>
            </div>
        </nav>
    </header>
    <div style="height: 80px;"></div> <!-- Spacer for fixed navbar -->
    <div class="container">
        <main role="main" class="pb-3">
            ${body}
        </main>
    </div>
    <footer class="text-light">
        <div class="container">
            <div class="row g-4">
                <div class="col-md-3 col-lg-4">
                    <h5><i class="fas fa-rocket me-2"></i>ToyShop Hakkında</h5>
                    <hr class="bg-white mb-3 mt-0 d-inline-block w-25">
                    <p class="mb-0">En kaliteli ve eğlenceli oyuncakları çocukların hayal gücüyle buluşturan modern oyuncak mağazası. .NET 8 mikroservis mimarisiyle güçlendirilmiştir.</p>
                    <div class="mt-3">
                        <a href="#" class="text-light me-3"><i class="fab fa-facebook fa-lg"></i></a>
                        <a href="#" class="text-light me-3"><i class="fab fa-instagram fa-lg"></i></a>
                        <a href="#" class="text-light me-3"><i class="fab fa-twitter fa-lg"></i></a>
                        <a href="#" class="text-light"><i class="fab fa-youtube fa-lg"></i></a>
                    </div>
                </div>
                <div class="col-md-2 col-lg-2 mx-auto">
                    <h5><i class="fas fa-info-circle me-2"></i>Bilgiler</h5>
                    <hr class="bg-white mb-3 mt-0 d-inline-block w-25">
                    <ul class="list-unstyled">
                        <li class="mb-2"><a href="/about" class="text-light text-decoration-none">Hakkımızda</a></li>
                        <li class="mb-2"><a href="/privacy" class="text-light text-decoration-none">Gizlilik Politikası</a></li>
                        <li class="mb-2"><a href="/terms" class="text-light text-decoration-none">Kullanım Şartları</a></li>
                        <li class="mb-2"><a href="/support" class="text-light text-decoration-none">Destek</a></li>
                    </ul>
                </div>
                <div class="col-md-3 col-lg-2 mx-auto">
                    <h5><i class="fas fa-toys me-2"></i>Kategoriler</h5>
                    <hr class="bg-white mb-3 mt-0 d-inline-block w-25">
                    <ul class="list-unstyled">
                        <li class="mb-2"><a href="/products?category=building" class="text-light text-decoration-none">Yapı Setleri</a></li>
                        <li class="mb-2"><a href="/products?category=dolls" class="text-light text-decoration-none">Bebekler</a></li>
                        <li class="mb-2"><a href="/products?category=vehicles" class="text-light text-decoration-none">Araçlar</a></li>
                        <li class="mb-2"><a href="/products?category=educational" class="text-light text-decoration-none">Eğitici Oyuncaklar</a></li>
                    </ul>
                </div>
                <div class="col-md-4 col-lg-3">
                    <h5><i class="fas fa-phone me-2"></i>İletişim</h5>
                    <hr class="bg-white mb-3 mt-0 d-inline-block w-25">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-map-marker-alt me-2"></i> ToyShop Merkez</li>
                        <li class="mb-2"><i class="fas fa-envelope me-2"></i> info@toyshop.com</li>
                        <li class="mb-2"><i class="fas fa-phone me-2"></i> +90 212 123 45 67</li>
                        <li class="mb-2"><i class="fas fa-clock me-2"></i> Pazartesi-Cumartesi: 09:00-22:00</li>
                    </ul>
                </div>
                <div class="col-12 text-center mt-4 pt-4 border-top">
                    <p class="mb-0">
                        <i class="fas fa-heart text-danger me-1"></i>
                        2024 ToyShop - Çocukların Hayal Dünyası | Geliştirme Modu
                        <i class="fas fa-rocket ms-1"></i>
                    </p>
                </div>
            </div>
        </div>
    </footer>
    <script src="//cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Quantity controls
        document.addEventListener('DOMContentLoaded', function() {
            document.addEventListener('click', function(e) {
                if (e.target.classList.contains('quantity-right-plus')) {
                    e.preventDefault();
                    const input = document.getElementById('quantity');
                    if (input) {
                        input.value = parseInt(input.value) + 1;
                    }
                }
                if (e.target.classList.contains('quantity-left-minus')) {
                    e.preventDefault();
                    const input = document.getElementById('quantity');
                    if (input && parseInt(input.value) > 1) {
                        input.value = parseInt(input.value) - 1;
                    }
                }
            });

            // Form validation
            const forms = document.querySelectorAll('.needs-validation');
            forms.forEach(form => {
                form.addEventListener('submit', function(event) {
                    if (!form.checkValidity()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                });
            });

            // Animate elements on scroll
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.opacity = '1';
                        entry.target.style.transform = 'translateY(0)';
                    }
                });
            }, observerOptions);

            document.querySelectorAll('.fade-in').forEach(el => {
                el.style.opacity = '0';
                el.style.transform = 'translateY(30px)';
                el.style.transition = 'all 0.6s ease';
                observer.observe(el);
            });
        });
    </script>
</body>
</html>`;
}

// Product card component
function renderProductCard(product) {
  const emoji = product.name.match(/[🏠🏰🏎️🧸🎮📱🎨🚁]/)?.[0] || "🧸";
  const stars =
    "★".repeat(Math.floor(product.rating)) +
    "☆".repeat(5 - Math.floor(product.rating));

  return `<div class="product-card fade-in">
        <span class="badge">${product.ageRange}</span>
        <div class="product-image">
            ${emoji}
        </div>
        <div class="text-center">
            <span class="category-badge">${product.category}</span>
            <h5 class="mt-3 mb-2 fw-bold">${product.name}</h5>
            <div class="rating mb-2">
                ${stars} <small class="text-muted">(${product.rating})</small>
            </div>
            <p class="text-muted small mb-3">${product.description}</p>
            <div class="price-tag mb-3">₺${(product.price * 30).toFixed(2)}</div>
            <div class="d-grid gap-2">
                <a href="/products/${product.id}" class="btn btn-warning">
                    <i class="fas fa-eye me-1"></i>Detayları Gör
                </a>
                <button class="btn btn-success" onclick="addToCart(${product.id})">
                    <i class="fas fa-cart-plus me-1"></i>Sepete Ekle
                </button>
            </div>
            <div class="mt-2">
                <small class="text-success">
                    <i class="fas fa-check-circle me-1"></i>Stokta Var
                </small>
                <br>
                <small class="text-info">
                    <i class="fas fa-truck me-1"></i>Ücretsiz Kargo
                </small>
            </div>
        </div>
    </div>`;
}

// Routes
app.get("/", (req, res) => {
  const featuredProducts = mockProducts.slice(0, 4);
  const popularProducts = mockProducts.slice(2, 6);
  const newProducts = mockProducts.slice(4, 8);

  const body = `
    <div class="main-container">
        <div class="hero-gradient fade-in">
            <h1 class="display-4 fw-bold mb-3">
                <i class="fas fa-rocket me-3"></i>
                ToyShop'a Hoş Geldiniz! 🎉
            </h1>
            <p class="lead mb-4">Çocukların hayal gücünü geliştiren en kaliteli oyuncaklar burada!</p>
            <a href="/products" class="btn btn-warning btn-lg">
                <i class="fas fa-toys me-2"></i>Oyuncakları Keşfet
            </a>
        </div>

        <div class="container py-5">
            <!-- Hero Carousel -->
            <div class="row mb-5">
                <div class="col-lg-8">
                    <div id="heroCarousel" class="carousel slide" data-bs-ride="carousel">
                        <div class="carousel-indicators">
                            <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="0" class="active"></button>
                            <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="1"></button>
                            <button type="button" data-bs-target="#heroCarousel" data-bs-slide-to="2"></button>
                        </div>
                        <div class="carousel-inner">
                            <div class="carousel-item active">
                                <div style="height: 350px; background: linear-gradient(135deg, var(--primary-color), var(--secondary-color)); display: flex; align-items: center; justify-content: center; color: white; border-radius: 20px;">
                                    <div class="text-center">
                                        <h2 class="fw-bold mb-3">🎯 Yeni LEGO Setleri</h2>
                                        <p class="lead">Hayal gücünü sınırsızca geliştir!</p>
                                    </div>
                                </div>
                            </div>
                            <div class="carousel-item">
                                <div style="height: 350px; background: linear-gradient(135deg, var(--accent-color), var(--pink-color)); display: flex; align-items: center; justify-content: center; color: var(--text-dark); border-radius: 20px;">
                                    <div class="text-center">
                                        <h2 class="fw-bold mb-3">🎮 Gaming Dünyası</h2>
                                        <p class="lead">En popüler oyun konsolları!</p>
                                    </div>
                                </div>
                            </div>
                            <div class="carousel-item">
                                <div style="height: 350px; background: linear-gradient(135deg, var(--purple-color), var(--blue-color)); display: flex; align-items: center; justify-content: center; color: var(--text-dark); border-radius: 20px;">
                                    <div class="text-center">
                                        <h2 class="fw-bold mb-3">🧸 Sevimli Peluşlar</h2>
                                        <p class="lead">En yumuşak dostlar!</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <button class="carousel-control-prev" type="button" data-bs-target="#heroCarousel" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon"></span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#heroCarousel" data-bs-slide="next">
                            <span class="carousel-control-next-icon"></span>
                        </button>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <h5><i class="fas fa-star me-2"></i>Öne Çıkan Ürün</h5>
                        </div>
                        <div class="card-body">
                            ${renderProductCard(mockProducts[0])}
                        </div>
                    </div>
                </div>
            </div>

            <!-- Category Quick Access -->
            <div class="row mb-5">
                <div class="col-12">
                    <h3 class="text-center mb-4 fw-bold">
                        <i class="fas fa-list me-2"></i>Kategoriler
                    </h3>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <div class="card text-center h-100">
                                <div class="card-body">
                                    <div class="mb-3" style="font-size: 3rem;">🏗️</div>
                                    <h6 class="fw-bold">Yapı Setleri</h6>
                                    <a href="/products?category=building" class="btn btn-sm btn-outline-primary">Görüntüle</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center h-100">
                                <div class="card-body">
                                    <div class="mb-3" style="font-size: 3rem;">👸</div>
                                    <h6 class="fw-bold">Bebekler</h6>
                                    <a href="/products?category=dolls" class="btn btn-sm btn-outline-primary">Görüntüle</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center h-100">
                                <div class="card-body">
                                    <div class="mb-3" style="font-size: 3rem;">🚗</div>
                                    <h6 class="fw-bold">Araçlar</h6>
                                    <a href="/products?category=vehicles" class="btn btn-sm btn-outline-primary">Görüntüle</a>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card text-center h-100">
                                <div class="card-body">
                                    <div class="mb-3" style="font-size: 3rem;">🎓</div>
                                    <h6 class="fw-bold">Eğitici</h6>
                                    <a href="/products?category=educational" class="btn btn-sm btn-outline-primary">Görüntüle</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Featured Products -->
            <div class="row mb-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-fire me-2"></i>Popüler Oyuncaklar</h4>
                        </div>
                        <div class="card-body">
                            <div class="row g-4">
                                ${featuredProducts.map((product) => `<div class="col-lg-3 col-md-6">${renderProductCard(product)}</div>`).join("")}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- New Arrivals -->
            <div class="row mb-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-sparkles me-2"></i>Yeni Gelenler</h4>
                        </div>
                        <div class="card-body">
                            <div class="row g-4">
                                ${newProducts.map((product) => `<div class="col-lg-3 col-md-6">${renderProductCard(product)}</div>`).join("")}
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Benefits Section -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row text-center g-4">
                                <div class="col-md-3">
                                    <div class="mb-3" style="font-size: 2.5rem; color: var(--primary-color);">
                                        <i class="fas fa-shipping-fast"></i>
                                    </div>
                                    <h5 class="fw-bold">Ücretsiz Kargo</h5>
                                    <p class="text-muted">500₺ üzeri siparişlerde</p>
                                </div>
                                <div class="col-md-3">
                                    <div class="mb-3" style="font-size: 2.5rem; color: var(--secondary-color);">
                                        <i class="fas fa-shield-alt"></i>
                                    </div>
                                    <h5 class="fw-bold">Güvenli Alışveriş</h5>
                                    <p class="text-muted">SSL sertifikalı ödeme</p>
                                </div>
                                <div class="col-md-3">
                                    <div class="mb-3" style="font-size: 2.5rem; color: var(--accent-color);">
                                        <i class="fas fa-undo"></i>
                                    </div>
                                    <h5 class="fw-bold">Kolay İade</h5>
                                    <p class="text-muted">14 gün içinde</p>
                                </div>
                                <div class="col-md-3">
                                    <div class="mb-3" style="font-size: 2.5rem; color: var(--purple-color);">
                                        <i class="fas fa-headset"></i>
                                    </div>
                                    <h5 class="fw-bold">7/24 Destek</h5>
                                    <p class="text-muted">Müşteri hizmetleri</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function addToCart(productId) {
            // Modern notification with SweetAlert style
            const product = ${JSON.stringify(mockProducts)}.find(p => p.id === productId);
            const notification = document.createElement('div');
            notification.className = 'alert alert-success position-fixed';
            notification.style.cssText = 'top: 100px; right: 20px; z-index: 9999; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);';
            notification.innerHTML = \`
                <i class="fas fa-check-circle me-2"></i>
                <strong>\${product.name}</strong> sepete eklendi!
            \`;
            document.body.appendChild(notification);
            setTimeout(() => notification.remove(), 3000);
        }
    </script>`;

  res.send(renderTemplate("Ana Sayfa", body, req));
});

app.get("/products", (req, res) => {
  const category = req.query.category;
  let filteredProducts = mockProducts;

  if (category) {
    filteredProducts = mockProducts.filter((p) =>
      p.category.toLowerCase().includes(category.toLowerCase()),
    );
  }

  const body = `
    <div class="main-container">
        <div class="container py-4">
            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-bold">
                        <i class="fas fa-toys me-2"></i>
                        ${category ? "Kategori: " + category : "Tüm Oyuncaklar"}
                        <span class="badge bg-primary">${filteredProducts.length}</span>
                    </h2>
                    <p class="text-muted">En kaliteli oyuncakları keşfedin</p>
                </div>
            </div>

            <!-- Filters -->
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="mb-3"><i class="fas fa-filter me-2"></i>Filtreler</h5>
                    <div class="row g-3">
                        <div class="col-md-2">
                            <select class="form-select" onchange="filterByCategory(this.value)">
                                <option value="">Tüm Kategoriler</option>
                                <option value="building" ${category === "building" ? "selected" : ""}>Yapı Setleri</option>
                                <option value="dolls" ${category === "dolls" ? "selected" : ""}>Bebekler</option>
                                <option value="vehicles" ${category === "vehicles" ? "selected" : ""}>Araçlar</option>
                                <option value="educational" ${category === "educational" ? "selected" : ""}>Eğitici</option>
                                <option value="electronic" ${category === "electronic" ? "selected" : ""}>Elektronik</option>
                                <option value="plush" ${category === "plush" ? "selected" : ""}>Peluş</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" onchange="filterByAge(this.value)">
                                <option value="">Tüm Yaşlar</option>
                                <option value="0-3">0-3 Yaş</option>
                                <option value="3-6">3-6 Yaş</option>
                                <option value="6-12">6-12 Yaş</option>
                                <option value="12+">12+ Yaş</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <select class="form-select" onchange="sortProducts(this.value)">
                                <option value="">Sırala</option>
                                <option value="price-low">Fiyat (Düşük-Yüksek)</option>
                                <option value="price-high">Fiyat (Yüksek-Düşük)</option>
                                <option value="rating">En Yüksek Puan</option>
                                <option value="name">İsme Göre</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="Oyuncak ara..." id="searchInput">
                                <button class="btn btn-primary" onclick="searchProducts()">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="btn-group w-100">
                                <button class="btn btn-outline-secondary active" onclick="setView('grid')">
                                    <i class="fas fa-th"></i>
                                </button>
                                <button class="btn btn-outline-secondary" onclick="setView('list')">
                                    <i class="fas fa-list"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Products Grid -->
            <div class="row g-4" id="productsContainer">
                ${filteredProducts
                  .map(
                    (product) => `
                    <div class="col-lg-3 col-md-4 col-sm-6 product-item"
                         data-category="${product.category.toLowerCase()}"
                         data-age="${product.ageRange}"
                         data-price="${product.price}"
                         data-rating="${product.rating}"
                         data-name="${product.name.toLowerCase()}">
                        ${renderProductCard(product)}
                    </div>
                `,
                  )
                  .join("")}
            </div>

            ${
              filteredProducts.length === 0
                ? `
                <div class="text-center py-5">
                    <div style="font-size: 4rem; color: var(--text-light);">🔍</div>
                    <h4 class="text-muted">Aradığınız kriterlere uygun ürün bulunamadı</h4>
                    <a href="/products" class="btn btn-primary mt-3">Tüm Ürünleri Görüntüle</a>
                </div>
            `
                : ""
            }
        </div>
    </div>

    <script>
        function addToCart(productId) {
            const product = ${JSON.stringify(mockProducts)}.find(p => p.id === productId);
            const notification = document.createElement('div');
            notification.className = 'alert alert-success position-fixed';
            notification.style.cssText = 'top: 100px; right: 20px; z-index: 9999; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);';
            notification.innerHTML = \`
                <i class="fas fa-check-circle me-2"></i>
                <strong>\${product.name}</strong> sepete eklendi!
            \`;
            document.body.appendChild(notification);
            setTimeout(() => notification.remove(), 3000);
        }

        function filterByCategory(category) {
            if (category) {
                window.location.href = '/products?category=' + category;
            } else {
                window.location.href = '/products';
            }
        }

        function filterByAge(age) {
            const items = document.querySelectorAll('.product-item');
            items.forEach(item => {
                if (!age || item.dataset.age.includes(age.split('-')[0])) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        function sortProducts(sortBy) {
            const container = document.getElementById('productsContainer');
            const items = Array.from(container.children);

            items.sort((a, b) => {
                switch(sortBy) {
                    case 'price-low':
                        return parseFloat(a.dataset.price) - parseFloat(b.dataset.price);
                    case 'price-high':
                        return parseFloat(b.dataset.price) - parseFloat(a.dataset.price);
                    case 'rating':
                        return parseFloat(b.dataset.rating) - parseFloat(a.dataset.rating);
                    case 'name':
                        return a.dataset.name.localeCompare(b.dataset.name);
                    default:
                        return 0;
                }
            });

            items.forEach(item => container.appendChild(item));
        }

        function searchProducts() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            const items = document.querySelectorAll('.product-item');

            items.forEach(item => {
                if (item.dataset.name.includes(searchTerm)) {
                    item.style.display = 'block';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        function setView(viewType) {
            const buttons = document.querySelectorAll('.btn-group button');
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');

            // Grid/List view logic can be implemented here
        }
    </script>`;

  res.send(renderTemplate("Oyuncaklar", body, req));
});

app.get("/products/:id", (req, res) => {
  const productId = parseInt(req.params.id);
  const product = mockProducts.find((p) => p.id === productId);

  if (!product) {
    return res
      .status(404)
      .send(renderTemplate("Ürün Bulunamadı", "<h2>Ürün Bulunamadı</h2>", req));
  }

  const emoji = product.name.match(/[🏠🏰🏎️🧸🎮📱🎨🚁]/)?.[0] || "🧸";
  const stars =
    "★".repeat(Math.floor(product.rating)) +
    "☆".repeat(5 - Math.floor(product.rating));
  const relatedProducts = mockProducts
    .filter((p) => p.id !== product.id && p.category === product.category)
    .slice(0, 3);

  const body = `
    <div class="main-container">
        <div class="container py-4">
            <!-- Breadcrumb -->
            <nav aria-label="breadcrumb" class="mb-4">
                <ol class="breadcrumb">
                    <li class="breadcrumb-item"><a href="/" class="text-decoration-none">Ana Sayfa</a></li>
                    <li class="breadcrumb-item"><a href="/products" class="text-decoration-none">Oyuncaklar</a></li>
                    <li class="breadcrumb-item active">${product.name}</li>
                </ol>
            </nav>

            <div class="row g-5">
                <!-- Product Images -->
                <div class="col-lg-6">
                    <div class="product-image-main mb-3" style="height: 500px; background: linear-gradient(135deg, var(--blue-color), var(--pink-color)); border-radius: 20px; display: flex; align-items: center; justify-content: center; font-size: 8rem; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                        ${emoji}
                    </div>
                    <div class="row g-2">
                        <div class="col-3">
                            <div class="product-thumb" style="height: 100px; background: linear-gradient(45deg, var(--primary-color), var(--secondary-color)); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 2rem; cursor: pointer;">
                                ${emoji}
                            </div>
                        </div>
                        <div class="col-3">
                            <div class="product-thumb" style="height: 100px; background: linear-gradient(45deg, var(--accent-color), var(--purple-color)); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 2rem; cursor: pointer;">
                                📦
                            </div>
                        </div>
                        <div class="col-3">
                            <div class="product-thumb" style="height: 100px; background: linear-gradient(45deg, var(--secondary-color), var(--blue-color)); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 2rem; cursor: pointer;">
                                🎁
                            </div>
                        </div>
                        <div class="col-3">
                            <div class="product-thumb" style="height: 100px; background: linear-gradient(45deg, var(--pink-color), var(--accent-color)); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 2rem; cursor: pointer;">
                                ✨
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product Info -->
                <div class="col-lg-6">
                    <div class="product-info">
                        <span class="badge bg-primary mb-3">${product.category}</span>
                        <h1 class="fw-bold mb-3">${product.name}</h1>

                        <div class="rating mb-3">
                            <span class="text-warning">${stars}</span>
                            <span class="text-muted ms-2">(${product.rating}) • ${Math.floor(Math.random() * 100 + 50)} değerlendirme</span>
                        </div>

                        <div class="price-section mb-4">
                            <h2 class="price-tag mb-0">₺${(product.price * 30).toFixed(2)}</h2>
                            <small class="text-muted text-decoration-line-through">₺${(product.price * 35).toFixed(2)}</small>
                            <span class="badge bg-success ms-2">%14 İndirim</span>
                        </div>

                        <p class="lead mb-4">${product.description}</p>

                        <!-- Product Details -->
                        <div class="product-details mb-4">
                            <div class="row g-3">
                                <div class="col-6">
                                    <div class="detail-item p-3 bg-light rounded">
                                        <i class="fas fa-child text-primary me-2"></i>
                                        <strong>Yaş Grubu:</strong> ${product.ageRange}
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="detail-item p-3 bg-light rounded">
                                        <i class="fas fa-tag text-success me-2"></i>
                                        <strong>Marka:</strong> ${product.brand}
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="detail-item p-3 bg-light rounded">
                                        <i class="fas fa-check-circle text-success me-2"></i>
                                        <strong>Stok:</strong> Mevcut
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="detail-item p-3 bg-light rounded">
                                        <i class="fas fa-truck text-info me-2"></i>
                                        <strong>Kargo:</strong> Ücretsiz
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quantity and Add to Cart -->
                        <div class="purchase-section">
                            <div class="row g-3 align-items-center mb-4">
                                <div class="col-auto">
                                    <label for="quantity" class="form-label fw-bold">Adet:</label>
                                </div>
                                <div class="col-auto">
                                    <div class="input-group" style="width: 140px;">
                                        <button class="btn btn-outline-secondary quantity-left-minus" type="button">
                                            <i class="fas fa-minus"></i>
                                        </button>
                                        <input type="number" id="quantity" class="form-control text-center" value="1" min="1" max="10">
                                        <button class="btn btn-outline-secondary quantity-right-plus" type="button">
                                            <i class="fas fa-plus"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <div class="d-grid gap-2">
                                <button class="btn btn-success btn-lg" onclick="addToCart(${product.id})">
                                    <i class="fas fa-cart-plus me-2"></i>Sepete Ekle
                                </button>
                                <button class="btn btn-warning">
                                    <i class="fas fa-heart me-2"></i>Favorilere Ekle
                                </button>
                            </div>

                            <div class="mt-3 text-center">
                                <small class="text-muted">
                                    <i class="fas fa-shield-alt me-1"></i>Güvenli ödeme
                                    <span class="mx-2">•</span>
                                    <i class="fas fa-undo me-1"></i>14 gün iade hakkı
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Product Tabs -->
            <div class="row mt-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <ul class="nav nav-tabs card-header-tabs" role="tablist">
                                <li class="nav-item">
                                    <a class="nav-link active" data-bs-toggle="tab" href="#description">Açıklama</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" data-bs-toggle="tab" href="#features">Özellikler</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" data-bs-toggle="tab" href="#reviews">Değerlendirmeler</a>
                                </li>
                            </ul>
                        </div>
                        <div class="card-body">
                            <div class="tab-content">
                                <div class="tab-pane active" id="description">
                                    <p class="lead">${product.description}</p>
                                    <p>Bu harika oyuncak çocukların hayal gücünü geliştirmek için özel olarak tasarlanmıştır. Kaliteli malzemelerden üretilmiş ve güvenlik standartlarına uygun olarak test edilmiştir.</p>
                                </div>
                                <div class="tab-pane" id="features">
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item">✅ CE sertifikalı güvenli malzeme</li>
                                        <li class="list-group-item">✅ Dayanıklı ve uzun ömürlü</li>
                                        <li class="list-group-item">✅ Eğitici ve eğlenceli</li>
                                        <li class="list-group-item">✅ Yaş grubuna uygun tasarım</li>
                                        <li class="list-group-item">✅ Kolay temizlenebilir</li>
                                    </ul>
                                </div>
                                <div class="tab-pane" id="reviews">
                                    <div class="mb-4">
                                        <h5>Müşteri Değerlendirmeleri</h5>
                                        <div class="d-flex align-items-center mb-3">
                                            <span class="text-warning me-2">${stars}</span>
                                            <span class="fw-bold me-2">${product.rating}</span>
                                            <span class="text-muted">(${Math.floor(Math.random() * 100 + 50)} değerlendirme)</span>
                                        </div>
                                    </div>
                                    <div class="review-item border-bottom pb-3 mb-3">
                                        <div class="d-flex align-items-center mb-2">
                                            <strong>Ayşe K.</strong>
                                            <span class="text-warning ms-2">★★★★★</span>
                                        </div>
                                        <p class="mb-0">Çocuğum çok sevdi! Kaliteli ve eğlenceli bir oyuncak.</p>
                                    </div>
                                    <div class="review-item">
                                        <div class="d-flex align-items-center mb-2">
                                            <strong>Mehmet Y.</strong>
                                            <span class="text-warning ms-2">★★★★☆</span>
                                        </div>
                                        <p class="mb-0">Hızlı kargo ve güzel paketleme. Ürün açıklamaya uygun.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Related Products -->
            ${
              relatedProducts.length > 0
                ? `
            <div class="row mt-5">
                <div class="col-12">
                    <h3 class="mb-4"><i class="fas fa-heart me-2"></i>Benzer Ürünler</h3>
                    <div class="row g-4">
                        ${relatedProducts
                          .map(
                            (relatedProduct) => `
                            <div class="col-lg-4">
                                ${renderProductCard(relatedProduct)}
                            </div>
                        `,
                          )
                          .join("")}
                    </div>
                </div>
            </div>
            `
                : ""
            }

            <div class="text-center mt-4">
                <a href="/products" class="btn btn-outline-primary">
                    <i class="fas fa-arrow-left me-2"></i>Tüm Oyuncaklara Dön
                </a>
            </div>
        </div>
    </div>

    <script>
        function addToCart(productId) {
            const quantity = document.getElementById('quantity').value;
            const product = ${JSON.stringify(mockProducts)}.find(p => p.id === productId);

            const notification = document.createElement('div');
            notification.className = 'alert alert-success position-fixed';
            notification.style.cssText = 'top: 100px; right: 20px; z-index: 9999; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.2);';
            notification.innerHTML = \`
                <i class="fas fa-check-circle me-2"></i>
                <strong>\${quantity} adet \${product.name}</strong> sepete eklendi!
            \`;
            document.body.appendChild(notification);
            setTimeout(() => notification.remove(), 3000);
        }
    </script>`;

  res.send(renderTemplate(product.name, body, req));
});

app.get("/cart", (req, res) => {
  const body = `
    <div class="main-container">
        <div class="container py-4">
            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-bold">
                        <i class="fas fa-shopping-cart me-2"></i>Alışveriş Sepetim
                    </h2>
                    <p class="text-muted">Sepetinizdeki ürünleri inceleyin</p>
                </div>
            </div>

            <div class="alert alert-info border-0 rounded-3">
                <div class="d-flex align-items-center">
                    <i class="fas fa-info-circle me-3 fa-2x"></i>
                    <div>
                        <h5 class="mb-1">Geliştirme Önizlemesi</h5>
                        <p class="mb-0">Sepet işlevselliği backend mikroservislerin çalışmasını gerektirir. Şu anda demo modunda çalışmaktasınız.</p>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <!-- Cart Items -->
                <div class="col-lg-8">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-list me-2"></i>Sepetim</h4>
                        </div>
                        <div class="card-body">
                            <!-- Empty Cart State -->
                            <div class="text-center py-5">
                                <div class="mb-4" style="font-size: 4rem; color: var(--text-light);">🛒</div>
                                <h4 class="text-muted mb-3">Sepetiniz şu anda boş</h4>
                                <p class="text-muted mb-4">Harika oyuncaklar keşfetmek için alışverişe başlayın!</p>
                                <a href="/products" class="btn btn-primary btn-lg">
                                    <i class="fas fa-toys me-2"></i>Oyuncakları Keşfet
                                </a>
                            </div>

                            <!-- Demo Cart Items (can be shown when items exist) -->
                            <div class="d-none">
                                <div class="cart-item d-flex align-items-center border-bottom py-3">
                                    <div class="cart-item-image me-3" style="width: 80px; height: 80px; background: var(--blue-color); border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 2rem;">
                                        🧸
                                    </div>
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1">LEGO Creator Expert</h6>
                                        <small class="text-muted">Yapı Setleri</small>
                                        <div class="mt-2">
                                            <span class="fw-bold text-success">₺2,699.70</span>
                                        </div>
                                    </div>
                                    <div class="cart-item-controls d-flex align-items-center">
                                        <button class="btn btn-sm btn-outline-secondary me-2">-</button>
                                        <span class="mx-2">1</span>
                                        <button class="btn btn-sm btn-outline-secondary me-3">+</button>
                                        <button class="btn btn-sm btn-outline-danger">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Suggested Products -->
                    <div class="card mt-4">
                        <div class="card-header">
                            <h5><i class="fas fa-lightbulb me-2"></i>Size Önerilir</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                ${mockProducts
                                  .slice(0, 3)
                                  .map(
                                    (product) => `
                                    <div class="col-md-4">
                                        <div class="suggested-item text-center p-3 border rounded">
                                            <div class="mb-2" style="font-size: 2rem;">${product.name.match(/[🏠🏰🏎️🧸🎮📱🎨🚁]/)?.[0] || "🧸"}</div>
                                            <h6 class="mb-1">${product.name}</h6>
                                            <div class="text-success fw-bold mb-2">₺${(product.price * 30).toFixed(2)}</div>
                                            <button class="btn btn-sm btn-outline-primary">Sepete Ekle</button>
                                        </div>
                                    </div>
                                `,
                                  )
                                  .join("")}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Order Summary -->
                <div class="col-lg-4">
                    <div class="card sticky-top" style="top: 100px;">
                        <div class="card-header">
                            <h4><i class="fas fa-calculator me-2"></i>Sipariş Özeti</h4>
                        </div>
                        <div class="card-body">
                            <div class="summary-row d-flex justify-content-between mb-2">
                                <span>Ara Toplam:</span>
                                <span>₺0,00</span>
                            </div>
                            <div class="summary-row d-flex justify-content-between mb-2">
                                <span>Kargo:</span>
                                <span class="text-success">Ücretsiz</span>
                            </div>
                            <div class="summary-row d-flex justify-content-between mb-3">
                                <span>İndirim:</span>
                                <span class="text-success">-₺0,00</span>
                            </div>
                            <hr>
                            <div class="summary-total d-flex justify-content-between mb-4">
                                <strong>Toplam:</strong>
                                <strong class="text-success">₺0,00</strong>
                            </div>

                            <div class="d-grid gap-2">
                                <button class="btn btn-success btn-lg" disabled>
                                    <i class="fas fa-credit-card me-2"></i>Ödemeye Geç
                                </button>
                                <button class="btn btn-outline-secondary">
                                    <i class="fas fa-heart me-2"></i>Favorilere Kaydet
                                </button>
                            </div>

                            <!-- Promo Code -->
                            <div class="mt-4">
                                <label class="form-label"><i class="fas fa-tag me-2"></i>Promosyon Kodu</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" placeholder="Kod giriniz">
                                    <button class="btn btn-outline-secondary">Uygula</button>
                                </div>
                            </div>

                            <!-- Payment Methods -->
                            <div class="mt-4">
                                <small class="text-muted d-block mb-2">Kabul edilen ödeme yöntemleri:</small>
                                <div class="payment-methods">
                                    <i class="fab fa-cc-visa fa-2x me-2 text-primary"></i>
                                    <i class="fab fa-cc-mastercard fa-2x me-2 text-warning"></i>
                                    <i class="fas fa-credit-card fa-2x me-2 text-success"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Security Info -->
                    <div class="card mt-3">
                        <div class="card-body text-center">
                            <i class="fas fa-shield-alt fa-2x text-success mb-2"></i>
                            <h6>Güvenli Alışveriş</h6>
                            <small class="text-muted">256-bit SSL sertifikası ile korumalı</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>`;

  res.send(renderTemplate("Sepetim", body, req));
});

app.get("/orders", (req, res) => {
  const body = `
    <div class="main-container">
        <div class="container py-4">
            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-bold">
                        <i class="fas fa-list-alt me-2"></i>Siparişlerim
                    </h2>
                    <p class="text-muted">Geçmiş siparişlerinizi takip edin</p>
                </div>
            </div>

            <div class="alert alert-info border-0 rounded-3">
                <div class="d-flex align-items-center">
                    <i class="fas fa-info-circle me-3 fa-2x"></i>
                    <div>
                        <h5 class="mb-1">Geliştirme Önizlemesi</h5>
                        <p class="mb-0">Sipariş işlevselliği backend mikroservislerin çalışmasını gerektirir. Şu anda demo modunda çalışmaktasınız.</p>
                    </div>
                </div>
            </div>

            <!-- Empty Orders State -->
            <div class="card">
                <div class="card-body">
                    <div class="text-center py-5">
                        <div class="mb-4" style="font-size: 4rem; color: var(--text-light);">📦</div>
                        <h4 class="text-muted mb-3">Henüz siparişiniz bulunmuyor</h4>
                        <p class="text-muted mb-4">İlk siparişinizi oluşturmak için alışverişe başlayın!</p>
                        <a href="/products" class="btn btn-primary btn-lg">
                            <i class="fas fa-toys me-2"></i>Alışverişe Başla
                        </a>
                    </div>
                </div>
            </div>

            <!-- Demo Orders (when orders exist) -->
            <div class="d-none">
                <div class="row g-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div>
                                    <h5 class="mb-0">Sipariş #TOY2024001</h5>
                                    <small class="text-muted">15 Mart 2024</small>
                                </div>
                                <span class="badge bg-success fs-6">Teslim Edildi</span>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="order-items">
                                            <div class="d-flex align-items-center mb-3">
                                                <div class="order-item-image me-3" style="width: 60px; height: 60px; background: var(--blue-color); border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem;">
                                                    🧸
                                                </div>
                                                <div>
                                                    <h6 class="mb-1">LEGO Creator Expert</h6>
                                                    <small class="text-muted">Adet: 1</small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4 text-end">
                                        <div class="order-total mb-2">
                                            <strong>₺2,699.70</strong>
                                        </div>
                                        <div class="order-actions">
                                            <button class="btn btn-sm btn-outline-primary me-2">Detaylar</button>
                                            <button class="btn btn-sm btn-outline-secondary">Tekrar Sipariş</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h5><i class="fas fa-bolt me-2"></i>Hızlı İşlemler</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <a href="/products" class="btn btn-outline-primary w-100">
                                        <i class="fas fa-toys d-block mb-2 fa-2x"></i>
                                        Yeni Sipariş
                                    </a>
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-outline-secondary w-100">
                                        <i class="fas fa-heart d-block mb-2 fa-2x"></i>
                                        Favorilerim
                                    </button>
                                </div>
                                <div class="col-md-3">
                                    <button class="btn btn-outline-info w-100">
                                        <i class="fas fa-truck d-block mb-2 fa-2x"></i>
                                        Kargo Takip
                                    </button>
                                </div>
                                <div class="col-md-3">
                                    <a href="/contact" class="btn btn-outline-warning w-100">
                                        <i class="fas fa-headset d-block mb-2 fa-2x"></i>
                                        Destek
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>`;

  res.send(renderTemplate("Siparişlerim", body, req));
});

app.get("/contact", (req, res) => {
  const body = `
    <div class="main-container">
        <div class="container py-4">
            <div class="row mb-4">
                <div class="col-12 text-center">
                    <h2 class="fw-bold">
                        <i class="fas fa-envelope me-2"></i>Bizimle İletişime Geçin
                    </h2>
                    <p class="text-muted">Sorularınız için buradayız! Size nasıl yardımcı olabiliriz?</p>
                </div>
            </div>

            <div class="row g-5">
                <!-- Contact Form -->
                <div class="col-lg-8">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-paper-plane me-2"></i>Mesaj Gönder</h4>
                        </div>
                        <div class="card-body">
                            <form class="needs-validation" novalidate>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="name" class="form-label">
                                            <i class="fas fa-user me-2"></i>Ad Soyad
                                        </label>
                                        <input type="text" class="form-control" id="name" required>
                                        <div class="invalid-feedback">Lütfen adınızı ve soyadınızı girin.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="email" class="form-label">
                                            <i class="fas fa-envelope me-2"></i>E-posta
                                        </label>
                                        <input type="email" class="form-control" id="email" required>
                                        <div class="invalid-feedback">Lütfen geçerli bir e-posta adresi girin.</div>
                                    </div>
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label for="phone" class="form-label">
                                            <i class="fas fa-phone me-2"></i>Telefon
                                        </label>
                                        <input type="tel" class="form-control" id="phone">
                                    </div>
                                    <div class="col-md-6">
                                        <label for="subject" class="form-label">
                                            <i class="fas fa-tag me-2"></i>Konu
                                        </label>
                                        <select class="form-select" id="subject" required>
                                            <option value="">Konu seçin</option>
                                            <option value="product">Ürün Sorunu</option>
                                            <option value="order">Sipariş Sorunu</option>
                                            <option value="return">İade Talebi</option>
                                            <option value="suggestion">Öneri</option>
                                            <option value="other">Diğer</option>
                                        </select>
                                        <div class="invalid-feedback">Lütfen bir konu seçin.</div>
                                    </div>
                                </div>
                                <div class="mb-4">
                                    <label for="message" class="form-label">
                                        <i class="fas fa-comment me-2"></i>Mesajınız
                                    </label>
                                    <textarea class="form-control" id="message" rows="6" placeholder="Mesajınızı buraya yazın..." required></textarea>
                                    <div class="invalid-feedback">Lütfen mesajınızı yazın.</div>
                                </div>
                                <div class="mb-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="privacy" required>
                                        <label class="form-check-label" for="privacy">
                                            <a href="/privacy" class="text-decoration-none">Gizlilik Politikası</a>nı okudum ve kabul ediyorum.
                                        </label>
                                        <div class="invalid-feedback">Gizlilik politikasını kabul etmelisiniz.</div>
                                    </div>
                                </div>
                                <button class="btn btn-primary btn-lg" type="submit">
                                    <i class="fas fa-paper-plane me-2"></i>Mesajı Gönder
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Contact Information -->
                <div class="col-lg-4">
                    <div class="card h-100">
                        <div class="card-header">
                            <h4><i class="fas fa-address-book me-2"></i>İletişim Bilgileri</h4>
                        </div>
                        <div class="card-body">
                            <div class="contact-item mb-4">
                                <div class="d-flex align-items-start mb-3">
                                    <div class="contact-icon me-3">
                                        <i class="fas fa-map-marker-alt fa-lg text-primary"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-1">Adres</h6>
                                        <p class="text-muted mb-0">
                                            ToyShop Merkez Mağaza<br>
                                            Çocuk Sokak No: 123<br>
                                            Oyuncak Mahallesi, İstanbul 34000
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="contact-item mb-4">
                                <div class="d-flex align-items-start mb-3">
                                    <div class="contact-icon me-3">
                                        <i class="fas fa-phone fa-lg text-success"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-1">Telefon</h6>
                                        <p class="text-muted mb-0">
                                            <a href="tel:+902121234567" class="text-decoration-none">+90 212 123 45 67</a><br>
                                            <small>Müşteri Hizmetleri</small>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="contact-item mb-4">
                                <div class="d-flex align-items-start mb-3">
                                    <div class="contact-icon me-3">
                                        <i class="fas fa-envelope fa-lg text-info"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-1">E-posta</h6>
                                        <p class="text-muted mb-0">
                                            <a href="mailto:info@toyshop.com" class="text-decoration-none">info@toyshop.com</a><br>
                                            <a href="mailto:destek@toyshop.com" class="text-decoration-none">destek@toyshop.com</a>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="contact-item mb-4">
                                <div class="d-flex align-items-start mb-3">
                                    <div class="contact-icon me-3">
                                        <i class="fas fa-clock fa-lg text-warning"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-1">Çalışma Saatleri</h6>
                                        <p class="text-muted mb-0">
                                            <strong>Pazartesi - Cumartesi:</strong><br>
                                            09:00 - 22:00<br>
                                            <strong>Pazar:</strong><br>
                                            10:00 - 20:00
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <div class="social-links">
                                <h6 class="mb-3">Sosyal Medya</h6>
                                <div class="d-flex gap-3">
                                    <a href="#" class="btn btn-outline-primary rounded-circle">
                                        <i class="fab fa-facebook"></i>
                                    </a>
                                    <a href="#" class="btn btn-outline-info rounded-circle">
                                        <i class="fab fa-instagram"></i>
                                    </a>
                                    <a href="#" class="btn btn-outline-primary rounded-circle">
                                        <i class="fab fa-twitter"></i>
                                    </a>
                                    <a href="#" class="btn btn-outline-danger rounded-circle">
                                        <i class="fab fa-youtube"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- FAQ Section -->
            <div class="row mt-5">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4><i class="fas fa-question-circle me-2"></i>Sık Sorulan Sorular</h4>
                        </div>
                        <div class="card-body">
                            <div class="accordion" id="faqAccordion">
                                <div class="accordion-item">
                                    <h2 class="accordion-header">
                                        <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1">
                                            Kargo ücreti ne kadar?
                                        </button>
                                    </h2>
                                    <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body">
                                            500₺ ve üzeri siparişlerde kargo tamamen ücretsizdir. 500₺ altı siparişlerde kargo ücreti 29₺'dir.
                                        </div>
                                    </div>
                                </div>
                                <div class="accordion-item">
                                    <h2 class="accordion-header">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                                            İade koşulları nelerdir?
                                        </button>
                                    </h2>
                                    <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body">
                                            Ürünlerinizi teslim aldığınız tarihten itibaren 14 gün içinde, ambalajında ve hiç kullanılmamış olarak iade edebilirsiniz.
                                        </div>
                                    </div>
                                </div>
                                <div class="accordion-item">
                                    <h2 class="accordion-header">
                                        <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                                            Siparişimi nasıl takip edebilirim?
                                        </button>
                                    </h2>
                                    <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
                                        <div class="accordion-body">
                                            Siparişiniz onaylandıktan sonra size gönderilen kargo takip numarasıyla siparişinizi takip edebilirsiniz.
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>`;

  res.send(renderTemplate("İletişim", body, req));
});

// API endpoints for future integration
// API Proxy middleware for backend services
app.use(
  "/api/catalog",
  createProxyMiddleware({
    target: BACKEND_SERVICES.GATEWAY_URL,
    changeOrigin: true,
    pathRewrite: {
      "^/api/catalog": "/catalog-service",
    },
    onError: (err, req, res) => {
      console.log("Catalog API error, falling back to mock data");
      // Fallback to mock data
      if (req.url.includes("/products")) {
        res.json(mockProducts);
      } else {
        res.status(500).json({ error: "Service unavailable" });
      }
    },
  }),
);

app.use(
  "/api/basket",
  createProxyMiddleware({
    target: BACKEND_SERVICES.GATEWAY_URL,
    changeOrigin: true,
    pathRewrite: {
      "^/api/basket": "/basket-service",
    },
    onError: (err, req, res) => {
      console.log("Basket API error");
      res.status(500).json({ error: "Basket service unavailable" });
    },
  }),
);

app.use(
  "/api/ordering",
  createProxyMiddleware({
    target: BACKEND_SERVICES.GATEWAY_URL,
    changeOrigin: true,
    pathRewrite: {
      "^/api/ordering": "/ordering-service",
    },
    onError: (err, req, res) => {
      console.log("Ordering API error");
      res.status(500).json({ error: "Ordering service unavailable" });
    },
  }),
);

// Health check endpoint
app.get("/api/health", async (req, res) => {
  const services = {
    frontend: true,
    gateway: false,
    catalog: false,
    basket: false,
    ordering: false,
  };

  try {
    const fetch = require("node-fetch");

    // Test Gateway
    try {
      const gatewayResponse = await fetch(
        `${BACKEND_SERVICES.GATEWAY_URL}/health`,
        { timeout: 2000 },
      );
      services.gateway = gatewayResponse.ok;
    } catch (error) {
      services.gateway = false;
    }

    // Test individual services if gateway is not available
    if (!services.gateway) {
      try {
        const catalogResponse = await fetch(
          `${BACKEND_SERVICES.CATALOG_API}/health`,
          { timeout: 2000 },
        );
        services.catalog = catalogResponse.ok;
      } catch (error) {
        services.catalog = false;
      }

      try {
        const basketResponse = await fetch(
          `${BACKEND_SERVICES.BASKET_API}/health`,
          { timeout: 2000 },
        );
        services.basket = basketResponse.ok;
      } catch (error) {
        services.basket = false;
      }

      try {
        const orderingResponse = await fetch(
          `${BACKEND_SERVICES.ORDERING_API}/health`,
          { timeout: 2000 },
        );
        services.ordering = orderingResponse.ok;
      } catch (error) {
        services.ordering = false;
      }
    } else {
      // If gateway is available, assume services are available through gateway
      services.catalog = true;
      services.basket = true;
      services.ordering = true;
    }
  } catch (error) {
    console.log("Health check error:", error.message);
  }

  const isHealthy =
    services.gateway ||
    (services.catalog && services.basket && services.ordering);

  res.status(isHealthy ? 200 : 503).json({
    status: isHealthy ? "healthy" : "degraded",
    services: services,
    timestamp: new Date().toISOString(),
    mode: isHealthy ? "backend" : "mock",
  });
});

// Legacy API endpoints - fallback to mock data if backend not available
app.get("/api/products", async (req, res) => {
  try {
    if (backendAvailable) {
      // Try to proxy to backend
      const fetch = require("node-fetch");
      const response = await fetch(
        `${BACKEND_SERVICES.GATEWAY_URL}/catalog-service/products`,
      );
      if (response.ok) {
        const data = await response.json();
        return res.json(data);
      }
    }
  } catch (error) {
    console.log("Backend API failed, using mock data");
  }

  // Fallback to mock data
  res.json(mockProducts);
});

app.get("/api/products/:id", async (req, res) => {
  const productId = parseInt(req.params.id);

  try {
    if (backendAvailable) {
      // Try to proxy to backend
      const fetch = require("node-fetch");
      const response = await fetch(
        `${BACKEND_SERVICES.GATEWAY_URL}/catalog-service/products/${productId}`,
      );
      if (response.ok) {
        const data = await response.json();
        return res.json(data);
      }
    }
  } catch (error) {
    console.log("Backend API failed, using mock data");
  }

  // Fallback to mock data
  const product = mockProducts.find((p) => p.id === productId);
  if (!product) {
    return res.status(404).json({ error: "Product not found" });
  }
  res.json(product);
});

// Development notice for other routes
app.get("*", (req, res) => {
  const body = `
    <div class="main-container">
        <div class="container py-4">
            <!-- Backend Status Alert -->
            <div id="backend-status" class="alert alert-warning d-none mb-4">
                <div class="d-flex align-items-center">
                    <div class="spinner-border spinner-border-sm me-2" role="status">
                        <span class="visually-hidden">Yükleniyor...</span>
                    </div>
                    <span>Backend servislerin durumu kontrol ediliyor...</span>
                </div>
            </div>

            <div class="row mb-4">
                <div class="col-12">
                    <h2 class="fw-bold">
                        <i class="fas fa-toys me-2"></i>
                        ${category ? "Kategori: " + category : "Tüm Oyuncaklar"}
                        <span class="badge bg-primary">${filteredProducts.length}</span>
                    </h2>
                    <p class="text-muted">En kaliteli oyuncakları keşfedin</p>
                </div>
            </div>
                    <div class="col-auto">
                        <a href="/" class="btn btn-primary btn-lg">
                            <i class="fas fa-home me-2"></i>Ana Sayfa
                        </a>
                    </div>
                    <div class="col-auto">
                        <a href="/products" class="btn btn-success btn-lg">
                            <i class="fas fa-toys me-2"></i>Oyuncaklar
                        </a>
                    </div>
                    <div class="col-auto">
                        <a href="/contact" class="btn btn-info btn-lg">
                            <i class="fas fa-envelope me-2"></i>İletişim
                        </a>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5><i class="fas fa-cogs me-2"></i>Tam Uygulama İçin Gereksinimler</h5>
                    </div>
                    <div class="card-body">
                        <div class="row g-4">
                            <div class="col-md-3 text-center">
                                <i class="fas fa-code fa-2x text-primary mb-2"></i>
                                <h6>.NET 8 SDK</h6>
                                <small class="text-muted">Backend mikroservisler</small>
                            </div>
                            <div class="col-md-3 text-center">
                                <i class="fas fa-docker fa-2x text-info mb-2"></i>
                                <h6>Docker & Compose</h6>
                                <small class="text-muted">Konteyner yönetimi</small>
                            </div>
                            <div class="col-md-3 text-center">
                                <i class="fas fa-database fa-2x text-success mb-2"></i>
                                <h6>Veritabanları</h6>
                                <small class="text-muted">PostgreSQL, SQL Server, Redis</small>
                            </div>
                            <div class="col-md-3 text-center">
                                <i class="fas fa-exchange-alt fa-2x text-warning mb-2"></i>
                                <h6>RabbitMQ</h6>
                                <small class="text-muted">Mesaj kuyruğu</small>
                            </div>
                        </div>
                        <div class="mt-4">
                            <p class="text-muted mb-0">
                                <i class="fas fa-terminal me-2"></i>
                                Tam kurulum için: <code>setup.ps1</code> dosyasını çalıştırın
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>`;

  res.send(renderTemplate("Sayfa Bulunamadı", body, req));
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
