package WebGUI::Session;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI;
use Data::Config;
use DBI;
use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(%session);
our %session = ();
tie %session, 'Tie::CPHash';

#-------------------------------------------------------------------
sub _generateSessionId {
	my ($sessionId);
	$sessionId = crypt(time(),rand(99));
	return $sessionId;
}

#-------------------------------------------------------------------
sub _getPageInfo {
        my (%page, $pageId, $pageName);
	tie %page, 'Tie::CPHash';
	($pageId) = $_[0];
	if ($pageId eq "") {
        	$pageName = lc($ENV{PATH_INFO});
        	$pageName =~ s/\///;
		$pageName =~ s/\'//;
		$pageName =~ s/\"//;
        	if ($pageName ne "") {
                	($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='".$pageName."'",$_[1]);
                	if ($pageId eq "") {
                        	$pageId = $_[2];
				$session{header}{status} = '404';
                	}
        	} else {
                	$pageId = 1;
        	}
	}
	%page = WebGUI::SQL->quickHash("select * from page where pageId='".$pageId."'",$_[1]);
	$page{url} = $_[3]."/".$page{urlizedTitle};
        return %page;
}

#-------------------------------------------------------------------
sub _getSessionVars {
        my (%vars, $uid, $encryptedPassword);
	tie %vars, 'Tie::CPHash';
        if ($_[0] ne "") {
        	%vars = WebGUI::SQL->quickHash("select * from userSession where sessionId='$_[0]'", $_[1]);
		if ($vars{sessionId} ne "") {
			WebGUI::SQL->write("update userSession set lastPageView=".time().", lastIP='$ENV{REMOTE_ADDR}', expires=".(time()+$_[2])." where sessionId='$_[0]'",$_[1]);
		}
	}
        return %vars;
}

#-------------------------------------------------------------------
sub _getUserInfo {
	my (%user, $uid, %profile);
	tie %user, 'Tie::CPHash';
	$uid = $_[0] || 1;
	%user = WebGUI::SQL->quickHash("select * from users where userId='$uid'", $_[1]);
	if ($user{userId} eq "") {
		%user = _getUserInfo("1",$_[1]);
	}
	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData from userProfileData, userProfileField where userProfileData.fieldName=userProfileField.fieldName and userProfileData.userId=$user{userId}", $_[1]);
	%user = (%user, %profile);
	return %user;
}

#-------------------------------------------------------------------
sub close {
        $session{'dbh'}->disconnect();
	undef %session;
}

#-------------------------------------------------------------------
sub end {
	WebGUI::SQL->write("delete from userSession where sessionId='$_[0]'",$session{dbh});
	if ($_[0] eq $session{var}{sessionId}) {
		refreshSessionVars();
	}
}

#-------------------------------------------------------------------
sub httpHeader {
        return $session{cgi}->header( 
		-cookie => $session{header}{cookie}, 
		-status => $session{header}{status} 
		);
}

#-------------------------------------------------------------------
sub httpRedirect {
        return $session{cgi}->redirect($_[0]);
}

#-------------------------------------------------------------------
sub open {
        my ($key, %CONFIG, %VARS, %PAGE, %FORM, $query, %COOKIES, $config, %USER, %SETTINGS, $dbh);
	tie %USER, 'Tie::CPHash';
	tie %VARS, 'Tie::CPHash';
	tie %PAGE, 'Tie::CPHash';
	$CONFIG{webguiRoot} = $_[0];
	$CONFIG{configFile} = $_[1] || "WebGUI.conf";
        $config = new Data::Config $CONFIG{webguiRoot}.'/etc/'.$CONFIG{configFile};
        foreach ($config->param) {
                $CONFIG{$_} = $config->param($_);
        }
        if( defined( $CONFIG{scripturl} ) ) {
                # get rid of leading "/" if present.
                $CONFIG{scripturl} =~ s/^\///;
        } else {
                # default to the "real" path to script.
                $CONFIG{scripturl} = $ENV{SCRIPT_NAME};
        }
        $dbh = DBI->connect($CONFIG{dsn}, $CONFIG{dbuser}, $CONFIG{dbpass}, { RaiseError => 0, AutoCommit => 1 });
	if ( $CONFIG{dsn} =~ /Oracle/ ) { # Set Oracle specific attributes
		$dbh->{LongReadLen} = 512 * 1024;
 		$dbh->{LongTruncOk} = 1;
 	} 
        $query = CGI->new();
        foreach ($query->param) {
                $FORM{$_} = $query->param($_);
        }
        foreach ($query->cookie) {
                $COOKIES{$_} = $query->cookie($_);
        }
        %SETTINGS = WebGUI::SQL->buildHash("select name,value from settings",$dbh);
	%VARS = _getSessionVars($COOKIES{wgSession},$dbh,$SETTINGS{sessionTimeout});
        %USER = _getUserInfo($VARS{userId},$dbh);
	$CGI::POST_MAX=1024 * $SETTINGS{maxAttachmentSize};
	%PAGE = _getPageInfo("",$dbh,$SETTINGS{notFoundPage},$CONFIG{scripturl});
        %session = (
                env => \%ENV,					# environment variables from the web server
                config=> \%CONFIG,				# variables loaded from the config file
                user => \%USER,					# the user's account information
		var => \%VARS,					# session specific variables
                form => \%FORM,					# variables passed in from a form
                cookie => \%COOKIES,				# variables passed in via cookie
                setting => \%SETTINGS,				# variables set by the administrator
                cgi => $query,					# interface to the CGI environment
                page => \%PAGE,					# variables related to the current page 
                dbh => $dbh,					# interface to the default WebGUI database
		header => $session{header}			# HTTP header modifiers
        );
}

#-------------------------------------------------------------------
sub refreshPageInfo {
        my (%PAGE, $pageId);
	tie %PAGE, 'Tie::CPHash';
	if ($_[0] == 0) {
		$pageId = 1;
	} else {
		$pageId = $_[0];
	}
        %PAGE = _getPageInfo($pageId,$session{dbh},$session{setting}{notFoundPage},$session{config}{scripturl});
        $session{page} = \%PAGE;
}

#-------------------------------------------------------------------
sub refreshSessionVars {
        my (%VARS);
	tie %VARS, 'Tie::CPHash';
        %VARS = _getSessionVars($_[0],$session{dbh},$session{setting}{sessionTimeout});
        $session{var} = \%VARS;
	refreshUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------
sub refreshUserInfo {
	my (%USER);
	tie %USER, 'Tie::CPHash';
	%USER = _getUserInfo($_[0],$session{dbh});
	$session{user} = \%USER;
}

#-------------------------------------------------------------------
sub setCookie {
	$session{header}{cookie} = $session{cgi}->cookie(-name=>$_[0], -value=>$_[1], -expires=>'+10y', -path=>'/');	
}

#-------------------------------------------------------------------
sub start {
	my ($sessionId);
	$sessionId = _generateSessionId();
	WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
		(time()+$session{setting}{sessionTimeout}).", ".
		time().", 0, '$ENV{REMOTE_ADDR}', $_[0])",$session{dbh});
	setCookie("wgSession",$sessionId);
	refreshSessionVars($sessionId);
}

1;
