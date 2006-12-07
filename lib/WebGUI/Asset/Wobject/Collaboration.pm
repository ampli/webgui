package WebGUI::Asset::Wobject::Collaboration;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Group;
use WebGUI::Cache;
use WebGUI::HTML;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Workflow::Cron;
use WebGUI::Asset::RSSCapable;
use base 'WebGUI::Asset::RSSCapable';
use base 'WebGUI::Asset::Wobject';

#-------------------------------------------------------------------
sub addChild {
	my $self = shift;
	my $properties = shift;
	my @other = @_;
	if ($properties->{className} ne "WebGUI::Asset::Post::Thread"
	    and $properties->{className} ne 'WebGUI::Asset::RSSFromParent') {
		$self->session->errorHandler->security("add a ".$properties->{className}." to a ".$self->get("className"));
		return undef;
	}
	return $self->SUPER::addChild($properties, @other);
}


#-------------------------------------------------------------------
sub appendPostListTemplateVars {
	my $self = shift;
	my $var = shift;
	my $p = shift;
	my $page = $p->getPageData;
	my $i = 0;
	foreach my $row (@$page) {
		my $post = WebGUI::Asset->new($self->session,$row->{assetId}, $row->{className}, $row->{revisionDate});
		$post->{_parent} = $self; # caching parent for efficiency 
		my $controls = $self->session->icon->delete('func=delete',$post->get("url"),"Delete").$self->session->icon->edit('func=edit',$post->get("url"));
		if ($self->get("sortBy") eq "lineage") {
			if ($self->get("sortOrder") eq "desc") {
				$controls .= $self->session->icon->moveUp('func=demote',$post->get("url")).$self->session->icon->moveDown('func=promote',$post->get("url"));
			} else {
				$controls .= $self->session->icon->moveUp('func=promote',$post->get("url")).$self->session->icon->moveDown('func=demote',$post->get("url"));
			}
		}
		my @rating_loop;
		for (my $i=0;$i<=$post->get("rating");$i++) {
			push(@rating_loop,{'rating_loop.count'=>$i});
		}
		my %lastReply;
		my $hasRead = 0;
		if ($post->get("className") =~ /Thread/) {
			if ($self->get("displayLastReply")) {
				my $lastPost = $post->getLastPost();
				%lastReply = (
					"lastReply.url"=>$lastPost->getUrl.'#'.$lastPost->getId,
                        		"lastReply.title"=>$lastPost->get("title"),
                        		"lastReply.user.isVisitor"=>$lastPost->get("ownerUserId") eq "1",
                        		"lastReply.username"=>$lastPost->get("username"),
                       	 		"lastReply.userProfile.url"=>$lastPost->WebGUI::Asset::Post::getPosterProfileUrl(),
                        		"lastReply.dateSubmitted.human"=>$self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%z"),
                        		"lastReply.timeSubmitted.human"=>$self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%Z")
					);
			}
			$hasRead = $post->isMarkedRead;
		}
		my $url;
		if ($post->get("status") eq "pending") {
			$url = $post->getUrl("revision=".$post->get("revisionDate"))."#".$post->getId;
		} else {
			$url = $post->getUrl."#".$post->getId;
		}
                push(@{$var->{post_loop}}, {
			%{$post->get},
                        "id"=>$post->getId,
                        "url"=>$url,
			rating_loop=>\@rating_loop,
			"content"=>$post->formatContent,
                        "status"=>$post->getStatus,
                        "thumbnail"=>$post->getThumbnailUrl,
                        "image.url"=>$post->getImageUrl,
                        "dateSubmitted.human"=>$self->session->datetime->epochToHuman($post->get("dateSubmitted"),"%z"),
                        "dateUpdated.human"=>$self->session->datetime->epochToHuman($post->get("dateUpdated"),"%z"),
                        "timeSubmitted.human"=>$self->session->datetime->epochToHuman($post->get("dateSubmitted"),"%Z"),
                        "timeUpdated.human"=>$self->session->datetime->epochToHuman($post->get("dateUpdated"),"%Z"),
                        "userProfile.url"=>$post->getPosterProfileUrl,
                        "user.isVisitor"=>$post->get("ownerUserId") eq "1",
        		"edit.url"=>$post->getEditUrl,
			'controls'=>$controls,
                        "isSecond"=>(($i+1)%2==0),
                        "isThird"=>(($i+1)%3==0),
                        "isFourth"=>(($i+1)%4==0),
                        "isFifth"=>(($i+1)%5==0),
			"user.hasRead" => $hasRead,
                	"user.isPoster"=>$post->isPoster,
                	"avatar.url"=>$post->getAvatarUrl,
			%lastReply
                        });
		$i++;
	}
	$p->appendTemplateVars($var);
}

