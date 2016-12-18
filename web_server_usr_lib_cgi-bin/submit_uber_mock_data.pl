#!/usr/bin/perl -w

use strict;
use warnings;
use 5.10.0;
use FindBin;

use Scalar::Util qw(blessed);
use Try::Tiny;

use Kafka::Connection;
use Kafka::Producer;

use Data::Dumper;
use CGI qw/:standard/, 'Vars';

my $location = param('location');
my $year = param('year');
my $month = param('month');
my $day = param('day');
my $hour = param('hour');
my $minute = param('minute');
my $second = param('second');
my $pickup = param('pickup');

my ( $connection, $producer );
try {
    #-- Connection
    $connection = Kafka::Connection->new( host => 'localhost', port => 9092 );

    #-- Producer
    $producer = Kafka::Producer->new( Connection => $connection );

    my $message = "<new_uber_pickup>";
    $message .= "<location>" . $location . "</location>";
    $message .= "<year>" . $year . "</year>";
    $message .= "<month>" . $month . "</month>";
    $message .= "<day>" . $day . "</day>";
    $message .= "<hour>" . $hour . "</hour>";
    $message .= "<minute>" . $minute . "</minute>";
    $message .= "<second>" . $second . "</second>";
    $message .= "<pickup>" . $pickup . "</pickup>";
    $message .= "</new_uber_pickup>";

    # Sending a single message
    my $response = $producer->send(
        'xinran-uber-events',              # topic
        0,                                 # partition
        $message                           # message
    );
} catch {
    if ( blessed( $_ ) && $_->isa( 'Kafka::Exception' ) ) {
        warn 'Error: (', $_->code, ') ',  $_->message, "\n";
        exit;
    } else {
        die $_;
    }
};

# Closes the producer and cleans up
undef $producer;
undef $connection;

print header(-type => 'text/plain', -charset => 'UTF-8');

print 'Done. Please refresh the plot by clicking the button above: Show the plot!';


