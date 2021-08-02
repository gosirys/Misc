#!/usr/bin/perl

#$equazionez = "-4-3+3:-2+5*-3+4:-3:-6*+7*-3-3*+7+9*-3*-4";

#$equazionez = "+2*+3:+2+5+18-3:+4:+8+5*+7:+2";
#$equazionez = "+2-1:+2*+4:+3+{[(+2:+5*-100:+3:+6-1:+6)*+9:+2]-7:+12}";
#$equazionez = "+2-1:+2*+4:+3+1:+18*+9:+2-7:+12";

#$equazionez = "+2-[(+3-1:+5):(+2+4:+5)+1:+3]*(+1-5:+8)+1:+2+1:+4"; ES 1 pag 117
#$equazionez = "+2+(+3-4*-5):(+2+4:+5)";
#$equazionez = "+2+23:(+14:+5)";

#$equazionez = "+2-[(+3-1:+5):(+2+4:+5)+1:+3]*(+1-5:+8)+1:+2+1:+4";                         #ES 1 pag 117
#$equazionez = "(+19:+3-2*+5:+6)+3:+4-2:+3:(+1:+6):(+8:+5)+(+7:+2+3:+4*+5:+6:+15)*+12:+17"; #ES 2 pag 117
$equazionez = "+1:+2+[+1:+3+(+2:+5)*(+1+2:+3)+2:(+1-1:+3)]*(+6:+5-1):(+1:+5)";             #ES 9 pag 117


print "\n[+] Risolvendo: $equazionez\n\n";

$equazione = conv($equazionez,2,2);

risolvi($equazione);

exit;

