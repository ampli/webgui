package WebGUI;
our $VERSION = "4.2.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use Tie::CPHash;
use WebGUI::ErrorHandler;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub page {
	my ($debug, %contentHash, $w, $cmd, $pageEdit, $wobject, $wobjectOutput, $extra, $originalWobject, $proxyWobjectId,
		$sth, $httpHeader, $header, $footer, $content, $operationOutput, $adminBar, %hash);
	WebGUI::Session::open($_[0],$_[1]);
	if ($session{form}{debug}==1 && WebGUI::Privilege::isInGroup(3)) {
		$debug = '<table bgcolor="#ffffff" style="color: #000000; font-size: 10pt; font-family: helvetica;">';
		while (my ($section, $hash) = each %session) {
			while (my ($key, $value) = each %$hash) {
				if (ref $value eq 'ARRAY') {
					$value = '['.join(', ',@$value).']';
				} elsif (ref $value eq 'HASH') {
					$value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
				}
				$debug .= '<tr><td align="right"><b>'.$section.'.'.$key.':</b></td><td>'.$value.'</td>';
			}
			$debug .= '<tr height=10><td>&nbsp;</td><td>&nbsp</td></tr>';
		}
		$debug .='</table>';
	}
	if (exists $session{form}{op}) {
		$cmd = "WebGUI::Operation::www_".$session{form}{op};
		$operationOutput = eval($cmd);
		WebGUI::ErrorHandler::warn("Non-existent operation called: $session{form}{op}.") if($@);
	}
	if (exists $session{form}{func} && exists $session{form}{wid}) {
		if ($session{form}{wid} eq "new") {
			$wobject = {wobjectId=>"new",namespace=>$session{form}{namespace},pageId=>$session{page}{pageId}};
		} else {
			$wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobjectId=".$session{form}{wid});	
			if (${$wobject}{namespace} eq "") {
				WebGUI::ErrorHandler::warn("Wobject [$session{form}{wid}] appears to be missing or corrupt, but was requested "
					."by $session{user}{username} [$session{user}{userId}].");
				$wobject = ();
			} else {
				$extra = WebGUI::SQL->quickHashRef("select * from ${$wobject}{namespace} where wobjectId=${$wobject}{wobjectId}");
                        	tie %hash, 'Tie::CPHash';
                        	%hash = (%{$wobject},%{$extra});
                         	$wobject = \%hash;
			}
		}
		if ($wobject) {
                        if (${$wobject}{pageId} != $session{page}{pageId}) {
                                ($proxyWobjectId) = WebGUI::SQL->quickArray("select wobject.wobjectId from wobject,WobjectProxy 
                                        where wobject.wobjectId=WobjectProxy.wobjectId and wobject.pageId=".$session{page}{pageId}."
                                        and WobjectProxy.proxiedWobjectId=".${$wobject}{wobjectId});
                                ${$wobject}{_WobjectProxy} = $proxyWobjectId;
                        } 
			unless (${$wobject}{pageId} == $session{page}{pageId} || ${$wobject}{pageId} == 2 || ${$wobject}{_WobjectProxy} ne "") {
				$wobjectOutput .= WebGUI::International::get(417);
				WebGUI::ErrorHandler::warn($session{user}{username}." [".$session{user}{userId}."] attempted to access wobject ["
					.$session{form}{wid}."] on page '".$session{page}{title}."' [".$session{page}{pageId}."].");
			} else {
				$cmd = "WebGUI::Wobject::".${$wobject}{namespace};
				$w = eval{$cmd->new($wobject)};
				WebGUI::ErrorHandler::fatalError("Couldn't instanciate wojbect: ${$wobject}{namespace}.") if($@);
				$cmd = "www_".$session{form}{func};
				$wobjectOutput = eval{$w->$cmd};
				WebGUI::ErrorHandler::fatalError("Web method doesn't exist in wojbect: ${$wobject}{namespace} / $session{form}{func}.") if($@);
			}
		}
	}
	if ($operationOutput ne "") {
		$contentHash{0} = $operationOutput;
		$content = WebGUI::Template::generate(\%contentHash,1);
	} elsif ($wobjectOutput ne "") {
		$contentHash{0} = $wobjectOutput;
		$content = WebGUI::Template::generate(\%contentHash,1);
	} else {
		if (WebGUI::Privilege::canViewPage()) {
			if ($session{var}{adminOn}) {
				$pageEdit = "\n<br>"
					.pageIcon()
					.editIcon('op=editPage')
					.moveUpIcon('op=movePageUp')
					.moveDownIcon('op=movePageDown')
					.cutIcon('op=cutPage')
					.deleteIcon('op=deletePage')
					."\n";
			}	
			$sth = WebGUI::SQL->read("select * from wobject where pageId=$session{page}{pageId} order by sequenceNumber, wobjectId");
			while ($wobject = $sth->hashRef) {
				if ($session{var}{adminOn}) {
					$contentHash{${$wobject}{templatePosition}} .= "\n<hr>"
						.editIcon('func=edit&wid='.${$wobject}{wobjectId})
						.moveUpIcon('func=moveUp&wid='.${$wobject}{wobjectId})
						.moveDownIcon('func=moveDown&wid='.${$wobject}{wobjectId})
						.moveTopIcon('func=moveTop&wid='.${$wobject}{wobjectId})
						.moveBottomIcon('func=moveBottom&wid='.${$wobject}{wobjectId})
						.copyIcon('func=copy&wid='.${$wobject}{wobjectId})
						.cutIcon('func=cut&wid='.${$wobject}{wobjectId})
						.deleteIcon('func=delete&wid='.${$wobject}{wobjectId})
						.'<br>';
				}
                                if (${$wobject}{namespace} eq "WobjectProxy") {
					$originalWobject = $wobject;
                                        ($wobject) = WebGUI::SQL->quickArray("select proxiedWobjectId from WobjectProxy where wobjectId=".${$wobject}{wobjectId});
                                        $wobject = WebGUI::SQL->quickHashRef("select * from wobject where wobject.wobjectId=".$wobject);
					if (${$wobject}{namespace} eq "") {
						$wobject = $originalWobject;
					} else {
						${$wobject}{templatePosition} = ${$originalWobject}{templatePosition};
						${$wobject}{_WobjectProxy} = ${$originalWobject}{wobjectId};
					}
                                }
				$extra = WebGUI::SQL->quickHashRef("select * from ${$wobject}{namespace} where wobjectId=${$wobject}{wobjectId}");
				tie %hash, 'Tie::CPHash';
				%hash = (%{$wobject},%{$extra});
				$wobject = \%hash;
				$cmd = "WebGUI::Wobject::".${$wobject}{namespace};
				$w = eval{$cmd->new($wobject)};
				WebGUI::ErrorHandler::fatalError("Couldn't instanciate wojbect: ${$wobject}{namespace}.") if($@);
				if ($w->inDateRange) {
					$contentHash{${$wobject}{templatePosition}} .= '<div class="wobject'.${$wobject}{namespace}.'" id=wobjectId'.${$wobject}{wobjectId}.'>';
					$contentHash{${$wobject}{templatePosition}} .= '<a name="'.${$wobject}{wobjectId}.'"></a>';
					$contentHash{${$wobject}{templatePosition}} .= eval{$w->www_view};
					WebGUI::ErrorHandler::fatalError("No view method in wojbect: ${$wobject}{namespace}.") if($@);
					$contentHash{${$wobject}{templatePosition}} .= "</div>\n\n";
				}
			}
			$sth->finish;
			$content = WebGUI::Template::generate(\%contentHash,$session{page}{templateId});
		} else {
			$contentHash{0} = WebGUI::Privilege::noAccess();
			$content = WebGUI::Template::generate(\%contentHash,1);
		}
	}
	if ($session{header}{redirect} ne "") {
		return $session{header}{redirect};
	} else {
		$httpHeader = WebGUI::Session::httpHeader();
		($header, $footer) = WebGUI::Style::getStyle();
		WebGUI::Session::close();
		return $httpHeader.$adminBar.$header.$pageEdit.$content.$footer.$debug;
	}
}




1;


