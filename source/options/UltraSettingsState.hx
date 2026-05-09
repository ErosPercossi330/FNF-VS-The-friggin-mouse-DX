package options;

/**
 * Kategorize ayar menüsü örneği.
 * CategoryOptionsMenu'yu extend et, override create()'de
 * kategorilerini ekle, sonunda buildMenu() çağır.
 *
 * 2. Sistem (MainMenuState bağlantısı):
 *   Option'ların variable alanı doğrudan ClientPrefs.data'daki
 *   field adıyla eşleşir. Ayarı kaydetmek için ClientPrefs.saveSettings()
 *   yeterlidir — zaten BaseOptionsMenu/CategoryOptionsMenu kapatılırken
 *   OptionsState.closeSubState() içinde çağrılır.
 *
 *   MainMenuState içinde ise sadece şunu yap:
 *     if (ClientPrefs.data.mainMenuInfoBox) { ... infoBox kodları ... }
 */
class UltraSettingsState extends CategoryOptionsMenu
{
	override function create()
	{
		title    = 'Ultra Ayarlar';
		rpcTitle = 'Ultra Ayarlar Menüsü';

		// ══════════════════════════════════════════════════
		// KATEGORİ 1 — Ana Menü Ayarları
		// ══════════════════════════════════════════════════
		var catMainMenu = new OptionCategory(
			'Ana Menü Ayarları',
			'Ana menü görünümü ve davranışıyla ilgili ayarlar.'
		);

		// Bu option'ın variable adı ClientPrefs.data içindeki field ile EŞLEŞMELİ.
		// Örnek: ClientPrefs.data.mainMenuInfoBox = true/false
		var optInfoBox = new Option(
			'Bilgi Kutucuğu',
			'Ana menüde bilgi kutucuğunu gösterir.',
			'mainMenuInfoBox',   // ← ClientPrefs.data.mainMenuInfoBox
			BOOL
		);
		catMainMenu.addOption(optInfoBox);

		var optBgAnim = new Option(
			'Arka Plan Animasyonu',
			'Ana menü arka plan animasyonunu etkinleştirir.',
			'mainMenuBgAnim',
			BOOL
		);
		catMainMenu.addOption(optBgAnim);

		// Bu option yalnızca 'mainMenuBgAnim' true ise aktif olur
		var optBgSpeed = new Option(
			'Animasyon Hızı',
			'Arka plan animasyonunun hızını ayarlar.',
			'mainMenuBgSpeed',
			FLOAT
		);
		optBgSpeed.minValue    = 0.1;
		optBgSpeed.maxValue    = 5.0;
		optBgSpeed.changeValue = 0.1;
		optBgSpeed.decimals    = 1;
		optBgSpeed.displayFormat = '%v x';
		optBgSpeed.dependsOn   = 'mainMenuBgAnim'; // ← bağımlılık sistemi
		catMainMenu.addOption(optBgSpeed);

		addCategory(catMainMenu);

		// ══════════════════════════════════════════════════
		// KATEGORİ 2 — Mod Menüsü Ayarları
		// ══════════════════════════════════════════════════
		var catModMenu = new OptionCategory(
			'Mod Menüsü Ayarları',
			'Mod menüsü görünümü ve sıralama seçenekleri.'
		);

		var optModSort = new Option(
			'Sıralama',
			'Modların listelenme sırasını belirler.',
			'modMenuSort',
			STRING,
			['A-Z', 'Z-A', 'Son Eklenen']
		);
		catModMenu.addOption(optModSort);

		var optModIcons = new Option(
			'Mod İkonları',
			'Mod listesinde ikon gösterir.',
			'modMenuIcons',
			BOOL
		);
		catModMenu.addOption(optModIcons);

		addCategory(catModMenu);

		// ══════════════════════════════════════════════════
		// KATEGORİ 3 — Serbest Oyun Menüsü Ayarları
		// ══════════════════════════════════════════════════
		var catFreeplay = new OptionCategory(
			'Serbest Oyun Menüsü Ayarları',
			'Serbest oyun menüsüne ait görsel ve davranış ayarları.'
		);

		var optFreeplayPreview = new Option(
			'Şarkı Önizleme',
			'Serbest oyun menüsünde şarkı önizlemesini oynatır.',
			'freeplayPreview',
			BOOL
		);
		catFreeplay.addOption(optFreeplayPreview);

		var optFreeplayVolume = new Option(
			'Önizleme Sesi',
			'Önizleme sesinin seviyesi.',
			'freeplayPreviewVolume',
			PERCENT
		);
		optFreeplayVolume.dependsOn = 'freeplayPreview'; // önizleme kapalıysa gri
		catFreeplay.addOption(optFreeplayVolume);

		addCategory(catFreeplay);

		// ══════════════════════════════════════════════════
		// Menüyü inşa et — addCategory çağrılarından SONRA
		// ══════════════════════════════════════════════════
		buildMenu();

		super.create();
	}
}

// ══════════════════════════════════════════════════════════════
// MainMenuState İÇİNDE KULLANIM (sadece örnek, oraya kopyala)
// ══════════════════════════════════════════════════════════════
//
//   override function create()
//   {
//       super.create();
//
//       // Bilgi kutucuğu ayarı açıksa göster
//       if (ClientPrefs.data.mainMenuInfoBox)
//       {
//           var infoBox:FlxText = new FlxText(10, 10, 400, 'Hoş geldin!', 20);
//           add(infoBox);
//       }
//
//       // Arka plan animasyonu açıksa başlat
//       if (ClientPrefs.data.mainMenuBgAnim)
//       {
//           var speed:Float = ClientPrefs.data.mainMenuBgSpeed;
//           bgSprite.velocity.x = 50 * speed;
//       }
//   }
//
// ──────────────────────────────────────────────────────────────
// OptionsState'e eklemek için openSelectedSubstate() içine:
//
//   case 'Ultra Ayarlar':
//       openSubState(new options.UltraSettingsState());
//
// options dizisine de ekle:
//   'Ultra Ayarlar'
// ══════════════════════════════════════════════════════════════