#-------------------------------------------------------------------
sub appendTemplateLabels {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	$var->{"transferkarma.label"} = $i18n->get("transfer karma");
	$var->{"karmaScale.label"} = $i18n->get("karma scale");
	$var->{"close.label"} = $i18n->get("close");
	$var->{"closed.label"} = $i18n->get("closed");
	$var->{"open.label"} = $i18n->get("open");
	$var->{"critical.label"} = $i18n->get("critical");
	$var->{"cosmetic.label"} = $i18n->get("cosmetic");
	$var->{"minor.label"} = $i18n->get("minor");
	$var->{"fatal.label"} = $i18n->get("fatal");
	$var->{"severity.label"} = $i18n->get("severity");
	$var->{"add.label"} = $i18n->get("add");
	$var->{"addlink.label"} = $i18n->get("addlink");
	$var->{"addquestion.label"} = $i18n->get("addquestion");
	$var->{'answer.label'} = $i18n->get("answer");
	$var->{'attachment.label'} = $i18n->get("attachment");
	$var->{'archive.label'} = $i18n->get("archive");
	$var->{'unarchive.label'} = $i18n->get("unarchive");
	$var->{"by.label"} = $i18n->get("by");
        $var->{'body.label'} = $i18n->get("body");
	$var->{"back.label"} = $i18n->get("back");
	$var->{'compensation.label'} = $i18n->get("compensation");
	$var->{'contentType.label'} = $i18n->get("contentType");
	$var->{"date.label"} = $i18n->get("date");
	$var->{"delete.label"} = $i18n->get("delete");
        $var->{'description.label'} = $i18n->get("description");
	$var->{"edit.label"} = $i18n->get("edit");
	$var->{'image.label'} = $i18n->get("image");
	$var->{"job.header.label"} = $i18n->get("edit job");
	$var->{"job.title.label"} = $i18n->get("job title");
	$var->{"job.description.label"} = $i18n->get("job description");
	$var->{"job.requirements.label"} = $i18n->get("job requirements");
	$var->{"karmaRank.label"} = $i18n->get("karma rank");
	$var->{"location.label"} = $i18n->get("location");
	$var->{"layout.flat.label"} = $i18n->get("flatLayout");
	$var->{'link.header.label'} = $i18n->get("edit link");
	$var->{"lastReply.label"} = $i18n->get("lastReply");
	$var->{"lock.label"} = $i18n->get("lock");
	$var->{"layout.label"} = $i18n->get("layout");
        $var->{'message.header.label'} = $i18n->get("edit message");
        $var->{'message.label'} = $i18n->get("message");
	$var->{"next.label"} = $i18n->get("next");
        $var->{'newWindow.label'} = $i18n->get("new window");
	$var->{"layout.nested.label"} = $i18n->get("nested");
	$var->{"previous.label"} = $i18n->get("previous");
	$var->{"post.label"} = $i18n->get("post");
	$var->{'question.label'} = $i18n->get("question");
	$var->{'question.header.label'} = $i18n->get("edit question");
	$var->{"rating.label"} = $i18n->get("rating");
	$var->{"rate.label"} = $i18n->get("rate");
	$var->{"reply.label"} = $i18n->get("reply");
	$var->{"replies.label"} = $i18n->get("replies");
	$var->{"readmore.label"} = $i18n->get("read more");
	$var->{"responses.label"} = $i18n->get("responses");
        $var->{"search.label"} = $i18n->get("search");
        $var->{'subject.label'} = $i18n->get("subject");
	$var->{"subscribe.label"} = $i18n->get("subscribe");
        $var->{'submission.header.label'} = $i18n->get("edit submission");
	$var->{"stick.label"} = $i18n->get("sticky");
	$var->{"status.label"} = $i18n->get("status");
	$var->{"synopsis.label"} = $i18n->get("synopsis");
	$var->{"thumbnail.label"} = $i18n->get("thumbnail");
	$var->{"title.label"} = $i18n->get("title");
	$var->{"unlock.label"} = $i18n->get("unlock");
	$var->{"unstick.label"} = $i18n->get("unstick");
	$var->{"unsubscribe.label"} = $i18n->get("unsubscribe");
        $var->{'url.label'} = $i18n->get("url");
        $var->{"user.label"} = $i18n->get("user");
	$var->{"views.label"} = $i18n->get("views");
        $var->{'visitorName.label'} = $i18n->get("visitor");
}

