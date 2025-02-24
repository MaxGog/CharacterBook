using CharacterBook.Models;

namespace CharacterBook.Interfaces;

public interface ICharacterService
{
    Task InitializeDatabase();
    Task<CharacterModel> AddCharacter(CharacterModel character);
    Task UpdateCharacter(CharacterModel character);
    Task DeleteCharacter(int id);
    Task<CharacterModel> GetCharacter(int id);
    Task<IEnumerable<CharacterModel>> GetAllCharacters();
    Task<IEnumerable<CharacterModel>> GetFavoriteCharacters();
    Task<IEnumerable<CharacterImage>> GetCharacterImages(int characterId);
}