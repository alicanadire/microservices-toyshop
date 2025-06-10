// This file is kept for compatibility but not used with MongoDB
// MongoDB uses its own document-based storage system
// Identity data is now stored in MongoDB collections:
// - users collection for ApplicationUser
// - roles collection for ApplicationRole

namespace Identity.API.Data;

public class IdentityDbContext
{
    // This class is no longer used with MongoDB implementation
    // MongoDB context is handled by MongoIdentityContext
}
