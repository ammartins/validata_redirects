#!/usr/bin/perl

use strict;

open FH, '<', 'redirect2.txt' or die('Not able to open file');
open FH2, '>', '3012.txt' or die("Not able to find the file");
open FH3, '>', '2002.txt' or die("Not able to find the file");
open FH404, '>', '4042.txt' or die("Not able to find the file");
open FH4, '>', 'other2.txt' or die("Not able to find the file");

sub getUrls {
    my $first;
    my $url;
    my $response;
    my $count = 0;
    while ( <FH> ) {
        print "\n\n Line Number $count \n\n";
        $count = $count +1;
        $_ =~ m/(Redirect|RedirectMatch)\s301\s.*\s(\/.*|http:.*)/g;
        #$_ =~ m/Redirect\s301\s.*\s(\/.*)/g;
        $first = $2;

        if ( !($first =~ m/http:\/\//g or $first =~ m/https:\/\//g) ) {
            $url = "http://www.leaseweb.com".$first."\n";
        } else {
            $url = $first;
        }

        
        $response = getCurl($url, '-I');
        #$response = system("curl $url");

        if ( $response =~ m/301/g ) {
            my $correctUrl = getNewResponse($url);
            print FH2 $_." ".$correctUrl."\n";
        }
        elsif ( $response =~ m/200/g ) {
            print FH3 $_;
        }
        elsif ( $response =~ m/404/g ) {
            print FH404 $_;
        }
        else {
            print FH4 $_;
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
