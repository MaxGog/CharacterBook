using System.Collections.ObjectModel;

using SQLite;

using CharacterBook.Models;

namespace CharacterBook.Services;

public class NoteStorageService : IAsyncDisposable
{
    private readonly string databasePath;
    private SQLiteAsyncConnection connection;

    public NoteStorageService()
    {
        databasePath = Path.Combine(FileSystem.AppDataDirectory, "notes.db");
        InitializeDatabase();
    }

    private void InitializeDatabase()
    {
        connection = new SQLiteAsyncConnection(databasePath);
        connection.CreateTableAsync<Note>().Wait();
    }

    public async Task<ObservableCollection<Note>> GetAllNotesAsync()
    {
        try
        {
            InitializeConnection();
            var notes = await connection.Table<Note>()
                .OrderBy(n => n.CreatedAt)
                .ToListAsync();
            return new ObservableCollection<Note>(notes);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметок: {ex.Message}");
        }
    }

    public async Task<Note> GetNoteAsync(string id)
    {
        try
        {
            InitializeConnection();
            return await connection.Table<Note>()
                .Where(n => n.Id == id)
                .FirstOrDefaultAsync();
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при получении заметки: {ex.Message}");
        }
    }

    public async Task SaveNoteAsync(Note note)
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

    public async Task DeleteNoteAsync(string id)
    {
        try
        {
            InitializeConnection();
            await connection.DeleteAsync<Note>(id);
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при удалении заметки: {ex.Message}");
        }
    }

    public async Task UpdateNoteAsync(Note note)
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