#!/usr/bin/perl

# laurent Montel <montel@kde.org>
# this function changes QStringList::split (QT3_SUPPORT) to QString::split (QT4)

use lib qw( . );
use functionUtilkde; 

sub addQStringElement
{
	my $result = $_[0];
	if ( $result =~ /^\"/ ) {
		$result = "QString( " . $result . ")";
	}
	return $result;
};

foreach my $file (@ARGV) {
    functionUtilkde::substInFile {
    if (my ($blank, $prefix, $contenu) = m!^(\s*.*)(QStringList::split.*)\((.*)\s*\);$!) {
			#warn "blank : $blank, prefix : $prefix, contenu : $contenu \n";
			if ( my ($firstelement, $secondelement, $thirdelement) = m!.*?\(\s*(.*),\s*(.*),\s*(.*)\);\s*$!) {
					#warn "three element : first : $firstelement : second $secondelement : third $thirdelement \n";
					my $argument = $prefix;
                    # Remove space before argument
                    $secondelement =~ s/ //g;	
					$thirdelement =~ s/ //g;
					
					$secondelement = addQStringElement( $secondelement );
					if ( $blank =~ /insertStringList/ ) {
							$thirdelement =~ s/\)//g;
                        if ( $thirdelement =~ /true/ ) {
                            #QString::KeepEmptyParts
                            $_ = $blank . $secondelement . ".split( " . $firstelement . ", QString::KeepEmptyParts" . "));\n" ;
                        }
                        elsif ( $thirdelement =~ /false/ ) {
                            #QString::SkipEmptyParts
                            $_ = $blank . $secondelement . ".split( " . $firstelement . ", QString::SkipEmptyParts" . "));\n" ;
                        }
                        # different element
                        else {
                            $_ = $blank . $secondelement . ".split( " . $firstelement . ", $thirdelement" . "));\n" ;
                    }	
                    }
                    else {
						if ( $thirdelement =~ /true/ ) {
							#QString::KeepEmptyParts
							$_ = $blank . $secondelement . ".split( " . $firstelement . ", QString::KeepEmptyParts" . ");\n" ;	
						}
						elsif ( $thirdelement =~ /false/ ) {
							#QString::SkipEmptyParts
							$_ = $blank . $secondelement . ".split( " . $firstelement . ", QString::SkipEmptyParts" . ");\n" ;
						}
						# different element
						else {
							$_ = $blank . $secondelement . ".split( " . $firstelement . ", $thirdelement" . ");\n" ;
					}
					}

			}
        	elsif ( my ($firstelement, $secondelement) = m!.*?\(\s*(.*),\s*(.*)\);\s*$!) {
					my $argument = $prefix;
					# Remove space before argument
					$secondelement =~ s/ //g;
					$secondelement = addQStringElement( $secondelement ); 
					if ($firstelement ~= /QRegExp/ ) {
                        if ( $blank =~ /insertStringList/ ) {
                                $secondelement =~ s/\)//g;
                                $_ = $blank . $secondelement . ".split( " . $fir
stelement . " QString::SkipEmptyParts));\n" ;
                        }
                        else {
                            $_ = $blank . $secondelement . ".split( " . $firstel
ement . "QString::SkipEmptyParts);\n" ;
					}
					else {
						if ( $blank =~ /insertStringList/ ) {
								$secondelement =~ s/\)//g;
								$_ = $blank . $secondelement . ".split( " . $firstelement . "));\n" ;
						}
						else {
            				$_ = $blank . $secondelement . ".split( " . $firstelement . ");\n" ;
					}
				}
        	}
    	}
    } $file;

}
functionUtilkde::diffFile( "@ARGV" );

