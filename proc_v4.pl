use Switch;

$R_ykkom=0;
$R_ir=0;
$R_ron=0;
$R_ron_pr=0;

$W_adrkom=0;$O_adrkom=1;
$W_kom=0;$O_kom=1;
$W_kop=0;$O_kop=1;
$W_a=0;$O_a=1;
$W_ia=0;$O_ia=1;
$W_sp=0;$O_sp=1;
$W_a1=0;$O_a1=1;
$W_pr=0;$O_pr=1;
$W_rez1=0;$O_rez1=1;
$W_r2=0;$O_r2=1;
$W_ind=0;$O_ind=1;
$W_prznk=0;$O_prznk=1;
$W_sum=0;$O_sum=1;

$D_pusk=1;$O_pusk=1;$D_pusk=1*$O_pusk;
$D_vzap1=0;$O_vzap1=1;
$D_zam1=0;$O_zam1=1;
$D_zam2=0;$O_zam2=1;
$D_chist=0;$O_chist=1;
$D_op=0;$O_op=1;
$D_vib=0;$O_vib=1;
$D_zapp=0;$O_zapp=1;
$D_pereh=0;$O_pereh=1;

@mem=();
open F,$ARGV[0];
while ($read=<F>){
	my @words =split ' ',$read;
	@mem=(@mem,@words)
}
close F;

while ($D_pusk==1) {
	#load from registers
	$W_adrkom=$O_adrkom*$R_ykkom;
	$W_ind=$O_ind*$R_ir;
	$W_sum=$O_sum*$R_ron;
	$W_prznk=$O_prznk*$R_ron_pr;
	#look to memory 1
	$W_kom=($O_kom==1)?($mem[$W_adrkom].$mem[$W_adrkom+1].$mem[$W_adrkom+2]):'000000';
	#regkom
	$W_kop=$O_kop*(hex substr($W_kom,0,2));
	$W_a=$O_a*((hex substr($W_kom,2,2))*256+(hex substr($W_kom,4,2)));
	#decom
	my $op=$W_kop>>4;
	my $i=($W_kop%16)>>2;
	my $p=($op==15)?4:$W_kop%4;
	$D_pusk=$O_pusk*(($W_kop!=255)?1:0);
	$D_vzap1=$O_vzap1*(($p==3)?1:0);
	$D_zam1=$O_zam1*(($p==1)?1:0);
	$D_zam2=$O_zam2*(($p!=3)?1:0);
	$D_chist=$O_chist*(($p!=2 and $p!=3)?1:0);
	$D_op=$O_op*$op;
	$D_vib=$O_vib*$i;
	$D_zapp=$O_zapp*(($p==0)?1:0);
	if ($op!=15 or $W_kop==255) {
		$D_pereh=0;
	} else {
		$D_pereh=1 if ($W_kop==254);
		$D_pereh=(($W_prznk>>1)==0)?1:0 if ($W_kop==240);
		$D_pereh=(($W_prznk%2)==0)?0:1 if ($W_kop==241);
		$D_pereh=1 if ($W_kop==244);
		$D_pereh=0 if ($W_kop==245);
	}
	$D_pereh=$O_pereh*$D_pereh;
	#add ir and a
	$W_ia=$O_ia*($W_ind+$W_a);
	#inc adrkom
	$W_adrkom+=3;
	#m1
	$W_adrkom=$W_ia if ($D_pereh==1);
	#look to memory 2
	$W_sp=$O_sp*((hex $mem[$W_ia])*256+(hex $mem[$W_ia+1]));
	#m2
	$W_a1=$O_a1*(($D_vib==0)?$W_sp:$W_ia);
	#alu
	switch ($D_op){
		case 0{$W_rez1=$W_sum;}
		case 1{$W_rez1=$W_a1;}
		case 2{$W_rez1=$W_a1+$W_sum;}
		case 3{$W_rez1=$W_sum-$W_a1;}
	}
	$W_pr=$O_pr*((($W_rez1==0)?0:1)*2+(($W_rez1>0)?1:0));
	$W_rez1=$O_rez1*$W_rez1;
	#m3
	$W_r2=$O_r2*(($D_chist==0)?$W_rez1:0);
	#write data to registers
	$R_ykkom=$W_adrkom if ($D_pusk==1);
	$R_ron=$W_rez1 if ($D_zam1==1);
	$R_ron_pr=$W_pr if ($D_zam1==1);
	$R_ir=$W_r2 if ($D_zam2==1);
	if ($D_zapp==1){
		my $r=$W_rez1;
		$mem[$W_ia+1]=&to_hex ($r%256);
		$r>>=8;
		$mem[$W_ia]=&to_hex ($r);
	}
	# &show_all;
	# $s=<>;
}
&show_all;
	

sub show_all{
	$\="\n";
	$,=" ";
	print "        REGISTERS:";
	print "ykkom: ",$R_ykkom;
	print "ir: ",$R_ir;
	print "ron: ",$R_ron;
	print "ron pr: ",$R_ron_pr;
	print "        WIRES:";
	print "adrkom: ",$W_adrkom;
	print "kom: ",$W_kom;
	print "kop: ",$W_kop;
	print "a: ",$W_a;
	print "ia: ",$W_ia;
	print "sp: ",$W_sp;
	print "a1: ",$W_a1;
	print "pr: ",$W_pr;
	print "rez1: ",$W_rez1;
	print "r2: ",$W_r2;
	print "ind: ",$W_ind;
	print "prznk: ",$W_prznk;
	print "sum: ",$W_sum;
	print "        DECOM:";
	print "pusk: ",$D_pusk;
	print "vzap1: ",$D_vzap1;
	print "zam1: ",$D_zam1;
	print "zam2: ",$D_zam2;
	print "chist: ",$D_chist;
	print "op: ",$D_op;
	print "vib: ",$D_vib;
	print "zapp: ",$D_zapp;
	print "pereh: ",$D_pereh;
	print "        MEMORY:";
	$\=' ';
	my $i=0;
	print (&to_hex ($i).":");
	for (0 .. $#mem){
		print $mem[$_];
		if (($_+1)%16==0){
			$i++;
			print "\n".(&to_hex ($i)).":" 
		}
	}
}

sub to_hex{
	my $a=$_[0];
	my $b=int $a/16;
	if ($b<10){
		$b+=48
	} else {
		$b+=55
	}
	$b=chr $b;
	my $c=$a%16;
	if ($c<10){
		$c+=48
	} else {
		$c+=55
	}
	$c=chr $c;
	return $b.$c
};