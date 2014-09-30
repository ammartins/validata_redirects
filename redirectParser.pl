#!/usr/bin/perl

use strict;

open FH, '<', 'derp.txt' or die('Not able to open file');
open OU, '>', 'redirectFinal.txt' or die('Not able to create file');

# Http 3XX codes
# 300
# 301
# 302
# 303
# 304
# 305
# 306
# 307


sub getUrls {
    my $first;
    my $url;
    my $response;
    my $rebuildLine;
    my $count = 0;
    while ( <FH> ) {
        my $line = $_;
        if ( $line =~ m/\n\n|#.*/g ) {
            print OU $line;
            next;
        }
        elsif ( $line =~ m/Redirect/ ) {
            print "\n\n Line Number $count $line \n\n";
            $count = $count +1;
            # Redirect 301 /en/help www.leaseweb.com
            $_ =~ m[(Redirect|RedirectMatch)\s(3\d\d|permanent)\s(.*)\s(/.*|http://.*|https://.*)]g;
            $rebuildLine = $1." ".$2." ".$3." ";
            $first = $3;

            if ( !($first =~ m/http:\/\//g or $first =~ m/https:\/\//g) ) {
                #$url = "http://www.leaseweb.com".$first."\n";
                $url = "http://marketing.lsw2.devleaseweb.com".$first."\n";
            } else {
                $url = $first;
            }

            $response = getCurl($url, '-I');

            if ( $response =~ m/301/g ) {
                my $correctUrl = getNewResponse($url);
                print "\n\n\n c - $correctUrl \n\n\n";
                print OU $rebuildLine.$correctUrl;
            }
            elsif ( $response =~ m/200/g ) {
                print OU $_;
                
            }
            elsif ( $response =~ m/404/g ) {
                print "\n\n $3 - $4 returns 404 \n\n";
                die(' 404 ');
            }
            else {
                print "\n\n $response -  $3 - $4 returns 404 \n\n";
                print OU $_;
            }
        }
        else {
            print OU "\n";
        }
    }
}

sub getNewResponse {
    my $url = shift;
    my $finalUrl;
    print "\n Getting a new url $url \n";
    my $curlResponse = getCurl($url, '-I');
    if ( $curlResponse =~ m/301/g ) {
        $curlResponse =~ m/Location:\s(.*)/g;
        die(' Same Url has requested') if ( $url eq $1 );
        $finalUrl = $1;
        getNewResponse($finalUrl);
    } elsif ( $curlResponse =~ m/200/ ) {
        return $url#; if ( $curlResponse =~ m/(200|404)/g );
    } else {
        print "\n - $url - \n";
        die('404 - '.$url)  if ( $curlResponse =~ m/(404)/g );
    }
}

sub getCurl {
    my $url = shift;
    my $flag = shift;

    return `curl $flag $url`;
}

getUrls();


