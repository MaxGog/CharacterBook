namespace CharacterBook.Constants;

public static class DatabaseConstants
{
    public const string CharactersDatabaseFilename = "Characters.db3";
    public const string FractionsDatabaseFilename = "Fractions.db3";
    public const SQLite.SQLiteOpenFlags Flags =
        SQLite.SQLiteOpenFlags.ReadWrite | SQLite.SQLiteOpenFlags.Create | SQLite.SQLiteOpenFlags.SharedCache;

    public static string CharactersDatabasePath => Path.Combine(FileSystem.AppDataDirectory, CharactersDatabaseFilename);
    public static string FractionsDatabasePath => Path.Combine(FileSystem.AppDataDirectory, FractionsDatabaseFilename);
}
