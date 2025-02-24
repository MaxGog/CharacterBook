using SQLite;

using CharacterBook.Models;

namespace CharacterBook.Data;

public static class DatabaseConnectionClass
{
    private static readonly string _databasePath;
    private static readonly Lazy<SQLiteAsyncConnection> _connection;

    static DatabaseConnectionClass()
    {
        var basePath = Path.Combine(FileSystem.AppDataDirectory, "characters.db");
        _databasePath = basePath;
        _connection = new Lazy<SQLiteAsyncConnection>(() 
            => new SQLiteAsyncConnection(basePath));
    }

    public static SQLiteAsyncConnection Connection => _connection.Value;

    public static async Task InitializeDatabase()
    {
        await Connection.CreateTableAsync<CharacterModel>();
        await Connection.CreateTableAsync<CharacterImage>();
    }

    public static string filePath => _databasePath;
}