using MongoDB.Driver;

namespace Identity.API.Data;

public class MongoIdentityContext
{
    public IMongoDatabase Database { get; }
    
    public MongoIdentityContext(IMongoClient client, string databaseName)
    {
        Database = client.GetDatabase(databaseName);
    }
    
    public IMongoCollection<ApplicationUser> Users => Database.GetCollection<ApplicationUser>("users");
    public IMongoCollection<ApplicationRole> Roles => Database.GetCollection<ApplicationRole>("roles");
}