sub risolvi() {
    my $equazione = $_[0];
    conv($equazione,1,1);
    if ($equazione  =~ /\(/) {
        my($tcnt,$tcntt) = (0,0);
        while ($equazione =~ /\(/g) {
            $tcnt++;
        }
        while (($equazione =~ /\(([^)]+)\)/g)&&($tcntt < $tcnt)) {
            my $piece = $1;
            my $tcntt++;
            my $mpiece = &risolvi_($piece);
            $equazione =~ s/\($piece\)/$mpiece/;
            $equazione = &clean($equazione);
            conv($equazione,1,1);
        }
    }
    if ($equazione  =~ /\[/) {
        my($tcnt,$tcntt) = (0,0);
        while ($equazione =~ /\[/g) {
            $tcnt++;
        }
        while (($equazione =~ /\[([^\]]+)\]/g)&&($tcntt < $tcnt)) {
            my $piece = $1;
            my $tcntt++;
            my $mpiece = &risolvi_($piece);
            $equazione =~ s/\[$piece\]/$mpiece/;
            $equazione = &clean($equazione);
            conv($equazione,1,1);
        }
    }
    if ($equazione  =~ /\{/) {
        my($tcnt,$tcntt) = (0,0);
        while ($equazione =~ /\{/g) {
            $tcnt++;
        }
        while (($equazione =~ /\{([^}])\}/g)&&($tcntt < $tcnt)) {
            my $piece = $1;
            my $tcntt++;
            my $mpiece = &risolvi_($piece);
            $equazione =~ s/\{$piece\}/$mpiece/;
            $equazione = &clean($equazione);
            conv($equazione,1,1);
        }
    }
    $equazione_u = risolvi_($equazione);
}

sub risolvi_() {
    my($equazione,$count) = ($_[0],-1);
    my(@numerii,@signss,@opss,$countz,@tmp_nnum,$cnm,@total,$string);
    while ($equazione =~ /(^|[0-9.])(meno|più)([0-9.]+)(diviso|per)(meno|più)([0-9.]+)(meno|più|$)/g) {
        my($num,$num2) = ($2.$3,$5.$6);
        my $num_ = $num."$4".$num2;
        my $g_num = $num."-".$num2;
        if ($4 =~ /per/) {
            $cnm = &sign($g_num,1);
        }
        elsif ($4 =~ /diviso/) {
            $cnm = &sign($g_num,2);
        }
        $equazione =~ s/$num_/$cnm/;
        conv($equazione,1,1);
    }
    while ($equazione =~ /(più|meno|)([0-9.]+)(per|diviso|più|meno|)/g) {
        my($sign,$num,$boh) = ($1,$2,$3);
        $count += 3;
        $countz = $count - 3;
        if ($tmp_nnum[$countz] !~ /per|diviso/) {
            push(@total," ");
        }
        if ($sign !~ /./) {
            $sign =~ s/(.*)/vuoto/;
        }
        push(@tmp_nnum,$sign,$num,$boh);
        if ($sign =~ /vuoto/) {
            $sign =~ s/(.*)/$tmp_nnum[$countz]/;
        }
        if ($boh =~ /per|diviso/) {
            push(@total,$sign,$num,$boh);
        }
        else {
            if ($tmp_nnum[$countz] =~ /per|diviso/) {
                push(@total,$sign,$num);
            }
        }
    }
    $string = join '', @total;
    $string =~ s/.+/$string /;
    $string =~ s/( +)/ /g;
    $string =~ s/^ //;
    while ($string =~ /([^ ]+) /g) {
        $equazione = &calcola($1,$equazione,"1");
    }
    if ($equazione =~ /(meno|più)([0-9.]+)(meno|più)/) {
        $equazione = &calcola($equazione,$equazione,"2");
    }
    #conv($equu,1,1);
    return($equazione);
}

sub calcola() {
    my($string,$equazione,$way,$stop,$cntm) = ($_[0],$_[1],$_[2],0,0);
    my(@numeri,@signs,@ops,@risultati,$sign,$st0p);
    if ($string =~ /\./) {
        $string =~ s/\./0011001100/g;
    }
    while ($string =~ /([0-9.]+)/g) {
        my $anum = $1;
        if ($anum =~ /0011001100/) {
            $anum =~ s/0011001100/./;
        }
        push(@numeri,$anum);
    }
    while ($string =~ /(diviso|per)/g) {
        push(@ops,$1);
    }
    while ($string =~ /(meno|più)/g) {
        push(@signs,$1);
    }
    $string =~ s/0011001100/./g;
    my($count,$count_,$count__,$cop) = (2,1,0,0);
    my $num_n = scalar(@numeri);
    $num_n++;
    while (my $a__ = <@numeri>) {
        if ($stop != 1) {
            if ($a__ == $numeri[0]) {
                if ($way == 1) {
                    if ($ops[$cop] =~ /per/) {
                        $risultati[$count__] = $a__*$numeri[1];
                    }
                    elsif ($ops[$cop] =~ /diviso/) {
                        $risultati[$count__] = $a__/$numeri[1];
                    }
                    $signss[$count__] = signs($signs[0],$signs[1]);
                    my($ris,$sign,$num2,$bstring) = ($risultati[$count__],$signss[$count__],$numeri[1],$string);
                    if ($string =~ /(meno|più)$a__(per|diviso)(meno|più)$num2/) {
                        $string =~ s/$1$a__$2$3$num2/$sign$ris/;
                        $equazione =~ s/$bstring/$string/;
                        conv($equazione,1,1);
                    }
                }
                elsif ($way == 2) {
                    if (($signs[0] =~ /più/)&&($signs[1] =~ /più/)) {
                        $risultati[$count__] = $a__+$numeri[1];
                    }
                    elsif (($signs[0] =~ /più/)&&($signs[1] =~ /meno/)) {
                        $risultati[$count__] = $a__-$numeri[1];
                    }
                    elsif (($signs[0] =~ /meno/)&&($signs[1] =~ /più/)) {
                        $risultati[$count__] = -$a__+$numeri[1];
                    }
                    elsif (($signs[0] =~ /meno/)&&($signs[1] =~ /meno/)) {
                        $risultati[$count__] = -$a__-$numeri[1];
                    }
                    my($ris,$fsign,$ssign,$num2,$bstring) = ($risultati[$count__],$signs[0],$signs[1],$numeri[1],$string);
                    if ($string =~ /$fsign$a__$ssign$num2/) {
                        $string =~ s/$fsign$a__$ssign$num2/$ris/;
                        $equazione =~ s/$bstring/$string/;
                        $equazione =~ s/-/meno/g;
                        $equazione =~ s/\+/più/g;
                        $equazione = &clean($equazione);
                        if ($equazione !~ /^(meno|più)/) {
                            $equazione =~ s/.+/più$equazione/;
                        }
                        if ($equazione !~ /(più|meno)([0-9.]+)(più|meno)/) {
                            $st0p = 1;
                        }
                        conv($equazione,1,1);
                    }
                }
                $cop++;
            }
            if ($way == 1) {
                if ($ops[$cop] =~ /per/) {
                    $risultati[$count_] = $risultati[$count__]*$numeri[$count];
                }
                elsif ($ops[$cop] =~ /diviso/) {
                    $risultati[$count_] = $risultati[$count__]/$numeri[$count];
                }
                $signss[$count_] = signs($signss[$count__],$signs[$count]);
                my($ris,$sign,$num,$num2,$bstring) = ($risultati[$count_],$signss[$count_],$risultati[$count__],$numeri[$count],$string);
                if ($string =~ /(meno|più)$num(per|diviso)(meno|più)$num2/) {
                    $string =~ s/$1$num$2$3$num2/$sign$ris/;
                    $equazione =~ s/$bstring/$string/;
                    conv($equazione,1,1);
                }
            }
            elsif (($way == 2)&&($st0p != 1)) {
                if ($signs[$count] =~ /più/) {
                    $risultati[$count_] = $risultati[$count__]+$numeri[$count];
                }
                elsif ($signs[$count] =~ /meno/) {
                    $risultati[$count_] = $risultati[$count__]-$numeri[$count];
                }
                $string =~ s/-/meno/g;
                $string =~ s/\+/più/g;
                my($ris,$num,$sign,$num2,$bstring) = ($risultati[$count_],$risultati[$count__],$signs[$count],$numeri[$count],$string);
                $num =~ s/-/meno/g;
                $num =~ s/\+/più/g;
                if ($string =~ /$num$sign$num2/) {
                    $string =~ s/$num$sign$num2/$ris/;
                    $equazione =~ s/$bstring/$string/;
                    $equazione =~ s/-/meno/g;
                    $equazione =~ s/\+/più/g;
                    $equazione = &clean($equazione);
                    if ($equazione !~ /^(meno|più)/) {
                        $equazione =~ s/.+/più$equazione/;
                    }
                    conv($equazione,1,1);
                }
            }
            if ($count == ($num_n-2)) {
                $stop = 1;
            }
            $count++; $count_++;$count__++;
        }
        $cop++;
    }
    if ($equazione !~ /^(più|meno)/) {
        $equazione =~ s/.+/più$equazione/;
    }
    return($equazione);
}

sub signs() {
    my($sign,$sign2) = @_;
    my $fsign;
    if (($sign =~ /più/)&&($sign2 =~ /più/)) {
        $fsign = "più";
    }
    elsif (($sign =~ /meno/)&&($sign2 =~ /meno/)) {
        $fsign = "più";
    }
    elsif (($sign =~ /meno/)&&($sign2 =~ /più/)) {
        $fsign = "meno";
    }
    elsif (($sign =~ /più/)&&($sign2 =~ /meno/)) {
        $fsign = "meno";
    }
    return($fsign);
}

sub sign() {
    my($numz,$op) = @_;
    my($num,$num2);
    if ($numz =~ /(.+)-(.+)/) {
        ($num,$num2) = ($1,$2);
    }
    my(@signsm,@signsp,$num_a_,$num_b_,$sign,$ris);
    if ($num =~ /(più|meno)([0-9.]+)/) {
        my $sign = $1;
        $num_a_ = $2;
        if ($sign =~ /più/) {
            push(@signsp,$1);
        }
        else {
            push(@signsm,$1);
        }
    }
    if ($num2 =~ /(più|meno)([0-9.]+)/) {
        my $sign = $1;
        $num_b_ = $2;
        if ($sign =~ /più/) {
            push(@signsp,$1);
        }
        else {
            push(@signsm,$1);
        }
    }
    if ((scalar(@signsp) == 0)||(scalar(@signsm) == 0)) {
        $sign = "più";
    }
    else {
        $sign = "meno";
    }
    if ($op == 1) {
        $ris = $num_a_*$num_b_;
    }
    elsif ($op == 2) {
        $ris = $num_a_/$num_b_;
    }
    my $cnm = $sign.$ris;
    return($cnm);
}

sub conv() {
    my($string,$mode,$opt) = @_;
    if ($mode == 1) {
        $string =~ s/ //g;
        $string =~ s/più/+/g;
        $string =~ s/meno/-/g;
        $string =~ s/per/*/g;
        $string =~ s/diviso/:/g;
    }
    elsif ($mode == 2) {
        $string =~ s/ //g;
        $string =~ s/\+/più/g;
        $string =~ s/-/meno/g;
        $string =~ s/\*/per/g;
        $string =~ s/:/diviso/g;
    }
    if ($opt == 1) {
        if ($string =~ /\./) {
            $string = conv_fraz($string);
        }
        print "$string =\n";

    }
    elsif ($opt == 2) {
        return($string);
    }
}

sub conv_fraz() {
    my($eq,@numeri) = ($_[0]);
    if ($eq =~ /\./) {
        while ($eq =~ /([0-9]+)\.([0-9]+)/g) {
            push(@numeri,$1.".".$2);
        }
        foreach my $e(@numeri) {
            my $match = 0;
            if ($e =~ /(.+)\.(.+)/) {
                my($num1,$num2) = ($1,$2);
                if ($num2 =~ /([0-9][0-9][0-9]){8,}/) {
                    my($f_num,$s_num,$t_num,$q_num,$ss_num);
                    if ($num2 =~ /^([0-9]{1})([0-9]{0,1})([0-9]{0,1})([0-9]{0,1})([0-9]{0,1})/) {
                        ($f_num,$s_num,$t_num,$q_num,$ss_num) = ($1,$2,$3,$4,$5);
                    }
                    if ($num2 =~ /^($f_num$s_num$t_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num,$num1);
                        my $y = $a-$b;
                        my $fraz = $y."/999";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}($s_num$t_num$q_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num.$q_num,$num1.$f_num);
                        my $y = $a-$b;
                        my $fraz = $y."/9990";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}$s_num{1}($t_num$q_num$q_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num.$q_num.$ss_num,$num1.$f_num.$s_num);
                        my $y = $a-$b;
                        my $fraz = $y."/99900";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                }
                elsif ($num2 =~ /([0-9][0-9]){8,}/) {
                    my($f_num,$s_num,$t_num,$q_num);
                    if ($num2 =~ /^([0-9]{1})([0-9]{0,1})([0-9]{0,1})([0-9]{0,1})/) {
                        ($f_num,$s_num,$t_num,$q_num) = ($1,$2,$3,$4);
                    }
                    if ($num2 =~ /^($f_num$s_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num,$num1);
                        my $y = $a-$b;
                        my $fraz = $y."/99";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}($s_num$t_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num,$num1.$f_num);
                        my $y = $a-$b;
                        my $fraz = $y."/990";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}$s_num{1}($t_num$q_num){8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num.$q_num,$num1.$f_num.$s_num);
                        my $y = $a-$b;
                        my $fraz = $y."/9900";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                }
                elsif ($num2 =~ /([0-9]{1}){8,}/) {
                    my($f_num,$s_num,$t_num);
                    if ($num2 =~ /^([0-9]{1})([0-9]{0,1})([0-9]{0,1})([0-9]{0,1})/) {
                        ($f_num,$s_num,$t_num,$x_num) = ($1,$2,$3,$4);
                    }
                    if ($num2 =~ /^$f_num{8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num,$num1);
                        my $y = $a-$b;
                        my $fraz = $y."/9";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}$s_num{8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num,$num1.$f_num);
                        my $y = $a-$b;
                        my $fraz = $y."/90";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}$s_num{1}$t_num{8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num,$num1.$f_num.$s_num);
                        my $y = $a-$b;
                        my $fraz = $y."/900";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                    elsif ($num2 =~ /^$f_num{1}$s_num{1}$t_num{1}$x_num{8,}/) {
                        $match = 1;
                        my($a,$b) = ($num1.$f_num.$s_num.$t_num.$x_num,$num1.$f_num.$s_num.$t_num);
                        my $y = $a-$b;
                        my $fraz = $y."/9000";
                        my $fraz = scomp_fraz($fraz);
                        $eq =~ s/$e/$fraz/;
                    }
                }
                if ($match != 1) {
                    my($count,$zero) = (0,);
                    while ($num2 =~ /[0-9]/g) {
                        $count++;
                    }
                    for (1..$count) {
                        $zero .= "0";
                    }
                    my $mul = "1".$zero;
                    my $y = $e*$mul;
                    my $fraz = $y."/".$mul;
                    my $fraz = scomp_fraz($fraz);
                    $eq =~ s/$e/$fraz/;
                }
            }
        }
        return($eq);
    }
}

