#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::HTML;
use WebGUI::Session;
use HTML::TokeParser;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my @filterSets = (
	{
		inputText => q!<p>Paragraph</p>^H();,^SQL("select * from users","^0;,^1;")!,
		output => q!<p>Paragraph</p>&#94;H();,&#94;SQL("select * from users","&#94;0;,&#94;1;")!,
		type => 'macros',
		comment => 'filter macros, valid or not',
	},
	{
		inputText => q!<p>Paragraph</p>^H();!,
		output => q!<p>Paragraph</p>&#94;H();!,
		type => 'macros',
		comment => 'filter macros leaves HTML alone',
	},
	{
		inputText => q!<p>Paragraph</p>!,
		output => q!Paragraph!,
		type => 'all',
		comment => 'all filter HTML',
	},
	{
		inputText => q!<div class="something"><div style="float: left;">This <span>is some</span> <i>text</i> here. Let's&nbsp;see what we get when we add a table.<table><tr><td>a</td><td>b</td></tr><tr><td>c</td><td>d</td></tr></table></div><div>Here's a little more text with <b>bold</b>, <strong>strong</strong>, and <strong><b>bold strong</b></strong>.</div>!,
		output => q!This is some text here. Let&#39;s&nbsp;see what we get when we add a table.abcdHere&#39;s a little more text with bold, strong, and bold strong.!,
		type => 'all',
		comment => 'all filter complex HTML',
	},
	{
		inputText => q!<p>Paragraph</p>^H();!,
		output => q!Paragraph&#94;H();!,
		type => 'all',
		comment => 'all filters macros and HTML',
	},
	{
		inputText => q!<iframe>!,
		output => q!!,
		type => 'all',
		comment => 'all with bare iframe',
	},
	{
		inputText => q!<iframe> height attribute!,
		output => q! height attribute!,
		type => 'all',
		comment => 'all, specific iframe test case',
	},
);

my $numTests = scalar @filterSets;

plan tests => $numTests;

foreach my $testSet (@filterSets) {
	my $output = WebGUI::HTML::filter($testSet->{inputText}, $testSet->{type});
	is($output, $testSet->{output}, $testSet->{comment});
}
