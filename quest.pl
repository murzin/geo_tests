#!/usr/bin/env perl

use common::sense;
use autodie;
use Data::Dumper;

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
print "from: "; $start = <>; chomp $start;
print "to : "; $stop = <>; chomp $stop;
print "rand?: "; $rand = <>; chomp $rand;
$start = 1 unless $start;
$stop = 200 unless $stop;

say "start: $start stop: $stop";
$start-- unless $rand;
while (1) {
    my $q;
    if (! $rand) {
        $q = $start++;
        last if $q >= $stop;
    } else {
        $q = $start + int(rand($stop-$start+1)) - 1;
    }
    my $qnum = $order[$q];
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