sub scomp_fraz() {
    my($fraz,$count) = ($_[0],0);
    my($big,$little,$done);
    if ($fraz =~ /([0-9]{1,})\/([0-9]{1,})/) {
        my($numA,$numB) = ($1,$2);
        @todiv = qw(2 3 4 5 6 7 8 9 11);
        while ($count < 9) {
            foreach my $e(@todiv) {
                $count++;
                my $y = $numA/$e;
                my $k = $numB/$e;
                if (($y !~ /\./)&&($k !~ /\./)) {
                    $count = $count-9;
                    ($numA,$numB) = ($y,$k);
                    if ($numB == 1) {
                        $count .= +50;
                    }
                }
            }
        }
        if ($numA > $numB) {
            ($big,$little) = ($numA,$numB);
        }
        else {
            ($big,$little) = ($numB,$numA);
        }
        my $y = $big/$little;
        if ($y !~ /\./) {
            $big =~ s/.+/$y/;
            $little =~ s/.+/1/;
        }
        if ($numA > $numB) {
            $numA =~ s/.+/$big/;
            $numB =~ s/.+/$little/;
        }
        elsif ($numB > $numA) {
            $numA =~ s/.+/$little/;
            $numB =~ s/.+/$big/;
        }
        if ($numB == 1) {
            $done = $numA;
        }
        else {
            $done = $numA."/".$numB;
        }
        return($done);
    }
}

sub clean() {
    my $equazione = $_[0];
    if ($equazione =~ /(piùpiù|menomeno|piùmeno|menopiù)/) {
        my $double = $1;
        if ($double =~ /piùpiù/) {
            $equazione =~ s/piùpiù/più/g;
        }
        elsif ($double =~ /menomeno/) {
            $equazione =~ s/menomeno/più/g;
        }
        elsif ($double =~ /piùmeno|menopiù/) {
            $equazione =~ s/piùmeno/meno/g;
            $equazione =~ s/menopiù/meno/g;
        }
    }
    return($equazione);
}