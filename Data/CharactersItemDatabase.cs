using SQLite;

using CharacterBook.Models;
using CharacterBook.Constants;

namespace CharacterBook.Data;
public static class CharactersItemDatabase
{
    static SQLiteAsyncConnection Database;

    static async Task Init()
    {
        if (Database is not null)
            return;

        Database = new SQLiteAsyncConnection(DatabaseConstants.CharactersDatabaseFilename, DatabaseConstants.Flags);
        var result = await Database.CreateTableAsync<CharacterModel>();
    }

    public static async Task<List<CharacterModel>> GetItemsAsync()
    {
        await Init();
        return await Database.Table<CharacterModel>().ToListAsync();
    }

    /*public async Task<List<CharacterModel>> GetItemsNotDoneAsync()
    {
        await Init();
        return await Database.Table<CharacterModel>().Where(t => t.Done).ToListAsync();

        // SQL queries are also possible
        //return await Database.QueryAsync<TodoItem>("SELECT * FROM [TodoItem] WHERE [Done] = 0");
    }*/

    public static async Task<CharacterModel> GetItemAsync(int id)
    {
        await Init();
        return await Database.Table<CharacterModel>().Where(i => i.Id == id).FirstOrDefaultAsync();
    }

    public static async Task<int> SaveItemAsync(CharacterModel item)
    {
        await Init();
        if (item.Id != 0)
            return await Database.UpdateAsync(item);
        else
            return await Database.InsertAsync(item);
    }

    public static async Task<int> DeleteItemAsync(CharacterModel item)
    {
        await Init();
        return await Database.DeleteAsync(item);
    }
    
}
