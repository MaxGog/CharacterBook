using SQLite;

namespace CharacterBook.Models;

public class CharacterModel
{
    [PrimaryKey, AutoIncrement, Column("_id")]
    public int Id { get; set; }
    public string Name { get; set; }
    public string Gender { get; set; }
    public string Age { get; set; }
    public string Description { get; set; }
    public string Race { get; set; }
    public DateTime CreateDateTime { get; set; }
    public bool isFavorite { get; set; }
}

public class CharacterImage
{
    [PrimaryKey]
    public int Id { get; set; }
    public int CharacterId { get; set; }
    public byte[] Data { get; set; }
    public string ContentType { get; set; }
}