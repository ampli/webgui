package WebGUI::Middleware::StackTrace;

use strict;
use warnings;
use parent qw/Plack::Middleware/;
use Devel::StackTrace;
use Devel::StackTrace::AsHTML;
use Try::Tiny;
use Plack::Util::Accessor qw( force no_print_errors );
use Scalar::Util 'blessed';
use Data::Dumper;
use Plack::Middleware::StackTrace;
use WebGUI::Session::Log;

BEGIN { 

    our $StackTraceClass = "Devel::StackTrace";
    if (try { require Devel::StackTrace::WithLexicals; 1 }) {
        $StackTraceClass = "Devel::StackTrace::WithLexicals";
    }

    my $old_fatal = *WebGUI::Session::Log::fatal{CODE};
    no warnings 'redefine';

    *WebGUI::Session::Log::fatal = sub {
        my $self = shift;
        my $message = shift;
        $self->{_stacktrace} = $StackTraceClass->new;
        $old_fatal->($self, $message, @_);
    };

}

# Optional since it needs PadWalker

sub call {
    my($self, $env) = @_;

    my $res = try { $self->app->($env) };

    if( my $trace = $env->{'webgui.session'}->log->{_stacktrace} ) {

        undef $env->{'webgui.session'}->log->{_stacktrace};  # the stack trace modules do create circular references; this is necessary

        my $text = trace_as_string($trace);
        $env->{'psgi.errors'}->print($text) unless $self->no_print_errors;
        my $html = eval { trace_as_html($trace, $env->{'webgui.session'}) };
        if ( $html and ($env->{HTTP_ACCEPT} || '*/*') =~ /html/) {
            $res = [500, ['Content-Type' => 'text/html; charset=utf-8'], [ utf8_safe($html) ]];
        } else {
            $res = [500, ['Content-Type' => 'text/plain; charset=utf-8'], [ utf8_safe($text) ]];
        }

    }    
     
    return $res;
}


sub trace_as_string {
    my $trace = shift;

    my $st = '';
    my $first = 1;
    foreach my $f ( $trace->frames() ) {
        $st .= "\t" unless $first;
        $st .= $f->as_string($first) . "\n";
        $first = 0;
    }

    return $st;
}

do { 
    no strict 'subs'; 
    no strict 'refs'; 
    *encode_html = *Devel::StackTrace::AsHTML::encode_html{CODE};
    *_build_context = *Devel::StackTrace::AsHTML::_build_context{CODE};
    *_build_arguments = *Devel::StackTrace::AsHTML::_build_arguments{CODE};
    *_build_lexicals = *Devel::StackTrace::AsHTML::_build_lexicals{CODE};
    # XXX what else?
};