#-------------------------------------------------------------------
sub canEdit {
        my $self = shift;
        return (
		(
			(
				$self->session->form->process("func") eq "add" || 
				(
					$self->session->form->process("assetId") eq "new" && 
					$self->session->form->process("func") eq "editSave" && 
					$self->session->form->process("class") eq "WebGUI::Asset::Post::Thread"
				)
			) && 
			$self->canPost
		) || # account for new posts
		$self->SUPER::canEdit()
	);
}

#-------------------------------------------------------------------
sub canModerate {
	my $self = shift;
	return $self->SUPER::canEdit;
}

#-------------------------------------------------------------------
sub canPost {
	my $self = shift;
	return (
		(
			$self->get("status") eq "approved" || 
			$self->getTagCount > 1 # checks to make sure that the cs has been committed at least once
		) && (
			$self->session->user->isInGroup($self->get("postGroupId")) 
			|| $self->SUPER::canEdit
		)
	);
}


#-------------------------------------------------------------------
sub canSubscribe {
        my $self = shift;
        return ($self->session->user->userId ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub canView {
	my $self = shift;
	return $self->SUPER::canView || $self->canPost;
}

#-------------------------------------------------------------------
sub commit {
	my $self = shift;
	$self->SUPER::commit;
	my $cron = undef;
	if ($self->get("getMailCronId")) {
		$cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
	}
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	unless (defined $cron) {
		$cron = WebGUI::Workflow::Cron->create($self->session, {
			title=>$self->getTitle." ".$i18n->get("mail"),
			minuteOfHour=>"*/".($self->get("getMailInterval")/60),
			className=>"WebGUI::Asset::Wobject::Collaboration",
			methodName=>"new",
			parameters=>$self->getId,
			workflowId=>"csworkflow000000000001"
			});
		$self->update({getMailCronId=>$cron->getId});
	}
	if ($self->get("getMail")) {
		$cron->set({enabled=>1,title=>$self->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($self->get("getMailInterval")/60)});
	} else {
		$cron->set({enabled=>0,title=>$self->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($self->get("getMailInterval")/60)});
	}
}

#-------------------------------------------------------------------
sub createSubscriptionGroup {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session, "new");
	$group->name($self->getId);
	$group->description("The group to store subscriptions for the collaboration system ".$self->getId);
	$group->isEditable(0);
	$group->showInForms(0);
	$group->deleteGroups([3]); # admins don't want to be auto subscribed to this thing
	$self->update({
		subscriptionGroupId=>$group->getId
		});
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Collaboration");
	my $useKarma = $session->setting->get('useKarma');

	my %sortByOptions;
	tie %sortByOptions, 'Tie::IxHash';
	%sortByOptions = (lineage=>$i18n->get('sequence'),
			  dateUpdated=>$i18n->get('date updated'),
			  dateSubmitted=>$i18n->get('date submitted'),
			  title=>$i18n->get('title'),
			  userDefined1=>$i18n->get('user defined 1'),
			  userDefined2=>$i18n->get('user defined 2'),
			  userDefined3=>$i18n->get('user defined 3'),
			  userDefined4=>$i18n->get('user defined 4'),
			  userDefined5=>$i18n->get('user defined 5'),
			  ($useKarma? (karmaRank=>$i18n->get('karma rank')) : ()),
			 );

	my $richEditorOptions = $session->db->buildHashRef("select distinct(assetData.assetId), assetData.title from asset, assetData where asset.className='WebGUI::Asset::RichEdit' and asset.assetId=assetData.assetId order by assetData.title");

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		visitorCacheTimeout => {
			tab => "display",
			fieldType => "interval",
			defaultValue => 3600,
			uiLevel => 8,
			label => $i18n->get("visitor cache timeout"),
			hoverHelp => $i18n->get("visitor cache timeout help")
			},
		autoSubscribeToThread => {
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'mail',
			label=>$i18n->get("auto subscribe to thread"),
			hoverHelp=>$i18n->get("auto subscribe to thread help"),
			},
		requireSubscriptionForEmailPosting => {
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'mail',
			label=>$i18n->get("require subscription for email posting"),
			hoverHelp=>$i18n->get("require subscription for email posting help"),
			},
		approvalWorkflow =>{
			fieldType=>"workflow",
			defaultValue=>"pbworkflow000000000003",
			type=>'WebGUI::VersionTag',
			tab=>'security',
			label=>$i18n->get('approval workflow'),
			hoverHelp=>$i18n->get('approval workflow description'),
			},
		thumbnailSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("thumbnail size"),
			hoverHelp => $i18n->get("thumbnail size help")
			},
		maxImageSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("max image size"),
			hoverHelp => $i18n->get("max image size help")
			},
		mailServer=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail server"),
			hoverHelp=>$i18n->get("mail server help"),
			},
		mailAccount=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail account"),
			hoverHelp=>$i18n->get("mail account help"),
			},
		mailPassword=>{
			fieldType=>"password",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail password"),
			hoverHelp=>$i18n->get("mail password help"),
			},
		mailAddress=>{
			fieldType=>"email",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail address"),
			hoverHelp=>$i18n->get("mail address help"),
			},
		mailPrefix=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail prefix"),
			hoverHelp=>$i18n->get("mail prefix help"),
			},
		getMailCronId=>{
			fieldType=>"hidden",
			defaultValue=>undef,
			noFormPost=>1
			},
		getMail=>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'mail',
			label=>$i18n->get("get mail"),
			hoverHelp=>$i18n->get("get mail help"),
			},
		getMailInterval=>{
			fieldType=>"interval",
			defaultValue=>300,
			tab=>'mail',
			label=>$i18n->get("get mail interval"),
			hoverHelp=>$i18n->get("get mail interval help"),
			},
		displayLastReply =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'display',
			label=>$i18n->get('display last reply'),
			hoverHelp=>$i18n->get('display last reply description'),
			},
		allowReplies =>{
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'security',
			label=>$i18n->get('allow replies'),
			hoverHelp=>$i18n->get('allow replies description'),
			},
		threadsPerPage =>{
			fieldType=>"integer",
			defaultValue=>30,
			tab=>'display',
			label=>$i18n->get('threads/page'),
			hoverHelp=>$i18n->get('threads/page description'),
			},
		postsPerPage =>{
			fieldType=>"integer",
			defaultValue=>10,
			tab=>'display',
			label=>$i18n->get('posts/page'),
			hoverHelp=>$i18n->get('posts/page description'),
			},
		archiveAfter =>{
			fieldType=>"interval",
			defaultValue=>31536000,
			tab=>'properties',
			label=>$i18n->get('archive after'),
			hoverHelp=>$i18n->get('archive after description'),
			},
		subscriptionGroupId =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		lastPostDate =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		lastPostId =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		rating =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		replies =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		views =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		threads =>{
			noFormPost=>1,
			fieldType=>"hidden",
			defaultValue=>undef
			},
		useContentFilter =>{
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'display',
			label=>$i18n->get('content filter'),
			hoverHelp=>$i18n->get('content filter description'),
			},
		filterCode =>{
			fieldType=>"filterContent",
			defaultValue=>'javascript',
			tab=>'security',
			label=>$i18n->get('filter code'),
			hoverHelp=>$i18n->get('filter code description'),
			},
		richEditor =>{
			fieldType=>"selectBox",
			defaultValue=>"PBrichedit000000000002",
			tab=>'display',
			label=>$i18n->get('rich editor'),
			hoverHelp=>$i18n->get('rich editor description'),
			options=>$richEditorOptions,
			},
		attachmentsPerPost =>{
			fieldType=>"integer",
			defaultValue=>0,
			tab=>'properties',
			label=>$i18n->get('attachments/post'),
			hoverHelp=>$i18n->get('attachments/post description'),
			},
		editTimeout =>{
			fieldType=>"interval",
			defaultValue=>3600,
			tab=>'security',
			label=>$i18n->get('edit timeout'),
			hoverHelp=>$i18n->get('edit timeout description'),
			},
		addEditStampToPosts =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'security',
			label=>$i18n->get('edit stamp'),
			hoverHelp=>$i18n->get('edit stamp description'),
			},
		usePreview =>{
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'properties',
			label=>$i18n->get('use preview'),
			hoverHelp=>$i18n->get('use preview description'),
			},
		sortOrder =>{
			fieldType=>"selectBox",
			defaultValue=>'desc',
			tab=>'display',
			options=>{ asc => $i18n->get('ascending'),
				   desc => $i18n->get('descending') },
			label=>$i18n->get('sort order'),
			hoverHelp=>$i18n->get('sort order description'),
			},
		sortBy =>{
			fieldType=>"selectBox",
			defaultValue=>'dateUpdated',
			tab=>'display',
			options=>\%sortByOptions,
			label=>$i18n->get('sort by'),
			hoverHelp=>$i18n->get('sort by description'),
			},
		notificationTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Notification",
			defaultValue=>'PBtmpl0000000000000027',
			tab=>'display',
			label=>$i18n->get('notification template'),
			hoverHelp=>$i18n->get('notification template description'),
			},
		searchTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Search",
			defaultValue=>'PBtmpl0000000000000031',
			tab=>'display',
			label=>$i18n->get('search template'),
			hoverHelp=>$i18n->get('search template description'),
			},
		postFormTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/PostForm",
			defaultValue=>'PBtmpl0000000000000029',
			tab=>'display',
			label=>$i18n->get('post template'),
			hoverHelp=>$i18n->get('post template description'),
			},
		threadTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Thread",
			defaultValue=>'PBtmpl0000000000000032',
			tab=>'display',
			label=>$i18n->get('thread template'),
			hoverHelp=>$i18n->get('thread template description'),
			},
		collaborationTemplateId =>{
			fieldType=>"template",
			namespace=>'Collaboration',
			defaultValue=>'PBtmpl0000000000000026',
			tab=>'display',
			label=>$i18n->get('system template'),
			hoverHelp=>$i18n->get('system template description'),
			},
		karmaPerPost =>{
			fieldType=>"integer",
			defaultValue=>0,
			tab=>'properties',
			visible=>$useKarma,
			label=>$i18n->get('karma/post'),
			hoverHelp=>$i18n->get('karma/post description'),
			},
		karmaSpentToRate => {
			fieldType => "integer",
			defaultValue=> 0,
			tab=>'properties',
			visible => $useKarma,
			label => $i18n->get('karma spent to rate'),
			hoverHelp => $i18n->get('karma spent to rate description'),
			},
		karmaRatingMultiplier => {
			fieldType => "integer",
			defaultValue=> 1,
			tab=>'properties',
			visible => $useKarma,
			label=>$i18n->get('karma rating multiplier'),
			hoverHelp=>$i18n->get('karma rating multiplier description'),
			},
		avatarsEnabled =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'properties',
			label=>$i18n->get('enable avatars'),
			hoverHelp=>$i18n->get('enable avatars description'),
			},
		postGroupId =>{
			fieldType=>"group",
			defaultValue=>'2',
			tab=>'security',
			label=>$i18n->get('who posts'),
			hoverHelp=>$i18n->get('who posts description'),
			},
		defaultKarmaScale => {
			fieldType=>"integer",
			defaultValue=>1,
			tab=>'properties',
			visible=>$useKarma,
			label=>$i18n->get("default karma scale"),
			hoverHelp=>$i18n->get('default karma scale help'),
			}
        );

        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		autoGenerateForms=>1,
		icon=>'collaboration.gif',
                tableName=>'Collaboration',
                className=>'WebGUI::Asset::Wobject::Collaboration',
                properties=>\%properties,
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate(@_);
	$newAsset->createSubscriptionGroup;
	return $newAsset;
}

