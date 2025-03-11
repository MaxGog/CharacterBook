using SQLite;

namespace CharacterBook.Models;

public class Character
{
    [PrimaryKey]
    public string Id { get; set; }
    public string? Name { get; set; }
    public int Age { get; set; }
    public string? Gender { get; set; }
    public string? Species { get; set; }
    public string? Description { get; set; }
    public string? Biography { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsFavorite { get; set; }
    public byte[]? ImageData { get; set; }
    public DateTime ModifiedAt { get; set; }
    public string? Tags { get; set; }
}