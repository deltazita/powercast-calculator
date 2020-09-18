#!/usr/bin/perl -w

use strict;
use Math::Trig ':pi';
use Math::Random;
use Switch;

die "usage: $0 <distance> <p1110/p2110>\n" unless (@ARGV == 2);

my $d = shift;
my $type = shift;
my $Ptx = 3; # EIRP

if (($type ne "p1110") && ($type ne "p2110")){
	print "# p1110 or p2110 must be defined!\n";
	exit;
}

my ($h, $r) = harvest();
printf "harvested: %.9f from %.9f received Watts \n", $h, $r;

sub harvest{
	my $i = Prx();
	my $eff = 0;
	my $h = 0;
	switch($type){
		case ("p1110"){
			$eff = eff_p1110($i);
			$h = $i*$eff;
			$h = 0.1 if ($h > 0.1);
		}
		case ("p2110"){
			$eff = eff_p2110($i);
			$h = $i*$eff;
			$h = 0.05 if ($h > 0.05);
		}
	}
	return ($h, $i);
}

sub eff_p1110{
	my $x = shift;
	$x *= 1000; # W to mW
	my $y = 0.5;
	if ($x < 0.3){
		$y = 0;
	}elsif (($x >= 0.3) && ($x < 0.6)){ # case 1
		$y = 1.433*$x-0.38;
	}elsif (($x >= 0.6) && ($x < 0.95)){ # case 2
		$y = exp(-($x-0.95)**2/0.74**2)/1.66;
	}elsif (($x >= 0.95) && ($x < 4)){ # case 3
		$y = exp(-($x-0.95)**2/6.5**2)/1.66;
	}elsif (($x >= 4) && ($x < 11)){ # case 4
		$y = exp(-($x-11)**2/11.5**2)/1.43;
	}elsif (($x >= 11) && ($x <= 100)){ # case 5
		$y = exp(-($x-11)**2/169**2)/1.43;
	}
	#printf "efficiency: %.6f \n", $y;
	return $y;
}

sub eff_p2110A{ # Version A
	my $x = shift;
	$x *= 1000; # W to mW
	my $y = 0.5;
	if ($x < 0.06){
		$y = 0;
	}elsif (($x >= 0.06) && ($x < 0.2)){ # case 1
		$y = ($x-0.06)**0.6 * (1.395-$x)**2;
	}elsif (($x >= 0.2) && ($x < 0.32)){ # case 2
		$y = exp(-($x-0.32)**2/0.39**2)/2.05;
	}elsif (($x >= 0.32) && ($x < 0.8)){ # case 3
		$y = exp(-($x-0.32)**2/1.3**2)/2.05;
	}elsif (($x >= 0.8) && ($x < 3.5)){ # case 4
		$y = exp(-($x-3.5)**2/4.8**2)/1.7;
	}elsif (($x >= 3.5) && ($x <= 10)){ # case 5
		$y = exp(-($x-3.5)**2/14.5**2)/1.7;
	}
	#printf "efficiency: %.6f \n", $y;
	return $y;
}

sub eff_p2110{ # Version B
	my $x = shift;
	$x *= 1000; # W to mW
	my $y = 0.52;
	if ($x < 0.04){
		$y = 0;
	}elsif (($x >= 0.04) && ($x < 0.08)){
		$y = exp(-($x-1.114)**28);
	}elsif (($x >= 0.08) && ($x < 0.2)){
		$y = ($x-0.078)**0.5 * (1.38-$x)**2.1;
	}elsif (($x >= 0.2) && ($x < 0.35)){
		$y = exp(-($x-0.32)**2/0.35**2)/1.795;
	}elsif (($x >= 0.33) && ($x < 0.6)){
		$y = exp(-($x-0.32)**2/1.1**2)/1.795;
	}elsif (($x >= 0.6) && ($x < 0.8)){
		$y = 1.7**(($x-0.7)**2) - 0.48;
	}elsif (($x >= 0.8) && ($x < 2.5)){
		$y = exp(-($x-2.5)**2/3.75**2)/1.555;
	}elsif (($x >= 2.5) && ($x <= 10)){
		$y = exp(-($x-2.5)**2/17**2)/1.555;
	}
	#printf "efficiency: %.6f \n", $y;
	return $y;
}

sub Prx{
	my ($Grx, $lambda) = (6, 3*10**8/915000000);
	$Grx = 10**($Grx/10);
	my $P1 = $Ptx*$Grx*($lambda/(4*pi*1))**2;
	my $G = 0.5;#random_uniform(1, 0, 1);
	my $sigma = 0.5; # 10dB
	my $I = $P1 * exp(2*$sigma*$G) / $d**2;
	return $I;
}
