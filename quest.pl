#!/usr/bin/env perl

use common::sense;
use autodie;
use Data::Dumper;

binmode STDOUT, ':utf8'; no warnings 'redefine';
local *Data::Dumper::qquote = sub { qq["${\(shift)}"] };
local $Data::Dumper::Useperl = 1;
local $Data::Dumper::Sortkeys = 1;
sub dumper { Data::Dumper->new([@_])->Indent(1)->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }

use List::Util q{shuffle};

my $q_file = 'kart_quest.txt';
my %anum = qw{1 ა) 2 ბ) 3 გ) 4 დ)};

my %questions;
my @order;
open my $F, '<:utf8', $q_file;

my $cur_quest;
my $cur_text;
while (<$F>) {
    chomp;
    next unless $_;
    next if /^\d+$/;
    if (/^(I[^\s]+).+([აბდგ][\)])$/) {
        unless ($questions{$1}) {
            say $_;
            print Dumper \%questions;
            die "no such q: $1 " unless $questions{$1};
        }
        $questions{$1}{answer} = $2;
        next;
    }
    if (/^(I[^\s]+)/ && ! $cur_quest) {
        $cur_quest = $1;
        push @order, $cur_quest;
        $questions{$1}{title} = $_;
        next;
    } elsif (/^(I[^\s]+)/ && $cur_quest) {
        say $_;
        print Dumper \%questions;
        die "qur quest prob!";
    }
    if ($cur_quest && /^ა\)/) {
        $questions{$cur_quest}{'ა)'} = $_;
        $questions{$cur_quest}{text} = $cur_text;
        $cur_text= '';
        next;
    }
    if ($cur_quest && /^ბ\)/) {
        $questions{$cur_quest}{'ბ)'} = $_;
        next;
    }
    if ($cur_quest && /^გ\)/) {
        $questions{$cur_quest}{'გ)'} = $_;
        next;
    }
    if ($cur_quest && /^დ\)/) {
        $questions{$cur_quest}{'დ)'} = $_;
        $cur_quest = '';
        next;
    }
    $cur_text.= $_.' ';
}
close $F;

#for my $qn (@order) {
#    say "TITLE: ".$questions{$qn}{title};
#    say "TEXT: ".$questions{$qn}{text};
#    say $questions{$qn}{'ა)'};
#    say $questions{$qn}{'ბ)'};
#    say $questions{$qn}{'გ)'};
#    say $questions{$qn}{'დ)'};
#    say "ANSWER: ".$questions{$qn}{answer};
#}

my ($start, $stop, $rand, $answer);
if (@ARGV) {
    $start = 0 + shift @ARGV;
    $stop = 0 + shift @ARGV;
    unless ($start > 0 && $start < $stop) {
        undef $start, $stop;
    }
}
my $stat_file = "stat_file";
my $stat;
if (-f $stat_file) {
    open my $f, "<", $stat_file or die;
    local $/;
    my $VAR1;
    $stat = eval <$f>;
    say $@ and exit if $@;
    close $f;
}

#print Dumper $stat;
#say "ee";exit;
print "from: " and $start = <> and chomp $start unless $start;
print "to : " and $stop = <> and chomp $stop unless $stop;
print "rand?: "; $rand = <>; chomp $rand;
$start = 1 unless $start;
$stop = 200 unless $stop;

say "start: $start stop: $stop";
$start-- unless $rand;
while (1) {
    my $q;
    if (! $rand) {
        $q = $start++;
        last if $q == $stop;
    } else {
        $q = $start + int(rand($stop-$start+1)) - 1;
    }
    my $qnum = $order[$q];
    randomize_questions($qnum);
    say $questions{$qnum}{title};
    say $questions{$qnum}{text};
    say $questions{$qnum}{'ა)'};
    say $questions{$qnum}{'ბ)'};
    say $questions{$qnum}{'გ)'};
    say $questions{$qnum}{'დ)'};
    say; print"? ";
    $answer = <>; chomp $answer;
    say "answer: ".$anum{$answer};
    say "right answer: ".$questions{$qnum}{answer};
    if ($anum{$answer} eq $questions{$qnum}{answer}) {
        $stat->{$qnum}{ok}++;
    } else {
        $stat->{$qnum}{no}++;
    }
    open my $f, ">", $stat_file or die;
    print $f Dumper $stat;
    close $f or die;
    <>;
    say; say;
}

sub randomize_questions {
    my $q = $questions{+shift};
    my @rand_l = shuffle 1..4;
    $q->{$_} = $anum{$rand_l[{reverse %anum}->{$q->{$_}} - 1]} for qw(answer);
    my %new;
    ($new{$anum{$rand_l[$_-1]}} = $q->{$anum{$_}}) =~ s/\Q$anum{$_}\E/$anum{$rand_l[$_-1]}/ for 1..4;
    $q->{$_} = $new{$_} for values %anum;
}
