## kDebug2kdDebug.sh
## Script to port from kDebugInfo and friends to kdDebug and friends.
## Example:
## kDebugInfo( [area,] "format %a - %b", arga, argb )
## becomes
## kdDebug( [area] ) << "format " << arga << " - " << argb << endl;
##
## Written by David Faure <faure@kde.org>, licensed under GPL.
## 17/03/2000

find $1 -name '*[cCph]' -type f | while read file; do
perl -i -e \
'
$inkdebug=0;
while (<>)
{
    if ( $inkdebug )
    {
	chop;
	#print "Reading line : " . $_ . "\n";
	$statement .= $_;
    }
    elsif ( /kDebug/ )
    {
	$inkdebug = 1;
	chop;
	$statement = $_;
    }
    
    if ( $inkdebug )
    {
	if ( /\)[\s]*;/ ) # look for );
	{
	    $inkdebug = 0;
	    $_ = $statement;
	    ## Ok, now we have the full line
	    ## 1 - Parse
	    m/(^.*kDebug[a-zA-Z]*)[\s]*\(/ || die "parse error on kDebug*";
	    $line=$1; # has the indentation, //, and the kDebug* name
	    s/$line[\s]*\([\s]*//; # remove line and (
	    $line =~ s/kDebugInfo/kdDebug/;
	    $line =~ s/kDebugWarning/kdWarning/;
	    $line =~ s/kDebugError/kdError/;
	    $line =~ s/kDebugFatal/kdFatal/;
	    $area = "";
	    if ( s/^([0-9]+)[\s]*,[\s]*//) # There is an area
	    {
		$area = $1;     # Store it
		$line .= "(" . $area . ")";
	    } else
	    { $line .= "()";  }

	    if ( !s/^\"([^\"]*)\"// ) # There is no format
	    {
		$line = $line . " << \"" . $1 . "\"";
	    } else
	    {
		$format = $1;
		s/[\s]*\);$/,/; # replace trailing junk with , for what follows
		$arguments = $_;

		## 2 - Look for %x
		@stringbits = split( "(%[0-9]*[a-z])", $format );
		foreach ( @stringbits )
		{
		    #print $_ . "\n";
		    if ( /(%[0-9]*[a-z])/ ) # This item is a format
		    {
			## 3 - Find argument
			$arguments =~ s/[\s]*([^,]+)[\s]*[,]//;
			# Remove trailing .ascii() and latin1()
			$arg = $1;
			$arg =~ s/\.ascii\(\)$//;
			$arg =~ s/\.latin1\(\)$//;
			$line = $line . " << " . $arg;
		    } else # This item is some litteral
		    {
			$line = $line . " << \"" . $_ . "\"";
		    }
		}
		
	    }
	    $line = $line . " << endl;\n";
	    print $line;
	}
    }
    else
    { 
        # Normal line
	print;
    }
}
' $file

done

