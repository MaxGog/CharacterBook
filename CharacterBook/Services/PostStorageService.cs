using System.Collections.ObjectModel;

using SQLite;

using CharacterBook.Models;

namespace CharacterBook.Services;

public class PostStorageService : IAsyncDisposable
{
    private readonly string databasePath;
    private SQLiteAsyncConnection connection;

    public PostStorageService()
    {
        databasePath = Path.Combine(FileSystem.AppDataDirectory, "notes.db");
        InitializeDatabase();
    }

    private void InitializeDatabase()
    {
        connection = new SQLiteAsyncConnection(databasePath);
        connection.CreateTableAsync<Post>().Wait();
    }

    public async Task<ObservableCollection<Post>> GetAllPostsAsync()
    {
        try
        {
            InitializeConnection();
            var notes = await connection.Table<Post>()
                .OrderBy(n => n.CreatedAt)
                .ToListAsync();
            return new ObservableCollection<Post>(notes);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметок: {ex.Message}");
        }
    }

    public async Task<Post> GetPostAsync(string id)
    {
        try
        {
            InitializeConnection();
            return await connection.Table<Post>()
                .Where(n => n.Id == id)
                .FirstOrDefaultAsync();
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметки: {ex.Message}");
        }
    }

    public async Task SavePostAsync(Post note)
    {
        try
        {
            InitializeConnection();
            if (string.IsNullOrEmpty(note.Id))
            {
                note.Id = Guid.NewGuid().ToString();
                await connection.InsertAsync(note);
            }
            else
            {
                await connection.UpdateAsync(note);
            }
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при сохранении заметки: {ex.Message}");
        }
    }

    public async Task DeletePostAsync(string id)
    {
        try
        {
            InitializeConnection();
            await connection.DeleteAsync<Post>(id);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при удалении заметки: {ex.Message}");
        }
    }

    public async Task UpdateNoteAsync(Post note)
    {
        try
        {
            InitializeConnection();
            await connection.UpdateAsync(note);
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

    public async ValueTask DisposeAsync()
    {
        if (connection != null)
        {
            await connection.CloseAsync();
            //connection.Dispose();
            connection = null;
        }
    }
}