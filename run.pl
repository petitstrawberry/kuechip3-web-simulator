#!/usr/bin/env perl

# explanation :
#   a script to check in java-mode
# usage :
#   perl run.pl      -> speed    x1
#   perl run.pl 100  -> speed  x100
#   perl run.pl 1000 -> speed x1000
# note :
#   To use GetOpt::Long, written in perl.
#   However, it is not used so shell script is also ok.

use v5.18;
use warnings;
use diagnostics;

# n 倍速の指定 (デフォルト : 1)
my $num_loop = shift // 1;
system qq!perl -pi -e 's/(int DEBUG_ACCEL\\s*=\\s*)(\\d+)/\${1}${num_loop}/' simulator.pde!;

# processing-java のパスチェック
if( qx/which processing-java/ !~ m/\S/ ) {
    die "A command 'processing-java' is not found";
}

# 過去のログファイルを削除
system "rm -f logfile*";

# 実行
chomp(my $wdir = qx/pwd/);
system qq!processing-java --force --sketch=${wdir}/ --run --output=${wdir}/output!;


