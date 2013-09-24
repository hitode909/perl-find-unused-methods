#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib 'lib';
use lib "$FindBin::Bin/../lib";
use FindUnusedMethod::CLI;

FindUnusedMethod::CLI->run(\@ARGV);
