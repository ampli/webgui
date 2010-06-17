package WebGUI::i18n::English::Asset_InOutBoard;
use strict;

our $I18N = {
	'In Out Template' => {
		message => q|In/Out Template|,
		lastUpdated =>1091624565
	},

	'22' => {
		message => q|In/Out Board, Report Template|,
		lastUpdated =>1091624565
	},

	'select delegate' => {
		message => q|In/Out Board, Select Delegates|,
		lastUpdated =>1122010599
	},

	'in/out status delegates' => {
		message => q|In/Out Status Delegates|,
		lastUpdated =>1122010599
	},

	'in/out status delegates description' => {
		message => q|Use this form to choose others who can change your status on the In/Out Board.  All users
		who you have already chosen to change your status will be preselected.  To remove a user, deselect them.|,
		lastUpdated =>1139260288
	},

	'showReport' => {
		message => q|A boolean indicating whether or not the <i>rows_loop</i> variable will be set.|,
		lastUpdated => 1149393724,
	},

	'report.form' => {
		message => q|A variable that contains an HTML form for limiting the scope, by date or department, of the report.|,
		lastUpdated => 1149393724,
	},

	'username.label' => {
		message => q|Internationalized label for the "Username" column of the report.|,
		lastUpdated => 1149393724,
	},

	'status.label' => {
		message => q|Internationalized label for the "Status" column of the report.|,
		lastUpdated => 1149393724,
	},

	'date.label' => {
		message => q|Internationalized label for the "Date" column of the report.|,
		lastUpdated => 1149393724,
	},

	'message.label' => {
		message => q|Internationalized label for the "Message" column of the report.|,
		lastUpdated => 1149393724,
	},

	'updatedBy.label' => {
		message => q|Internationalized label for the "Updated By" column of the report.|,
		lastUpdated => 1149393724,
	},

	'report rows_loop' => {
		message => q|A loop containing the rows of data for the In/Out Board Report&nbsp;|,
		lastUpdated => 1149393724,
	},

	'department' => {
		message => q|A variable that returns the user's department. If no department has been assigned to this user, an internationalized label for "No Department" will be used.|,
		lastUpdated => 1149393724,
	},

	'createdBy' => {
		message => q|A variable that returns which user, either the user himself or a delegate, changed the status for this user.|,
		lastUpdated => 1149393724,
	},

	'23' => {
		message => q|<p>The following variables are available from In/Out Board Report template:</p>
|,
		lastUpdated =>1149394078
	},

        '1 description' => {
                message => q|The status list allows you to customize what the 'states' of a user are. i.e., 'In' or 'Out'.|,
                lastUpdated => 1138988640,
        },

        '12 description' => {
                message => q|How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?|,
                lastUpdated => 1138988640,
        },

        'In Out Template description' => {
                message => q|Choose a template to display the In/Out Board to users.|,
                lastUpdated => 1165518044,
        },

        '13 description' => {
                message => q|Choose a template to display the In/Out Board Report.|,
                lastUpdated => 1165518045,
        },

        '3 description' => {
                message => q|Which groups are allowed to view reports generated by the In/Out Board Wobject?|,
                lastUpdated => 1138988640,
        },

        'inOutGroup description' => {
                message => q|Which groups are allowed to use this In/Out Board to change their status?|,
                lastUpdated => 1138988640,
        },

	'20' => {
		message => q|In/Out Board, Template|,
		lastUpdated =>1091624565
	},

	'canViewReport' => {
		message => q|A boolean indicating whether or not the <i>viewReportURL</i> variable will be set.|,
		lastUpdated => 1149393667,
	},

	'viewReportURL' => {
		message => q|URL that links to the view report page.|,
		lastUpdated => 1149393667,
	},

	'selectDelegatesURL' => {
		message => q|URL that links to a form where users can select other users (delegates) who
can alter their status.|,
		lastUpdated => 1149393667,
	},

	'displayForm' => {
		message => q|A boolean indicating whether or not the <i>form</i> variable will be set.|,
		lastUpdated => 1149393667,
	},

	'form' => {
		message => q|A variable that contains the HTML for displaying the In/Out Entry Form to update status for the current user or another user.|,
		lastUpdated => 1149393667,
	},

	'rows_loop' => {
		message => q|A loop containing the rows of data for the In/Out Board|,
		lastUpdated => 1149393667,
	},

	'deptHasChanged' => {
		message => q|A boolean value indicating whether or not this row of data is for a department that is different than the previous rows|,
		lastUpdated => 1165518086,
	},

	'username' => {
		message => q|A variable that returns the user's name.  If the first and last name fields are defined in the user profile, that is what is returned.  Otherwise, the user's WebGUI username is returned.  i.e., "John Doe" vs "Jdoe"|,
		lastUpdated => 1165518097,
	},

	'status' => {
		message => q|A variable that returns the user's status.  The status of a user is defined by the Status List in the Wobject Properties.  If no status is set for the current user 'Never Checked In' is returned.|,
		lastUpdated => 1149393667,
	},

	'dateStamp' => {
		message => q|A variable that returns the date the status of the user was last updated.|,
		lastUpdated => 1149393667,
	},

	'message' => {
		message => q|A variable that returns what the user entered in the "What's going on?" field when updating their status.|,
		lastUpdated => 1149393667,
	},

	'paginateBar' => {
		message => q|A variable that returns the HTML necessary to create a Traditional Pagination Bar.  i.e., &gt;&gt; First, 1, 2, Last &lt;&lt;|,
		lastUpdated => 1149393667,
	},

	'21' => {
		message => q|<p>The following variables are made available from In/Out Board:</p>
  |,
		lastUpdated =>1149393698
	},

	'2' => {
		message => q|Enter one per line.|,
		lastUpdated =>1091624565
	},

	'in/out status delegates subtext' => {
		message => q|Multiple users can be selected as delegates.  Delegates will be able to update your status.|,
		lastUpdated =>1122523790,
	},

	'17' => {
		message => q|End Date|,
		lastUpdated =>1091624565
	},

	'17 description' => {
		message => q|Like the Start Date, End Date can help limit the size of your report by not showing changes in status after the date you select.|,
		lastUpdated =>1139265525
	},

	'16' => {
		message => q|Start Date|,
		lastUpdated =>1091624565
	},

	'16 description' => {
		message => q|The Start Date can help limit the size of your report by not showing changes in status before the date you select.|,
		lastUpdated =>1139262071
	},

	'15' => {
		message => q|Never Checked In|,
		lastUpdated =>1091624565
	},

	'14' => {
		message => q|Paginate Report After|,
		lastUpdated =>1091624565
	},

	'14 description' => {
		message => q|Select how many lines you want in each page of the report.  You will be provided links to access additional pages of the report.|,
		lastUpdated =>1139264214
	},

	'13' => {
		message => q|Report Template|,
		lastUpdated =>1091624565
	},

	'12' => {
		message => q|Paginate After|,
		lastUpdated =>1091624565
	},

	'11' => {
		message => q|Out|,
		lastUpdated =>1091624565
	},

	'10' => {
		message => q|In|,
		lastUpdated =>1091624565
	},

	'assetName' => {
		message => q|In/Out Board|,
		lastUpdated =>1091624565
	},

	'8' => {
		message => q|Status Log Report|,
		lastUpdated =>1091624565
	},

	'7' => {
		message => q|No Department|,
		lastUpdated =>1091624565
	},

	'6' => {
		message => q|What's happening?|,
		lastUpdated =>1091624565
	},

	'6 description' => {
		message => q|You can enter in reasons for the change in status (doctor's appointment, went home) etc. here.|,
		lastUpdated =>1139254446
	},

	'delegate' => {
		message => q|Update status for: |,
		lastUpdated =>1122319088
	},

	'delegate description' => {
		message => q|Select a name from this list to update the status for someone other than yourself.|,
		lastUpdated =>1139253866
	},

	'myself' => {
		message => q|Myself|,
		lastUpdated =>1122319088
	},

	'5' => {
		message => q|Status|,
		lastUpdated =>1091624565
	},

	'5 description' => {
		message => q|You may select one status from the list.  If you would like to further explain the reason for the status, use the "What's happening" field.|,
		lastUpdated =>1139253909
	},

	'4' => {
		message => q|View Report|,
		lastUpdated =>1091624565
	},

	'3' => {
		message => q|Who can view reports?|,
		lastUpdated =>1091624565
	},

	'1' => {
		message => q|Status List|,
		lastUpdated =>1091624565
	},

	'inOutGroup' => {
		message => q|Who can log in/out?|,
		lastUpdated =>1091624565
	},

	'username label' => {
		message => q|Username|,
		lastUpdated =>1123199740
	},

	'date label' => {
		message => q|Date|,
		lastUpdated =>1123199740
	},

	'message label' => {
		message => q|Message|,
		lastUpdated =>1123199740
	},

	'updatedBy label' => {
		message => q|Updated By|,
		lastUpdated =>1123199740
	},

	'all departments' => {
		message => q|All Departments|,
		lastUpdated =>1123266324
	},

	'filter departments' => {
		message => q|Filter departments:|,
		lastUpdated =>1123266322
	},

	'filter departments description' => {
		message => q|Each In/Out Board can be configured to serve multiple departments.  By default, all departments are shown in the report.  Select the name of any one department to limit the report to only display status changes from that department.| ,
		lastUpdated =>1139262439
	},

	'IT' => {
		message => q|IT|,
		lastUpdated =>1152589736,
		context => q|User profile field, abbreviation for Information Technology|,
	},

	'HR' => {
		message => q|HR|,
		lastUpdated =>1152589736,
		context => q|User profile field, abbreviation for Human Resources|,
	},

	'Regular Staff' => {
		message => q|Regular Staff|,
		lastUpdated =>1152589736,
		context => q|User profile field|,
	},

	'Department' => {
		message => q|Department|,
		lastUpdated =>1152589736,
		context => q|label for user profile field|,
	},

	'report title' => {
		message => q|In/Out Board Report|,
		lastUpdated =>1165810121,
		context => q|Default i18n label for a In/Out Board Report|,
	},

	'reportTitleLabel' => {
		message => q|Internationalized title for an In/Out Board Report.|,
		lastUpdated =>1165810121,
	},

	'select delegates label' => {
		message => q|Select Delegates|,
		lastUpdated =>1165810121,
		context => q|Default i18n label for the URL to select delegates|,
	},

	'selectDelegatesLabel' => {
		message => q|Internationalized title for the URL to select delegates.|,
		lastUpdated =>1165810121,
	},

	'view report label' => {
		message => q|View Report|,
		lastUpdated =>1165810121,
	},

	'viewReportLabel' => {
		message => q|Internationalized title for the URL to view reports.|,
		lastUpdated =>1165810121,
	},

	'in out board asset template variables title' => {
		message => q|In/Out Board Asset Template Variables|,
		lastUpdated => 1168992432
	},

	'in out board asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1168992436
	},

	'statusList' => {
		message => q|A string with all of the possible board statuses separated by newlines.|,
		lastUpdated => 1168992648
	},

	'reportViewerGroup' => {
		message => q|The ID of the group that is allowed to view reports.|,
		lastUpdated => 1168992648
	},

	'inOutTemplateId' => {
		message => q|The ID of the template that is used to display the main screen of the In/Out Board.|,
		lastUpdated => 1168992648
	},

	'reportTemplateId' => {
		message => q|The ID of the template that is used to display In/Out Board reports.|,
		lastUpdated => 1168992648
	},

	'paginateAfter' => {
		message => q|The number of rows should be displayed per page in the main In/Out Board.|,
		lastUpdated => 1168992648
	},

};

1;
