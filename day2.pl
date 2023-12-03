#!/usr/bin/perl

use strict;
use warnings;

use 5.34.0;
use Regexp::Grammars;
use Data::Dumper;


my $input = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
";

my $max_red = 12;
my $max_green = 13;
my $max_blue = 14;

# Doc: https://metacpan.org/pod/Regexp::Grammars
my $parser = qr{
    <nocontext:>
    <game>
    <rule: game>      Game <gameid>: <[draws]> ** (;)
    <token: gameid>   \d+
    <rule: draws>     <[MATCH=draw]> ** (,)
    <rule: draw>      <quantity> <color>
    <rule: quantity>  \d+
    <rule: color>     (green|red|blue)
}xms;

my $total = 0;
my @input_split = split('\n', $input); # TODO: could have used grammar above instead of split.

foreach my $line (@input_split) {
    print("$line\n"); 
    my $should_skip = 0;  # TODO: should use a bool.
    $line =~ $parser;
    my $hash = \%/;  # TODO: what is this exactly? It lets me access the output of operation above, but I'm not sure waht it is.
    # print(Dumper($hash));  # Useful for debugging.
    my $game = $hash->{'game'};
    my $gameid = $game->{'gameid'};
    print("Game ", $gameid, "\n");
    my $draws = $game->{'draws'};
    while (my ($i, $draw) = each @{$draws}) {
        print("\t== draw: ", $i, "\n");
        foreach my $ballquantity (@{$draw}) {
            my $quantity = $ballquantity->{'quantity'};
            my $color = $ballquantity->{'color'};
            print("\t\t", $quantity, " ", $color, "\n");
            if ($color eq 'red' && $quantity > $max_red) {
                print("\t\t\tshould skip game\n");
                $should_skip = 1;
                last;
            }
            if ($color eq 'green' && $quantity > $max_green) {
                print("\t\t\tshould skip game\n");
                $should_skip = 1;
                last;
            }
            if ($color eq 'blue' && $quantity > $max_blue) {
                print("\t\t\tshould skip game\n");
                $should_skip = 1;
                last;
            }
        }
        if ($should_skip == 1) {
            last;
        }
    }
    if ($should_skip == 0) {
        $total += $gameid;
    }
}
print("\n\n********** Part 1: the grand total: ", $total, "\n");


# TODO: parse the input only once for both parts.
my $total_power = 0;
foreach my $line (@input_split) {
    my $greatest_red = 0;
    my $greatest_green = 0;
    my $greatest_blue = 0;
    print("$line\n"); 
    $line =~ $parser;
    my $hash = \%/;
    my $game = $hash->{'game'};
    my $gameid = $game->{'gameid'};
    print("Game ", $gameid, "\n");
    my $draws = $game->{'draws'};
    while (my ($i, $draw) = each @{$draws}) {
        print("\t== draw: ", $i, "\n");
        foreach my $ballquantity (@{$draw}) {
            my $quantity = $ballquantity->{'quantity'};
            my $color = $ballquantity->{'color'};
            print("\t\t", $quantity, " ", $color, "\n");
            if ($color eq 'red' && $quantity > $greatest_red) {
                $greatest_red = $quantity;
            }
            if ($color eq 'green' && $quantity > $greatest_green) {
                $greatest_green = $quantity;
            }
            if ($color eq 'blue' && $quantity > $greatest_blue) {
                $greatest_blue = $quantity;
            }
        }
    }
    print("\t ** greatest red: ", $greatest_red, "\n");
    print("\t ** greatest green: ", $greatest_green, "\n");
    print("\t ** greatest blue: ", $greatest_blue, "\n");
    my $game_power = $greatest_red * $greatest_green * $greatest_blue;
    print("\t ** game power : ", $game_power, "\n");
    $total_power += $game_power
}
print("\n\n********** Part 2: the grand total: ", $total_power, "\n");

