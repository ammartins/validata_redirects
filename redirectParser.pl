#!/usr/bin/perl

use strict;

open FH, '<', 'redirect.txt' or die('Not able to open file');
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
            $_ =~ m[(Redirect|RedirectMatch)\s(3\d\d|permanent)\s(.*)\s(/.*|http://.*|https://.*)]g;
            $rebuildLine = $1." ".$2." ".$3." ";
            $first = $4;

            if ( !($first =~ m/http:\/\//g or $first =~ m/https:\/\//g) ) {
                $url = "http://www.leaseweb.com".$first."\n";
            } else {
                $url = $first;
            }

            $response = getCurl($url, '-I');

            if ( $response =~ m/301/g ) {
                my $correctUrl = getNewResponse($url);
                print OU $rebuildLine.$correctUrl;
            }
            elsif ( $response =~ m/200/g ) {
                print OU $_;
            }
            elsif ( $response =~ m/404/g ) {
                print OU '# 404 - '.$_;
            }
            else {
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
    if ( getCurl($url, '-I') =~ m/301/g ) {
        my $response = getCurl($url, '');
        $response =~ m/((https|http):\/\/.*)\"/g;
        $finalUrl = $1;
        getNewResponse($finalUrl);
    }
    return $finalUrl;
}

sub getCurl {
    my $url = shift;
    my $flag = shift;

    return `curl $flag $url`;
}

getUrls();
