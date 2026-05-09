package options;

/**
 * Bir kategori başlığı ve altındaki option'ları tutar.
 * CategoryOptionsMenu içinde accordion sistemi için kullanılır.
 *
 * Kullanım:
 *   var cat = new OptionCategory('Ana Menü Ayarları', 'Ana menüyle ilgili ayarlar.');
 *   cat.addOption(new Option(...));
 *   cat.addOption(new Option(...));
 *   menu.addCategory(cat);
 */
class OptionCategory
{
	/** Başlıkta gösterilecek isim. */
	public var name:String;

	/** Başlık seçildiğinde altta gösterilecek açıklama. */
	public var description:String;

	/** Bu kategoriye ait option listesi. */
	public var options:Array<Option> = [];

	/** Accordion açık mı? */
	public var isOpen:Bool = false;

	public function new(name:String, description:String = '')
	{
		this.name        = name;
		this.description = description;
	}

	public function addOption(option:Option):Option
	{
		options.push(option);
		return option;
	}
}
