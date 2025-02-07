using CharacterBook.Models;
using CharacterBook.Data;

namespace CharacterBook.Views;

[QueryProperty(nameof(CharacterId), nameof(CharacterId))]
public partial class EditCharacterPage : ContentPage
{
	private bool hasPicture = false;
    private byte[] picture;
	public string CharacterId { set => Load(value); }
	public EditCharacterPage()
	{
		InitializeComponent();
		OnAppearing();
	}
	protected async override void OnAppearing()
	{
		BindingContext = new CharacterModel();
		//chooseFraction.ItemsSource = await DataAccess.FractionsData.GetFractionsAsync();
		//chooseFraction.ItemDisplayBinding = new Binding("FractionName");
		//chooseFraction.SelectedItem = await DataAccess.FractionsData.GetFractionsAsync();
	}
	private async void Load(string value)
	{
		try
		{
			var character = await CharactersItemDatabase.GetItemAsync(Convert.ToInt32(value));
			BindingContext = character;
			/*if (character.Image != null)
			{
				var convert = new ImageToByteServiceXamarin();
				CharacterPicture.Source = convert.ByteToImageXamarin(character.Image);
			}*/
		}
		catch { ShowErrorWindow(null); }
	}

	private async void SaveCharacter()
	{
		var character = (CharacterModel)BindingContext;
		character.CreateDateTime = DateTime.Now;
		//TagsService.SetTags(character.Tags);
		try
		{
			/*if (HasPicture)
			{
				character.Image = tmp;
			}
			if (fraction != null)
			{
				character.Fraction = fraction.Id;
				character.DisplayFraction = fraction.FractionName;
			}*/
			_ = await CharactersItemDatabase.SaveItemAsync(character);
			await DisplayAlert("Сохранено", "Персонаж успешно сохранён", "Отлично!");
		}
		catch { ShowErrorWindow(null); }
	}

	private async void DelCharacter()
	{
		var character = (CharacterModel)BindingContext;
		_ = await CharactersItemDatabase.DeleteItemAsync(character);
	}

	private async void WantSave()
	{
		var action = await DisplayAlert("Вы хотите выйти?", "Вы действительно хотите выйти?", "Да", "Вернутся");
		if (action) { SaveCharacter(); }
	}

	private void SaveBtnClicked(object sender, EventArgs e) => SaveCharacter();

	/*private async void ImageButton_Clicked(object sender, EventArgs e)
	{
		await DisplayAlert(Resource.SizeImage, Resource.SizeImageDescription, Resource.Okay);
		(sender as ImageButton).IsEnabled = false;

		Stream stream = await DependencyService.Get<IPhotoPickerService>().GetImageStreamAsync();
		if (stream != null)
		{
			CharacterPicture.Source = ImageSource.FromStream(() => stream);
			using (MemoryStream memoryStream = new MemoryStream())
			{
				stream.CopyTo(memoryStream);
				tmp = memoryStream.ToArray();
				memoryStream.Close();
			}
			stream.Close();
		}

		(sender as ImageButton).IsEnabled = true;
		HasPicture = true;
	}*/

	private async void DelBtnClicked(object sender, EventArgs e)
	{
		DelCharacter();
		await Shell.Current.GoToAsync("..");
	}

	/*private void chooseFraction_SelectedIndexChanged(object sender, EventArgs e)
	{
		fraction = (FractionModel)chooseFraction.SelectedItem;
	}*/

	private async void ShowErrorWindow(string errorText)
	{
		var action = await DisplayAlert("Ошибка", "К сожалению в приложении произошла ошибка!"
		 + "\nТип ошибки: " + errorText, "Написать на email", "Закрыть");
		if (action)
		{
			await Email.ComposeAsync("Произошла ошибка", errorText, "max.gog2005@outlook.com");
		}
	}

	/*private async void Share_Clicked(object sender, EventArgs e)
	{
		var action = await DisplayActionSheet(Resource.Share, Resource.Cancel, Resource.Okay, Resource.Export, Resource.CopyText);
		if (action == Resource.Export)
		{
			var character = (CharacterModel)BindingContext;
			try
			{
				DependencyService.Get<IFileService>().saveFileAsync(character.Name + ".txt", character.AllInfo);
				await DisplayAlert(Resource.CharacterSave, Resource.CharacterSaveDescription, Resource.Okay);
			}
			catch (Exception ex)
			{
				ShowErrorWindow(ex.Message);
			}
		}
		else if (action == Resource.CopyText)
		{
			var character = (CharacterModel)BindingContext;
			await Clipboard.SetTextAsync(character.AllInfo);
		}
	}*/

	protected override bool OnBackButtonPressed()
	{
		WantSave();
		base.OnBackButtonPressed();
		return false;
	}
}