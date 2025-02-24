using SQLite;

using CharacterBook.Models;
using CharacterBook.Data;
using CharacterBook.Interfaces;

namespace CharacterBook.Services;

public class CharacterService : ICharacterService
{
    private readonly SQLiteAsyncConnection _connection;

    public CharacterService()
    {
        _connection = DatabaseConnectionClass.Connection;
    }

    public async Task InitializeDatabase()
    {
        await DatabaseConnectionClass.InitializeDatabase();
    }

    public async Task<CharacterModel> AddCharacter(CharacterModel character)
    {
        try
        {
            character.CreateDateTime = DateTime.UtcNow;
            var id = await _connection.InsertAsync(character);
            return await GetCharacter((int)id);
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при добавлении персонажа: {ex.Message}");
        }
    }

    public async Task UpdateCharacter(CharacterModel character)
    {
        try
        {
            await _connection.UpdateAsync(character);
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при обновлении персонажа: {ex.Message}");
        }
    }

    public async Task DeleteCharacter(int id)
    {
        try
        {
            var images = await GetCharacterImages(id);
            foreach (var image in images)
            {
                await _connection.DeleteAsync(image);
            }
            await _connection.DeleteAsync<CharacterModel>(id);
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при удалении персонажа: {ex.Message}");
        }
    }

    public async Task<CharacterModel> GetCharacter(int id)
    {
        try
        {
            return await _connection.GetAsync<CharacterModel>(id);
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при получении персонажа: {ex.Message}");
        }
    }

    public async Task<IEnumerable<CharacterModel>> GetAllCharacters()
    {
        try
        {
            return await _connection.Table<CharacterModel>()
                .OrderBy(c => c.Name)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при получении списка персонажей: {ex.Message}");
        }
    }

    public async Task<IEnumerable<CharacterModel>> GetFavoriteCharacters()
    {
        try
        {
            return await _connection.Table<CharacterModel>()
                .Where(c => c.isFavorite)
                .OrderBy(c => c.Name)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при получении избранных персонажей: {ex.Message}");
        }
    }

    public async Task<IEnumerable<CharacterImage>> GetCharacterImages(int characterId)
    {
        try
        {
            return await _connection.Table<CharacterImage>()
                .Where(i => i.CharacterId == characterId)
                .ToListAsync();
        }
        catch (Exception ex)
        {
            throw new Exception($"Ошибка при получении изображений персонажа: {ex.Message}");
        }
    }
}