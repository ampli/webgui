package WebGUI::i18n::English::Macro_Page;

our $I18N = {

	'macroName' => {
		message => q|Page|,
		lastUpdated => 1128839316,
	},

	'page title' => {
		message => q|Page Macro|,
		lastUpdated => 1112466408,
	},

	'page body' => {
		message => q|

<p><b>&#94;Page();</b><br />
This can be used to retrieve information about the current asset. For instance it could be used to get the page URL like this &#94;Page("urlizedTitle"); or to get the menu title like this &#94;Page("menuTitle");.  If the macro is called outside the context of
an asset, or if the property doesn't exist, then it returns nothing.
</p>
<p>Properties available for retrieval depend on the type of asset that is being queried.</p>
<p>This Macro may be nested inside other Macros if the property returned does not contain commas or quotes.</p>
|,
		lastUpdated => 1168622743,
	},
};

1;
