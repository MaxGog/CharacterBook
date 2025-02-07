namespace CharacterBook.Views;

public partial class ListCharacterPage : ContentPage
{
	public ListCharacterPage()
	{
		InitializeComponent();
	}
	private async void AddBtnClicked(object sender, EventArgs e) => await Shell.Current.GoToAsync(nameof(EditCharacterPage));
}