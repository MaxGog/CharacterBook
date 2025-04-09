using System.Collections.ObjectModel;

using SQLite;

using CharacterBook.Models;

namespace CharacterBook.Services;

public class CharacterStorageService : IAsyncDisposable
{
    private readonly string databasePath;
    private SQLiteAsyncConnection connection;

    public CharacterStorageService()
    {
        databasePath = Path.Combine(FileSystem.AppDataDirectory, "characters.db");
        InitializeDatabase();
    }

    private void InitializeDatabase()
    {
        connection = new SQLiteAsyncConnection(databasePath);
        connection.CreateTableAsync<Character>().Wait();
    }

    public async Task<ObservableCollection<Character>> GetAllCharactersAsync()
    {
        try
        {
            InitializeConnection();
            var characters = await connection.Table<Character>()
                .OrderBy(n => n.CreatedAt)
                .ToListAsync();
            return new ObservableCollection<Character>(characters);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметок: {ex.Message}");
        }
    }

    public async Task<Character> GetCharacterAsync(string id)
    {
        try
        {
            InitializeConnection();
            return await connection.Table<Character>().Where(n => n.Id == id).FirstOrDefaultAsync();
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметки: {ex.Message}");
        }
    }

    public async Task SaveCharacterAsync(Character character)
    {
        try
        {
            InitializeConnection();
            if (string.IsNullOrEmpty(character.Id))
            {
                character.Id = Guid.NewGuid().ToString();
                await connection.InsertAsync(character);
            }
            else
            {
                await connection.UpdateAsync(character);
            }
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при сохранении заметки: {ex.Message}");
        }
    }

    public async Task DeleteCharacterAsync(string id)
    {
        try
        {
            InitializeConnection();
            await connection.DeleteAsync<Character>(id);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при удалении заметки: {ex.Message}");
        }
    }

    public async Task UpdateCharacterAsync(Character character)
    {
        try
        {
            InitializeConnection();
            await connection.UpdateAsync(character);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при обновлении заметки: {ex.Message}");
        }
    }

    private void InitializeConnection()
    {
        if (connection == null)
        {
            InitializeDatabase();
        }
    }

    public ValueTask DisposeAsync()
    {
        throw new NotImplementedException();
    }

    /*public async Task<bool> ExportCharacterAsync(Character character, string filePath)
    {
        try
        {
            var characterJson = JsonSerializer.Serialize(character);
            await File.WriteAllTextAsync(filePath, characterJson);
            
            // Копируем изображение, если оно существует
            if (!string.IsNullOrEmpty(character.ImageData))
            {
                var imageFile = Path.Combine(FileSystem.AppDataDirectory, character.ImageData);
                if (File.Exists(imageFile))
                {
                    var destImagePath = Path.Combine(Path.GetDirectoryName(filePath), 
                        $"{character.Name}_image{Path.GetExtension(character.ImageData)}");
                    await File.CopyAsync(imageFile, destImagePath);
                }
            }
            
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Ошибка при экспорте персонажа: {ex.Message}");
            return false;
        }
    }*/
}