#-------------------------------------------------------------------
sub getRssItems {
	my $self = shift;

	# XXX copied and reformatted this query from www_viewRSS, but why is it constructed like this?
	# And it's duplicated inside view, too!  Eeeagh!  And it uses the versionTag scratch var...
	my ($sortBy, $sortOrder) = ($self->getValue('sortBy'), $self->getValue('sortOrder'));
	my @postIds = $self->session->db->buildArray(<<"SQL", [$self->getId, $self->session->scratch->get('versionTag')]);
  SELECT asset.assetId
    FROM Thread
         LEFT JOIN asset ON Thread.assetId = asset.assetId
         LEFT JOIN Post ON Post.assetId = Thread.assetId AND Post.revisionDate = Thread.revisionDate
         LEFT JOIN assetData ON assetData.assetId = Thread.assetId
                                AND assetData.revisionDate = Thread.revisionDate
   WHERE asset.parentId = ? AND asset.state = 'published' AND asset.className = 'WebGUI::Asset::Post::Thread'
         AND (assetData.status = 'approved' OR assetData.tagId = ?)
   GROUP BY assetData.assetId
   ORDER BY $sortBy $sortOrder
SQL

	return map {
		my $postId = $_;
		my $post = WebGUI::Asset->newByDynamicClass($self->session, $postId);
		my $postUrl = $self->session->url->getSiteURL() . $post->getUrl;
		# Buggo: this is an abuse of 'author'.  'author' is supposed to be an email address.
		# But this is how it was in the original Collaboration RSS, so.
		({ author => $post->get('username'),
		   title => $post->get('title'),
		   link => $postUrl, guid => $postUrl,
		   description => $post->get('synopsis'),
		   pubDate => $self->session->datetime->epochToMail($post->get('dateUpdated')),
		   attachmentLoop => do {
			   if ($post->get('storageId')) {
				   my $storage = $post->getStorageLocation;
				   [map {({ 'attachment.url' => $storage->getUrl($_),
					    'attachment.path' => $storage->getPath($_),
					    'attachment.length' => $storage->getFileSize($_) })}
				    @{$storage->getFiles}]
			   } else { undef }
		   }
		 })
	} @postIds;
}

