package WebGUI::i18n::English::Image;

our $I18N = {

	'image add/edit title' => {
		message => q|Image, Add/Edit|,
        	lastUpdated => 1106762707,
	},

	'image add/edit body' => {
                message => q|<P>Image Assets are used to store images that you want displayed on your site.</P>

<P>Since Images are a subset of File Assets, they have the properties that all Assets do as well
as File Assets.  Below are the properties that are specific to Image Assets:</P>

<P><b>Thumbnail size</b><br/>
A thumbnail of the Image will be created and available for use in
templates.  The longest side of the thumbnail will be set to this size
in pixels.  It defaults to the value from the sitewide setting.

<P><b>Parameters</b><br/>
This is a set of extra parameters to the &lt;IMG&gt; tag that is generated for
the image.  You can use this to set alignment or to set the text that is displayed
if the image cannot be displayed (such as to a text-only browser).

<P><b>Thumbnail</b><br/>
If an image is currently stored in the Asset,  then its thumbnail will be
shown here.
|,
		context => 'Describing image add/edit form specific fields',
		lastUpdated => 1106764520,
	},

	'thumbnail size' => {
		message => q|Thumbnail Size|,
		context => q|label for Image asset form|,
		lastUpdated => 1106609855
	},

	'parameters' => {
		message => q|Parameters|,
		context => q|label for Image asset form|,
		lastUpdated => 1106609855,
	},

	'thumbnail' => {
		message => q|Thumbnail|,
		context => q|label for Image asset form|,
		lastUpdated => 1106765841
	},

};

1;
