using SQLite;

using CharacterBook.Models;
using CharacterBook.Constants;

namespace CharacterBook.Data;

public class CharacterManager(CharacterContext context)
{
    private readonly CharacterContext Context = context;

    public async Task<List<Character>> GetCharactersAsync()
    {
        return await Context.GetAllCharactersAsync();
    }

    public async Task<Character> GetCharacterAsync(int id)
    {
        return await Context.GetCharacterAsync(id);
    }

    public async Task UpdateCharacterAsync(Character character)
    {
        await Context.SaveCharacterAsync(character);
    }

    public async Task DeleteCharacterAsync(int id)
    {
        var character = await Context.GetCharacterAsync(id);
        if (character != null)
        {
            await Context.DeleteCharacterAsync(character);
            
            // Удаляем изображение при удалении персонажа
            /*if (!string.IsNullOrEmpty(character.ImageData))
            {
                var imageFile = Path.Combine(FileSystem.AppDataDirectory, character.ImageData);
                if (File.Exists(imageFile))
                {
                    File.Delete(imageFile);
                }
            }*/
        }
    }

    public async Task ToggleFavoriteAsync(int id)
    {
        var character = await Context.GetCharacterAsync(id);
        if (character != null)
        {
            character.IsFavorite = !character.IsFavorite;
            await Context.SaveCharacterAsync(character);
        }
    }

    /*public async Task<bool> ExportCharacterAsync(int id, string filePath)
    {
        var character = await Context.GetCharacterAsync(id);
        if (character != null)
        {
            return await Context.ExportCharacterAsync(character, filePath);
        }
        return false;
    }*/
}

public class CharacterContext
{
    private SQLiteAsyncConnection Database;

    public async Task Init()
    {
        if (Database != null)
            return;

        Database = new SQLiteAsyncConnection(Constants.Constants.DatabasePath, Constants.Constants.Flags);
        await Database.CreateTableAsync<Character>();
    }

    public async Task<List<Character>> GetAllCharactersAsync()
    {
        await Init();
        return await Database.Table<Character>().ToListAsync();
    }

    public async Task<Character> GetCharacterAsync(int id)
    {
        await Init();
        return await Database.Table<Character>()
            .Where(c => c.Id == id)
            .FirstOrDefaultAsync();
    }

    public async Task<int> SaveCharacterAsync(Character character)
    {
        await Init();
        if (character.Id != 0)
            return await Database.UpdateAsync(character);
        return await Database.InsertAsync(character);
    }

    public async Task<int> DeleteCharacterAsync(Character character)
    {
        await Init();
        return await Database.DeleteAsync(character);
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