#-------------------------------------------------------------------
sub getEditTabs {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_Collaboration");

	return (['mail', $i18n->get('mail'), 9]);
}

#-------------------------------------------------------------------

=head2 getNewThreadUrl(  )

Formats the url to start a new thread.

=cut

sub getNewThreadUrl {
	my $self = shift;
	$self->getUrl("func=add;class=WebGUI::Asset::Post::Thread");
}

#-------------------------------------------------------------------

=head2 getSearchUrl (  )

Formats the url to the forum search engine.

=cut

sub getSearchUrl {
	my $self = shift;
	return $self->getUrl("func=search");
}

#-------------------------------------------------------------------

=head2 getSortByUrl ( sortBy )

Formats the url to change the default sort.

=head3 sortBy

The sort by string. Can be views, rating, date replies, or lastreply.

=cut

sub getSortByUrl {
	my $self = shift;
	my $sortBy = shift;
	return $self->getUrl("sortBy=".$sortBy);
}

#-------------------------------------------------------------------

=head2 getSubscribeUrl (  )

Formats the url to subscribe to the forum.

=cut

sub getSubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=subscribe");
}

#-------------------------------------------------------------------

=head2 getUnsubscribeUrl ( )

Formats the url to unsubscribe from the forum.

=cut

sub getUnsubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=unsubscribe");
}


