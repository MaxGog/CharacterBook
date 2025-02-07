using SQLite;

namespace CharacterBook.Models;

[Table("Characters")]
public class CharacterModel
{
    [PrimaryKey, AutoIncrement, Column("_id")]
    public int Id { get; set; }

    public string Name { get; set; }
    public string Species { get; set; }
    public string Age { get; set; }
    public string Gender { get; set; }
    public string Description { get; set; }

    public byte[] MainPhoto { get; set; }
    public byte[] AppearancePhoto { get; set; }

    public DateTime CreateDateTime { get; set; }

    public bool Favorite { get; set; }

    //public string Tags { get; set; }
}