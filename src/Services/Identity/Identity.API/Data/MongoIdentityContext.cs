// This file is no longer needed as MongoDB collections are handled automatically
// by AspNetCore.Identity.MongoDbCore package

using MongoDB.Driver;

namespace Identity.API.Data;

/// <summary>
/// Legacy MongoDB Context - Not needed with AspNetCore.Identity.MongoDbCore
/// The package automatically handles MongoDB collections for Identity
/// </summary>
[Obsolete("This context is not needed. AspNetCore.Identity.MongoDbCore handles MongoDB collections automatically")]
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