#-------------------------------------------------------------------
sub _computeThreadCount {
	my $self = shift;
	return scalar @{$self->getLineage(['children'], {includeOnlyClasses => ['WebGUI::Asset::Post::Thread']})};
}

sub _computePostCount {
	my $self = shift;
	return scalar @{$self->getLineage(['descendants'], {includeOnlyClasses => ['WebGUI::Asset::Post']})};
}

#-------------------------------------------------------------------

=head2 incrementReplies ( lastPostDate, lastPostId )

Increments the reply counter for this forum.

=head3 lastPostDate

The date of the post being added.

=head3 lastPostId

The unique identifier of the post being added.

=cut

sub incrementReplies {
        my ($self, $lastPostDate, $lastPostId) = @_;
	my $threads = $self->_computeThreadCount;
        my $replies = $self->_computePostCount;
        $self->update({replies=>$replies, threads=>$threads, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
}

#-------------------------------------------------------------------

=head2 incrementThreads ( lastPostDate, lastPostId )

Increments the thread counter for this forum.

=head3 lastPostDate

The date of the post that was just added.

=head3 lastPostId

The unique identifier of the post that was just added.

=cut

sub incrementThreads {
        my ($self, $lastPostDate, $lastPostId) = @_;
        $self->update({threads=>$self->_computeThreadCount, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter on this forum.

=cut

sub incrementViews {
        my ($self) = @_;
        $self->update({views=>$self->get("views")+1});
}

#-------------------------------------------------------------------

=head2 isSubscribed (  )

Returns a boolean indicating whether the user is subscribed to the forum.

=cut

sub isSubscribed {
        my $self = shift;
	return $self->session->user->isInGroup($self->get("subscriptionGroupId"));	
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("collaborationTemplateId"));
	$self->session->style->setLink($self->getRssUrl,{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
        my $updatePrivs = ($self->session->form->process("groupIdView") ne $self->get("groupIdView") || $self->session->form->process("groupIdEdit") ne $self->get("groupIdEdit"));
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->get("subscriptionGroupId") eq "") {
		$self->createSubscriptionGroup;
	}
        if ($updatePrivs) {
                foreach my $descendant (@{$self->getLineage(["descendants"],{returnObjects=>1})}) {
                        $descendant->update({
                                groupIdView=>$self->get("groupIdView"),
                                groupIdEdit=>$self->get("groupIdEdit")
                                });
                }
        }
	$self->session->scratch->delete($self->getId."_sortBy");
        $self->session->scratch->delete($self->getId."_sortDir");
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session, $self->get("subscriptionGroupId"));
	$group->delete;
	if ($self->get("getMailCronId")) {
		my $cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
		$cron->delete if defined $cron;
	}
	$self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Calculates the rating of this forum from its threads and stores the new value in the forum properties.

=cut

sub recalculateRating {
        my $self = shift;
        my ($count) = $self->session->db->quickArray("select count(*) from Thread left join asset on Thread.assetId=asset.assetId 
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".$self->session->db->quote($self->getId)." and Post.rating>0");
        $count = $count || 1;
        my ($sum) = $self->session->db->quickArray("select sum(Post.rating) from Thread left join asset on Thread.assetId=asset.assetId 
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".$self->session->db->quote($self->getId)." and Post.rating>0");
        my $average = round($sum/$count);
        $self->update({rating=>$average});
}


#-------------------------------------------------------------------

=head2 setLastPost ( id, date )

Sets the most recent post in this collaboration system.

=head3 id

The assetId of the most recent post.

=head3 date

The date of the most recent post.

=cut

sub setLastPost {
        my $self = shift;
        my $id = shift;
        my $date = shift;
        $self->update({lastPostId=>$id, lastPostDate=>$date});
}

#-------------------------------------------------------------------

=head2 sumReplies ( )

Calculates the number of replies to this collaboration system and updates the counter to reflect that. Also updates thread count since it needs to know that to calculate reply count.

=cut

sub sumReplies {
        my $self = shift;
	my $threads = $self->_computeThreadCount;
	my $replies = $self->_computePostCount;
	$self->update({replies=>$replies, threads=>$threads});
}

#-------------------------------------------------------------------

=head2 sumThreads ( )

Calculates the number of threads in this collaboration system and updates the counter to reflect that.

=cut

sub sumThreads {
        my $self = shift;
	$self->update({threads=>$self->_computeThreadCount});
}

#-------------------------------------------------------------------

=head2 subscribe ( )

Subscribes a user to this collaboration system.

=cut

sub subscribe {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
	$group->addUsers([$self->session->user->userId]);
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Unsubscribes a user from this collaboration system

=cut

sub unsubscribe {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
	$group->deleteUsers([$self->session->user->userId],[$self->get("subscriptionGroupId")]);
}


#-------------------------------------------------------------------
sub _visitorCacheOk {
	my $self = shift;
	return ($self->session->user->userId eq '1'
		&& !$self->session->form->process('sortBy'));
}

sub _visitorCacheKey {
	my $self = shift;
	my $pn = $self->session->form->process('pn');
	return "view_".$self->getId."?pn=".$pn;
}

sub view {
	my $self = shift;
	if ($self->_visitorCacheOk) {
		my $out = WebGUI::Cache->new($self->session,$self->_visitorCacheKey)->get;
		$self->session->errorHandler->debug("HIT") if $out;
		return $out if $out;
	}
	my $scratchSortBy = $self->getId."_sortBy";
	my $scratchSortOrder = $self->getId."_sortDir";
	my $sortBy = $self->session->form->process("sortBy") || $self->session->scratch->get($scratchSortBy) || $self->get("sortBy");
	my $sortOrder = $self->session->scratch->get($scratchSortOrder) || $self->get("sortOrder");
	if ($sortBy ne $self->session->scratch->get($scratchSortBy) && $self->session->form->process("func") ne "editSave") {
		$self->session->scratch->set($scratchSortBy,$self->session->form->process("sortBy"));
	} elsif ($self->session->form->process("sortBy") && $self->session->form->process("func") ne "editSave") {
                if ($sortOrder eq "asc") {
                        $sortOrder = "desc";
                } else {
                        $sortOrder = "asc";
                }
                $self->session->scratch->set($scratchSortOrder, $sortOrder);
	}
	$sortBy ||= "dateUpdated";
	$sortOrder ||= "desc";
	my %var;
	$var{'user.canPost'} = $self->canPost;
        $var{"add.url"} = $self->getNewThreadUrl;
        $var{"rss.url"} = $self->getRssUrl;
        $var{'user.isModerator'} = $self->canModerate;
        $var{'user.isVisitor'} = ($self->session->user->userId eq '1');
	$var{'user.isSubscribed'} = $self->isSubscribed;
	$var{'sortby.title.url'} = $self->getSortByUrl("title");
	$var{'sortby.username.url'} = $self->getSortByUrl("username");
	$var{'karmaIsEnabled'} = $self->session->setting->get("useKarma");
	$var{'sortby.karmaRank.url'} = $self->getSortByUrl("karmaRank");
	$var{'sortby.date.url'} = $self->getSortByUrl("dateSubmitted");
	$var{'sortby.lastreply.url'} = $self->getSortByUrl("lastPostDate");
	$var{'sortby.views.url'} = $self->getSortByUrl("views");
	$var{'sortby.replies.url'} = $self->getSortByUrl("replies");
	$var{'sortby.rating.url'} = $self->getSortByUrl("rating");
	$var{"search.url"} = $self->getSearchUrl;
	$var{"subscribe.url"} = $self->getSubscribeUrl;
	$var{"unsubscribe.url"} = $self->getUnsubscribeUrl;
	my $sql = "select asset.assetId,asset.className,assetData.revisionDate as revisionDate
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=Thread.assetId and Thread.revisionDate = Post.revisionDate
		left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate = assetData.revisionDate
		where asset.parentId=".$self->session->db->quote($self->getId)." and asset.state='published' and 
		asset.className='WebGUI::Asset::Post::Thread' and assetData.revisionDate=(SELECT max(revisionDate) from assetData 
			where assetData.assetId=asset.assetId and (assetData.status='approved'  
			or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag"))."))
		group by assetData.assetId order by Thread.isSticky desc, ".$sortBy." ".$sortOrder;
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl,$self->get("threadsPerPage"));
	$p->setDataByQuery($sql);
	$self->appendPostListTemplateVars(\%var, $p);
	$self->appendTemplateLabels(\%var);

	# If the asset is not called through the normal prepareView/view cycle, first call prepareView.
	# This happens for instance in the viewDetail method in the Matrix. In that case the Collaboration
	# is called through the api.
	$self->prepareView unless ($self->{_viewTemplate});
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if ($self->_visitorCacheOk) {
		WebGUI::Cache->new($self->session,$self->_visitorCacheKey)
			->set($out,$self->get("visitorCacheTimeout"));
		$self->session->errorHandler->debug("MISS");
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 www_search ( )

The web method to display and use the forum search interface.

=cut

sub www_search {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_Collaboration');
        my %var;
	my $query = $self->session->form->process("query","text");
        $var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
         	.WebGUI::Form::hidden($self->session,{ name=>"func", value=>"search" })
        	.WebGUI::Form::hidden($self->session,{ name=>"doit", value=>1 });
        $var{'query.form'} = WebGUI::Form::text($self->session,{
                name=>'query',
                value=>$query
                });
        $var{'form.search'} = WebGUI::Form::submit($self->session,{value=>$i18n->get(170,'WebGUI')});
        $var{'form.footer'} = WebGUI::Form::formFooter($self->session);
        $var{'back.url'} = $self->getUrl;
	$self->appendTemplateLabels(\%var);
        $var{doit} = $self->session->form->process("doit");
        if ($self->session->form->process("doit")) {
		my $search = WebGUI::Search->new($self->session);
		$search->search({
				keywords=>$query,
				lineage=>[$self->get("lineage")],
				classes=>["WebGUI::Asset::Post", "WebGUI::Asset::Post::Thread"]
				});
		my $p = $search->getPaginatorResultSet($self->getUrl("func=search;doit=1;query=".$query), $self->get("threadsPerPage"));
		$self->appendPostListTemplateVars(\%var, $p);
        }
        return  $self->processStyle($self->processTemplate(\%var, $self->get("searchTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_subscribe (  )

The web method to subscribe to a collaboration.

=cut

sub www_subscribe {
	my $self = shift;
	$self->subscribe if $self->canSubscribe;
        return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unsubscribe (  )

The web method to unsubscribe from a collaboration.

=cut

sub www_unsubscribe {
	my $self = shift;
	$self->unsubscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------
# format the date according to rfc 822 (for RSS export)
my @_months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
sub _get_rfc822_date {
	my $self = shift;
        my ($time) = @_;
        my ($year, $mon, $mday, $hour, $min, $sec) = $self->session->datetime->localtime($time);
        my $month = $_months[$mon - 1];
        return sprintf("%02d %s %04d %02d:%02d:%02d GMT", 
                       $mday, $month, $year, $hour, $min, $sec);
}
  
#-------------------------------------------------------------------
# encode a string to include in xml (for RSS export)
sub _xml_encode {
	my $text = shift;
        $text =~ s/&/&amp;/g;
        $text =~ s/</&lt;/g;
        $text =~ s/\]\]>/\]\]&gt;/g;
        return $text;
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	my $disableCache = ($self->session->form->process("sortBy") ne "");
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->userId eq "1" && !$disableCache);
	return $self->SUPER::www_view(@_);
}

1;

