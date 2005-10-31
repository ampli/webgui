package WebGUI::Help::Asset_Image;

our $HELP = {

        'image add/edit' => {
		title => 'image add/edit title',
		body => 'image add/edit body',
		fields => [
                        {
                                title => 'Thumbnail size',
                                description => 'Thumbnail size description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'Parameters',
                                description => 'Parameters description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'Thumbnail',
                                description => 'Thumbnail description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'image template title',
                                description => 'image template description',
                                namespace => 'Asset_Image',
                        },
		],
		related => [
			{
				tag => 'image template',
				namespace => 'Asset_Image',
			},
			{
				tag => 'image resize',
				namespace => 'Asset_Image',
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'file add/edit',
				namespace => 'Asset_File'
			},
		]
	},

        'image template' => {
		title => 'image template title',
		body => 'image template body',
		fields => [
		],
		related => [
			{
				tag => 'image add/edit',
				namespace => 'Asset_Image',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		]
	},

        'image resize' => {
		title => 'resize image title',
		body => 'resize image body',
		fields => [
                        {
                                title => 'image size',
                                description => 'image size description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'new width',
                                description => 'new width description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'new height',
                                description => 'new height description',
                                namespace => 'Asset_Image',
                        },
		],
		related => [
			{
				tag => 'image add/edit',
				namespace => 'Asset_Image',
			},
		]
	},

};

1;
