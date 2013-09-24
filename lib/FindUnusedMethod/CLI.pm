package FindUnusedMethod::CLI;
use strict;
use warnings;
use 5.014000;
use FindUnusedMethod;

sub run {
    my ($class, $args) = @_;

    my $app = FindUnusedMethod->new;

    for my $file (@$args) {
        $app->register_file($file);
    }

    my $unused_methods = FindUnusedMethod::unused_methods($app);

    for my $unused_method (@$unused_methods) {
        my ($package, $method, $line) = @$unused_method;

        say "@{[ $package ]}#L@{[ $line ]}\t@{[ $method ]}";
    }
}

1;
