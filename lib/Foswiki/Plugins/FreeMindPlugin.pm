=pod

---+ package FreeMindPlugin

=cut

package Foswiki::Plugins::FreeMindPlugin;

use strict;

use File::Basename;

require Foswiki::Func;    
require Foswiki::Plugins;

use vars qw( $VERSION $RELEASE $SHORTDESCRIPTION $debug $pluginName);

our $VERSION = '$Rev: 15942 (11 Aug 2008) $';
our $RELEASE = '1.1';
our $SHORTDESCRIPTION = 'Plugin to render FreeMind mindmaps';

$pluginName = 'FreeMindPlugin';

sub initPlugin {
    my( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if( $Foswiki::Plugins::VERSION < 1.026 ) {
        Foswiki::Func::writeWarning( "Version mismatch between $pluginName and Plugins.pm" );
        return 0;
    }

    $debug = $Foswiki::cfg{Plugins}{FreeMindPlugin}{Debug} || 0;

    # register the _handleFreeMind function 
    Foswiki::Func::registerTagHandler( 'FREEMIND', \&_handleFreeMind );

    # Plugin correctly initialized
    return 1;
}

sub getPluginResourceDir() {
    return Foswiki::Func::getPubUrlPath() . "/System/${pluginName}/";
}

# Handler for the %FREEMIND{...}% variable
sub _handleFreeMind {
    my($session, $params, $theTopic, $theWeb) = @_;

    my $mindMap = $params->{mindMap} || $params->{file};
    my $height = $params->{height} || "400";
    my $width = $params->{width} || "550";
    my $quality = $params->{quality} || "high";
    my $renderer = $params->{renderer} || "flash";

    my $flashobject = getPluginResourceDir() . "swfobject.js"; 
    my $freeMindRenderer = getPluginResourceDir() . "visorFreemind.swf";
    my $id = fileparse($mindMap);
    my $flashVersion = 6;
    my $background = "#9999ff";
    my $expressInstaller = getPluginResourceDir() . "expressInstall.swf";

    my $jarfile = getPluginResourceDir() . "freemindbrowser.jar"; 

    my $output;

    if($renderer eq "flash") {
      $output = "\n" .
"<script type=\"text/javascript\" src=\"$flashobject\"></script>". "\n" .
"<div id=\"$id\">"."\n" .
" Flash plugin or Javascript are turned off.". "\n" .
" Activate both and reload to view the mindmap". "\n" .
"</div>". "\n" .
"<script type=\"text/javascript\">". "\n" .
"var flashvars = {};" . "\n" .
"flashvars.openURL = \"_blank\";" . "\n" . 
"flashvars.initLoadFile = \"$mindMap\";" . "\n" . 
"flashvars.startCollapsedToLevel = \"5\";" . "\n" .
"var params = {};" . "\n" .
"params.quality = \"$quality\";" . "\n" .
"swfobject.embedSWF(\"$freeMindRenderer\", \"$id\", \"$width\", \"$height\", \"$flashVersion\", \"$expressInstaller\", flashvars, params);". "\n" .
"</script>" . "\n";
} elsif ($renderer eq "applet") {
    $output = "\n" .
"  <applet code=\"freemind.main.FreeMindApplet.class\" archive=\"$jarfile\" width=\"$width\" height=\"$height\">" . "\n" .
"    <param name=\"type\" value=\"application/x-java-applet;version=1.4\" />" . "\n" .
"    <param name=\"scriptable\" value=\"false\" /> " . "\n" .
"    <param name=\"modes\" value=\"freemind.modes.browsemode.BrowseMode\" />" . "\n" .
"    <param name=\"browsemode_initial_map\" value=\"$mindMap\" />" . "\n" .
"    <param name=\"initial_mode\" value=\"Browse\" />" . "\n" .
"    <param name=\"selection_method\" value=\"selection_method_direct\" />" . "\n" .
"  </applet>" . "\n";
}

  return $output;
}

1;