sub trace_as_html {

    my $trace = shift;
    my $session = shift or die;
    my %opt   = @_;

    # replaces: my $ret = $trace->as_html;  
    # ... which just did __PACKAGE__->render
    # render copied and inlined here

    my $extras = sub { $session->url->extras(@_) };

    my $msg = encode_html($trace->frame(1)->args);
    my $out = qq{<!doctype html><head><title>Error: ${msg}</title>};

    $opt{style} ||= \<<STYLE;
a.toggle { color: #444 }
body { margin: 0; padding: 0; background: #fff; color: #000; }
h1 { margin: 0 0 .5em; padding: .25em .5em .1em 1.5em; border-bottom: thick solid #002; background: #444; color: #eee; font-size: x-large; }
pre.message { margin: .5em 1em; }
li.frame { font-size: small; margin-top: 3em }
li.frame:nth-child(1) { margin-top: 0 }
pre.context { border: 1px solid #aaa; padding: 0.2em 0; background: #fff; color: #444; font-size: medium; }
pre .match { color: #000;background-color: #f99; font-weight: bold }
pre.vardump { margin:0 }
pre code strong { color: #000; background: #f88; }

table.lexicals, table.arguments { border-collapse: collapse }
table.lexicals td, table.arguments td { border: 1px solid #000; margin: 0; padding: .3em }
table.lexicals tr:nth-child(2n) { background: #DDDDFF }
table.arguments tr:nth-child(2n) { background: #DDFFDD }
.lexicals, .arguments { display: none }
.variable, .value { font-family: monospace; white-space: pre }
td.variable { vertical-align: top }
STYLE

    if (ref $opt{style}) {
        $out .= qq(<style type="text/css">${$opt{style}}</style>);
    } else {
        $out .= qq(<link rel="stylesheet" type="text/css" href=") . encode_html($opt{style}) . q(" />);
    }

    $out .= <<HEAD;
<script language="JavaScript" type="text/javascript">
function toggleThing(ref, type, hideMsg, showMsg) {
 var css = document.getElementById(type+'-'+ref).style;
 css.display = css.display == 'block' ? 'none' : 'block';

 var hyperlink = document.getElementById('toggle-'+ref);
 hyperlink.textContent = css.display == 'block' ? hideMsg : showMsg;
}

function toggleArguments(ref) {
 toggleThing(ref, 'arguments', 'Hide function arguments', 'Show function arguments');
}

function toggleLexicals(ref) {
 toggleThing(ref, 'lexicals', 'Hide lexical variables', 'Show lexical variables');
}
</script>
<link rel="stylesheet" type="text/css" href="@{[ $extras->('yui/build/treeview/assets/skins/sam/treeview.css') ]}" />
<link rel="stylesheet" type="text/css" href="@{[ $extras->('yui/build/button/assets/skins/sam/button.css') ]}" />
<link rel="stylesheet" type="text/css" href="@{[ $extras->('yui/build/button/assets/skins/sam/button.css') ]}" /> 
<script type="text/javascript" src="@{[ $extras->('yui/build/yahoo-dom-event/yahoo-dom-event.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/yuiloader/yuiloader-min.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/event/event-min.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/dom/dom-min.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/treeview/treeview-min.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/element/element-min.js') ]}"></script>
<script type="text/javascript" src="@{[ $extras->('yui/build/button/button-min.js') ]}"></script>

</head>
<body>
<h1>Error trace</h1><pre class="message">$msg</pre><ol>
HEAD

warn "came up with URL to treeview-min.js: @{[ $extras->('yui/build/treeview/treeview-min.js') ]}";

    my $accumulated_asset_info = [];  # record the stack frames from when we find an asset on the call stack

    $trace->next_frame; # ignore the head
    my $i = 0;
    while (my $frame = $trace->next_frame) {

        $i++;
        $out .= join(
            '',
            '<li class="frame">',
            $frame->subroutine ? encode_html("in " . $frame->subroutine) : '',
            ' at ',
            $frame->filename ? encode_html($frame->filename) : '',
            ' line ',
            $frame->line,
            _build_asset_info($i, ($frame->args)[0], $accumulated_asset_info, $frame), # adds data to $accumulated_asset_info; this line added relative the stock Devel::StackTrace::AsHTML
            q(<pre class="context"><code>),
            _build_context($frame) || '', 
            q(</code></pre>),
            _build_arguments($i, [$frame->args]),
            $frame->can('lexicals') ? _build_lexicals($i, $frame->lexicals) : '',
            q(</li>),
        );
    }
    $out .= qq{</ol>};

    # dump the asset tree

    my $assets = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {returnObjects=>1});

    my $tree = { type => 'text', label => 'root', children => [], };
    
    for my $asset (@$assets) {
        # create a tree structure of assets matching their lineage
        # the format (arrays, hashes, fields) matches what YAHOO.treeview expects
        # when we find an asset mentioned in one of the stack trace frames above, we add the saved file/line/etc info to the label
        my $lineage = $asset->get('lineage');
        my @parts = $lineage =~ m/(.{6})/g;
        # warn "asset:  $asset lineage: $lineage parts: @parts";
        my $node = $tree;
        while(@parts) {
            my $part = shift @parts;
            if((my $child_node) = grep $_->{lineage_chunk} eq $part, @{$node->{children}}) {
                $node = $child_node;
            } else {
                my $label = $asset->get('title') . ': Id: ' . $asset->getId . ' Class: ' . ref($asset);
                for my $message ( map $_->{message}, grep $_->{asset_id} eq $asset->getId, @$accumulated_asset_info ) {
                    $label .= " <----- $message";
                } 
                my $child_node = { 
                    type => 'text', 
                    label => $label,
                    lineage_chunk => $part, 
                    children => [ ], 
                };
                push @{$node->{children}}, $child_node;
                $node = $child_node;
            }
        }
    }
    
    use JSON::PP; # JSON::XS creates something that's mangled
    my $json_tree = JSON::PP->new->ascii->pretty->encode( [ $tree ] );

    # warn "json_tree: $json_tree";
    # do { open my $fh, '>', 'json.debug2.js' or die $!; $fh->print($json_tree); };
 
    $out .= qq{
          <ol><li>
             <div id="treeDiv1"></div> 
          </ol></li>
          <script language="javascript">
              var tree = new YAHOO.widget.TreeView("treeDiv1", $json_tree); 
              tree.expandAll();
              tree.draw();
          </script>
    };

    $out .= "</body></html>";

    return $out;
}

sub _build_asset_info {
    my($id, $asset, $accumulated_asset_info, $frame) = @_;

    return '' unless $asset and Scalar::Util::blessed($asset) and $asset->isa('WebGUI::Asset');

    my $asset_title = $asset->get('title');
    my $asset_id = $asset->getId;
    my $asset_class = ref $asset;
    
    my $message = "Stack frame number: $id AssetID: $asset_id Class: $asset_class Title: ``$asset_title''";

    push @$accumulated_asset_info, { asset_id => $asset_id, message => $message, };

    return $message;
}

sub utf8_safe {
    my $str = shift;

    # NOTE: I know messing with utf8:: in the code is WRONG, but
    # because we're running someone else's code that we can't
    # guarnatee which encoding an exception is encoded, there's no
    # better way than doing this. The latest Devel::StackTrace::AsHTML
    # (0.08 or later) encodes high-bit chars as HTML entities, so this
    # path won't be executed.
    if (utf8::is_utf8($str)) {
        utf8::encode($str);
    }

    $str;
}

1;

__END__

=head1 NAME

Plack^HWebGUI::Middleware::StackTrace - Displays stack trace when your app dies

=head1 SYNOPSIS

  enable "+WebGUI::Middleware::StackTrace";

=head1 DESCRIPTION

This middleware is a copy and modification of L<Plack::Middleware::StackTrace>, a
middleware which catches exceptions (run-time errors) happening in your
application and displays nice stack trace screen.
This copy has been extended to display additional WebGUI specific information.

You're recommended to use this middleware during the development and
use L<Plack::Middleware::HTTPExceptions> in the deployment mode as a
replacement, so that all the exceptions thrown from your application
still get caught and rendered as a 500 error response, rather than
crashing the web server.

Catching errors in streaming response is not supported.

=head1 CONFIGURATION

=over 4

=item force

  enable "+WebGUI::Middleware::StackTrace", force => 1;

Force display the stack trace when an error occurs within your
application and the response code from your application is
500. Defaults to off.

The use case of this option is that when your framework catches all
the exceptions in the main handler and returns all failures in your
code as a normal 500 PSGI error response. In such cases, this
middleware would never have a chance to display errors because it
can't tell if it's an application error or just random C<eval> in your
code. This option enforces the middleware to display stack trace even
if it's not the direct error thrown by the application.

=item no_print_errors

  enable "+WebGUI::Middleware::StackTrace", no_print_errors => 1;

Skips printing the text stacktrace to console
(C<psgi.errors>). Defaults to 0, which means the text version of the
stack trace error is printed to the errors handle, which usually is a
standard error.

=back

=head1 AUTHOR

Tokuhiro Matsuno

Tatsuhiko Miyagawa

Scott Walters

With code taken from:

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>
    
Shawn M Moore

HTML generation code is ripped off from L<CGI::ExceptionManager> written by Tokuhiro Matsuno and Kazuho Oku.

=head1 SEE ALSO

L<Plack::Middleware::StackTrace>

L<Devel::StackTrace::AsHTML> L<Plack::Middleware> L<Plack::Middleware::HTTPExceptions>

=cut

